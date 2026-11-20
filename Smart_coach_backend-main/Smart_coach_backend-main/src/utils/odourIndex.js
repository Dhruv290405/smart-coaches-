/**
 * BODR – Bad Odour Detection System: alert logic & mathematics
 * (spec: "Bad Odour mathematic logic" document).
 *
 * 1. Individual gas limits (each gas checked independently, strictly greater than):
 *      NH3 > 10 ppm, CH4 > 15 ppm, H2S > 5 ppm  -> "gas over limit"
 *    Shown in the app and reports only; since 21 Nov 2026 they do NOT send
 *    notifications on their own (decision: alert on the Hygiene Score only).
 *
 * 2. Combined Odour Index:
 *      Index = [(NH3/10 + CH4/15 + H2S/5) / 3] x 100   (rounded to 2 dp)
 *    A missing / invalid gas reading counts as 0.
 *
 * 3. Combined Index classification (alert threshold set to 250 on 21 Nov 2026):
 *      >= 250       -> CRITICAL  (= Overall Hygiene Score 37.5 % or below)
 *      90 – <250    -> MEDIUM
 *      < 90         -> no combined-index alert ("Normal")
 *    Hygiene Score % shown in the app = 100 - index / 4 (index 400+ = 0 %).
 *
 * 4. VOC (voc_index) is kept as the original sensor value; it is NOT part of
 *    the index and does not raise notifications.
 *
 * Notifications (in-app + push + email + SMS) are sent for CRITICAL only:
 * combined Index >= 250 (Hygiene Score <= 37.5 %). MEDIUM and gas-over-limit
 * are shown in the app and reports. The app mirrors this in odour_model.dart.
 */

const GAS_THRESHOLDS = { nh3: 10, ch4: 15, h2s: 5 };

const MEDIUM = 90;
const CRITICAL = 250; // critical when index is at or above this
const HIGH = CRITICAL; // kept for compatibility; the HIGH band no longer exists

const ALERT_THRESHOLD = CRITICAL;

const LEVELS = ['Normal', 'Medium', 'Critical'];

function num(v) {
  const n = Number(v);
  return Number.isFinite(n) && n > 0 ? n : 0;
}

function round2(v) {
  return Math.round(v * 100) / 100;
}

/** Reads gases from a raw DB/device row (any of the known column spellings). */
function gasValues(row = {}) {
  return {
    nh3: num(row.nh3_ppm ?? row.nh3),
    ch4: num(row.methane_ppm ?? row.methane ?? row.ch4_ppm ?? row.ch4),
    h2s: num(row.h2s_ppm ?? row.h2s),
  };
}

/** Combined Odour Index = [(NH3/10 + CH4/15 + H2S/5) / 3] x 100. */
function computeOdourIndex(row = {}) {
  const g = gasValues(row);
  const ratioSum = g.nh3 / GAS_THRESHOLDS.nh3 + g.ch4 / GAS_THRESHOLDS.ch4 + g.h2s / GAS_THRESHOLDS.h2s;
  return round2((ratioSum / 3) * 100);
}

/** Combined-index level: Normal / Medium / Critical. */
function bandFor(value) {
  const v = Number(value) || 0;
  if (v >= CRITICAL) return 'Critical';
  if (v >= MEDIUM) return 'Medium';
  return 'Normal';
}

/** Gases whose reading is strictly above the configured threshold. */
function gasAlerts(row = {}) {
  const g = gasValues(row);
  const out = [];
  if (g.nh3 > GAS_THRESHOLDS.nh3) out.push({ gas: 'NH3', value: g.nh3, threshold: GAS_THRESHOLDS.nh3 });
  if (g.ch4 > GAS_THRESHOLDS.ch4) out.push({ gas: 'CH4', value: g.ch4, threshold: GAS_THRESHOLDS.ch4 });
  if (g.h2s > GAS_THRESHOLDS.h2s) out.push({ gas: 'H2S', value: g.h2s, threshold: GAS_THRESHOLDS.h2s });
  return out;
}

function getOdourLevel(index) {
  const level = bandFor(index);
  return {
    level,
    label: level === 'Critical' ? 'Bad Odour Alert' : level === 'Normal' ? null : `${level} Odour`,
    severity: level === 'Critical' ? 'critical' : level === 'Normal' ? 'info' : 'warning',
    sendSms: level === 'Critical',
  };
}

function levelRank(level) {
  return LEVELS.indexOf(level);
}

/** Overall level of one reading = combined index level (Normal / Medium / Critical). */
function overallLevel(row = {}) {
  return bandFor(computeOdourIndex(row));
}

/** Hygiene Score % shown in the app: index 0 -> 100 %, index 400+ -> 0 %. */
function hygieneScore(index) {
  return Math.max(0, Math.min(100, 100 - (Number(index) || 0) / 4));
}

/**
 * Single decision used for ALL odour notifications (in-app, push, email, SMS):
 * 'Critical' when the combined Index >= 250 (Hygiene Score <= 37.5 %), else 'Normal'.
 * Gases over their limit are listed in `reasons` for the message text.
 */
function evaluateOdourReading(row = {}) {
  const g = gasValues(row);
  const voc = num(row.voc_index ?? row.voc);
  const index = computeOdourIndex(row);
  const band = bandFor(index);
  const gases = gasAlerts(row);
  const level = band === 'Critical' ? 'Critical' : 'Normal';
  const reasons = [];
  if (level === 'Critical') {
    reasons.push(`Odour Index ${index} (Hygiene Score ${round2(hygieneScore(index))}%, alert at 37.5% or below)`);
    gases.forEach((a) => reasons.push(`${a.gas} ${round2(a.value)} ppm over ${a.threshold} ppm limit`));
  }
  return { level, band, index, hygiene: round2(hygieneScore(index)), gases, reasons, nh3: g.nh3, ch4: g.ch4, h2s: g.h2s, voc };
}

function alertRank(level) {
  return ['Normal', 'Critical'].indexOf(level);
}

/**
 * PostgREST `or` filter returning a SUPERSET of CRITICAL rows. Index >= 250 needs
 * the ratio sum >= 7.5, so at least one ratio >= 2.5, i.e. that gas is above its
 * limit. Callers must still apply evaluateOdourReading() to get the exact set.
 */
const ALERT_CANDIDATE_FILTER = `nh3_ppm.gt.${GAS_THRESHOLDS.nh3},methane_ppm.gt.${GAS_THRESHOLDS.ch4},h2s_ppm.gt.${GAS_THRESHOLDS.h2s}`;

module.exports = {
  GAS_THRESHOLDS,
  MEDIUM,
  HIGH,
  CRITICAL,
  ALERT_THRESHOLD,
  ALERT_CANDIDATE_FILTER,
  gasValues,
  gasAlerts,
  computeOdourIndex,
  bandFor,
  overallLevel,
  hygieneScore,
  getOdourLevel,
  levelRank,
  evaluateOdourReading,
  alertRank,
};
