/**
 * Sensor Hygiene — Weighted Odour Index (0 - 1000 scale)
 *
 *   Index = 0.3 x (NH3 / 100 x 1000) + 0.5 x (H2S / 100 x 1000) + 0.2 x (VOC / 1000 x 1000)
 *   Simplified: Index = 3 x NH3 + 5 x H2S + 0.2 x VOC
 *
 * Weights: NH3 0.3, H2S 0.5, VOC 0.2 (sum = 1). NH3 and H2S in ppm (0-100),
 * VOC in ppm (0-1000, device `voc_index`).
 * Example: NH3 20, H2S 10, VOC 300 -> 60 + 50 + 60 = 170 (Normal).
 *
 * Bands:  Normal 0-250 | Moderate 250-500 | Warning 500-950 | ALERT > 950
 * Bad odour alert (in-app + push + email + SMS) when Index > 950.
 *
 * Single source of truth for odour severity: alerts, API responses and
 * reports all use it. The app mirrors it in odour_model.dart (OdourIndex).
 */

const WEIGHTS = { nh3: 3, h2s: 5, voc: 0.2 };

const MODERATE = 250;
const WARNING = 500;
const ALERT = 950; // alert when index is strictly greater than this

const ALERT_THRESHOLD = ALERT;

function num(v) {
  const n = Number(v);
  return Number.isFinite(n) && n > 0 ? n : 0;
}

/** Accepts a raw DB/device row (any of the known column spellings). */
function computeOdourIndex(row = {}) {
  const nh3 = num(row.nh3_ppm ?? row.nh3);
  const h2s = num(row.h2s_ppm ?? row.h2s);
  const voc = num(row.voc_index ?? row.voc);
  const index = WEIGHTS.nh3 * nh3 + WEIGHTS.h2s * h2s + WEIGHTS.voc * voc;
  return Math.round(Math.min(1000, index) * 10) / 10;
}

/** Band for any value on the 0-1000 scale: Normal / Moderate / Warning / Alert. */
function bandFor(value) {
  const v = Number(value) || 0;
  if (v > ALERT) return 'Alert';
  if (v >= WARNING) return 'Warning';
  if (v >= MODERATE) return 'Moderate';
  return 'Normal';
}

function getOdourLevel(index) {
  const level = bandFor(index);
  return {
    level,
    label: level === 'Alert' ? 'Bad Odour Alert' : level === 'Normal' ? null : `${level} Odour`,
    severity: level === 'Alert' ? 'critical' : level === 'Normal' ? 'info' : 'warning',
    sendSms: level === 'Alert',
  };
}

function levelRank(level) {
  return ['Normal', 'Moderate', 'Warning', 'Alert'].indexOf(level);
}

/**
 * Single decision used for ALL odour notifications (in-app, push, email, SMS):
 *   Index > 950 -> 'Critical' (Bad Odour Alert) ; anything else -> 'Normal'.
 * Moderate / Warning are shown in the app only.
 */
function evaluateOdourReading(row = {}) {
  const nh3 = num(row.nh3_ppm ?? row.nh3);
  const h2s = num(row.h2s_ppm ?? row.h2s);
  const voc = num(row.voc_index ?? row.voc);
  const index = computeOdourIndex(row);
  const band = bandFor(index);
  const level = band === 'Alert' ? 'Critical' : 'Normal';
  const reasons = level === 'Critical' ? [`Odour Index ${index} (> ${ALERT})`] : [];
  return { level, band, index, reasons, nh3, h2s, voc };
}

function alertRank(level) {
  return ['Normal', 'Warning', 'Critical'].indexOf(level);
}

/**
 * PostgREST `or` filter returning a SUPERSET of rows whose index can exceed
 * ALERT (950). VOC contributes at most 0.2 x 1000 = 200, so 3*NH3 + 5*H2S must
 * exceed 750, which needs NH3 >= 125 or H2S >= 75 (if both were below, the sum
 * would be < 750). Callers must still apply computeOdourIndex().
 */
const ALERT_CANDIDATE_FILTER = 'nh3_ppm.gte.125,h2s_ppm.gte.75';

module.exports = {
  WEIGHTS,
  MODERATE,
  WARNING,
  ALERT,
  ALERT_THRESHOLD,
  ALERT_CANDIDATE_FILTER,
  computeOdourIndex,
  bandFor,
  getOdourLevel,
  levelRank,
  evaluateOdourReading,
  alertRank,
};
