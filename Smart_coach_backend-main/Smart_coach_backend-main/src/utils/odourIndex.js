/**
 * BODR – Bad Odour Detection System: alert logic & mathematics
 *
 * Alert levels based on VOC index:
 *   VOC >= 250  -> CRITICAL (Hygiene 15-20%)
 *   VOC >= 100  -> MEDIUM   (Hygiene 30-40%)
 *   VOC < 100   -> Normal   (Hygiene 80%+)
 *
 * Hygiene Score % is VOC-based (piecewise linear):
 *   VOC 250-500+  -> 15-20%
 *   VOC 100-200   -> 30-40%
 *   VOC < 95      -> 80-90%
 *   VOC <= 60     -> 100%
 *
 * Individual gas limits still tracked for display:
 *   NH3 > 10, CH4 > 15, H2S > 5 ppm
 *
 * Notifications: CRITICAL triggers in-app + push + email + SMS.
 * MEDIUM is in-app + push only.
 */

const GAS_THRESHOLDS = { nh3: 10, ch4: 15, h2s: 5 };

const VOC_CRITICAL = 250;
const VOC_MEDIUM = 100;

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

/** VOC-based level: Normal / Medium / Critical. */
function bandFor(vocValue) {
  const v = Number(vocValue) || 0;
  if (v >= VOC_CRITICAL) return 'Critical';
  if (v >= VOC_MEDIUM) return 'Medium';
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

function getOdourLevel(vocValue) {
  const level = bandFor(vocValue);
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

/** Overall level of one reading based on VOC index. */
function overallLevel(row = {}) {
  const voc = num(row.voc_index ?? row.voc);
  return bandFor(voc);
}

/** Hygiene Score % based on VOC index (piecewise linear). */
function hygieneScore(vocValue) {
  const v = Number(vocValue) || 0;
  if (v >= 500) return 15;
  if (v >= 250) return 15 + (500 - v) / (500 - 250) * (20 - 15);
  if (v >= 200) return 20 + (250 - v) / (250 - 200) * (30 - 20);
  if (v >= 100) return 30 + (200 - v) / (200 - 100) * (40 - 30);
  if (v >= 95)  return 40 + (100 - v) / (100 - 95) * (80 - 40);
  if (v >= 60)  return 80 + (95 - v) / (95 - 60) * (100 - 80);
  return 100;
}

/**
 * Single decision used for ALL odour notifications (in-app, push, email, SMS):
 * 'Critical' when VOC >= 250 (Hygiene Score <= 20 %), else 'Normal'.
 * Gases over their limit are listed in `reasons` for the message text.
 */
function evaluateOdourReading(row = {}) {
  const g = gasValues(row);
  const voc = num(row.voc_index ?? row.voc);
  const index = computeOdourIndex(row);
  const band = bandFor(voc);
  const gases = gasAlerts(row);
  const level = band === 'Critical' ? 'Critical' : 'Normal';
  const reasons = [];
  if (level === 'Critical') {
    reasons.push(`Odour Index ${index} (Hygiene Score ${round2(hygieneScore(voc))}%)`);
    gases.forEach((a) => reasons.push(`${a.gas} ${round2(a.value)} ppm over ${a.threshold} ppm limit`));
  }
  return { level, band, index, hygiene: round2(hygieneScore(voc)), gases, reasons, nh3: g.nh3, ch4: g.ch4, h2s: g.h2s, voc };
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
  VOC_CRITICAL,
  VOC_MEDIUM,
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
