/**
 * BODR – Bad Odour Detection System: alert logic & mathematics
 * (spec: "Bad Odour mathematic logic" document).
 *
 * 1. Individual gas alerts (each gas checked independently, strictly greater than):
 *      NH3 > 10 ppm  -> CRITICAL
 *      CH4 > 15 ppm  -> CRITICAL
 *      H2S > 5 ppm   -> CRITICAL
 *
 * 2. Combined Odour Index:
 *      Index = [(NH3/10 + CH4/15 + H2S/5) / 3] x 100   (rounded to 2 dp)
 *    A missing / invalid gas reading counts as 0.
 *
 * 3. Combined Index classification:
 *      > 500        -> CRITICAL
 *      250 – 500    -> HIGH     (inclusive)
 *      90 – <250    -> MEDIUM
 *      < 90         -> no combined-index alert ("Normal")
 *
 * 4. VOC (voc_index) is kept as the original sensor value; it is NOT part of
 *    the index and does not raise notifications.
 *
 * Notifications (in-app + push + email + SMS) are sent for CRITICAL only:
 * any individual gas CRITICAL, or combined Index > 500. HIGH / MEDIUM are
 * shown in the app and reports. The app mirrors this in odour_model.dart.
 */

const GAS_THRESHOLDS = { nh3: 10, ch4: 15, h2s: 5 };

const MEDIUM = 90;
const HIGH = 250;
const CRITICAL = 500; // critical when index is strictly greater than this

const ALERT_THRESHOLD = CRITICAL;

const LEVELS = ['Normal', 'Medium', 'High', 'Critical'];

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

/** Combined-index level: Normal / Medium / High / Critical. */
function bandFor(value) {
  const v = Number(value) || 0;
  if (v > CRITICAL) return 'Critical';
  if (v >= HIGH) return 'High';
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

/**
 * Overall level of one reading = worst of (combined index level, gas alerts).
 * Any gas above its threshold makes the reading CRITICAL.
 */
function overallLevel(row = {}) {
  const index = computeOdourIndex(row);
  const band = bandFor(index);
  return gasAlerts(row).length > 0 ? 'Critical' : band;
}

/**
 * Single decision used for ALL odour notifications (in-app, push, email, SMS):
 * 'Critical' if any gas > threshold or Index > 500, otherwise 'Normal'.
 */
function evaluateOdourReading(row = {}) {
  const g = gasValues(row);
  const voc = num(row.voc_index ?? row.voc);
  const index = computeOdourIndex(row);
  const band = bandFor(index);
  const gases = gasAlerts(row);
  const reasons = gases.map((a) => `${a.gas} ${round2(a.value)} ppm > ${a.threshold} ppm`);
  if (band === 'Critical') reasons.push(`Combined Odour Index ${index} > ${CRITICAL}`);
  const level = reasons.length > 0 ? 'Critical' : 'Normal';
  return { level, band, index, gases, reasons, nh3: g.nh3, ch4: g.ch4, h2s: g.h2s, voc };
}

function alertRank(level) {
  return ['Normal', 'Critical'].indexOf(level);
}

/**
 * PostgREST `or` filter for rows that are CRITICAL. Index > 500 needs the ratio
 * sum > 15, so at least one ratio > 5, i.e. that gas is already above its
 * threshold — this filter is therefore exact for CRITICAL readings.
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
  getOdourLevel,
  levelRank,
  evaluateOdourReading,
  alertRank,
};
