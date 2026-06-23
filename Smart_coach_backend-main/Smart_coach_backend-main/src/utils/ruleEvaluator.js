function evalSubcondition(subcond, context) {
  const op = (subcond.operator || '').toUpperCase().trim();
  const threshold = Number(subcond.threshold_value);
  const sensorValue = Number(context.water_level);

  if (isNaN(sensorValue) || isNaN(threshold)) {
    console.warn('Invalid numeric comparison:', { sensorValue, threshold });
    return false;
  }

  switch (op) {
    case '>':  return sensorValue > threshold;
    case '<':  return sensorValue < threshold;
    case '>=': return sensorValue >= threshold;
    case '<=': return sensorValue <= threshold;
    case '=':
    case '==': return sensorValue === threshold;
    case '!=':
    case '<>': return sensorValue !== threshold;
    default:
      console.warn('Unknown operator:', op);
      return false;
  }
}

function evaluateCondition(subconditions = [], context = {}) {
  if (!subconditions || subconditions.length === 0) return false;

  // ✅ Ensure subconditions are evaluated in sort_order
  const orderedSubs = [...subconditions].sort(
    (a, b) => (a.sort_order ?? 0) - (b.sort_order ?? 0)
  );

  // Default: all subconditions must be true (AND)
  for (const sc of orderedSubs) {
    const ok = evalSubcondition(sc, context);
    if (!ok) return false;
  }
  return true;
}

function evaluateRule(structuredConditions, context = {}) {
  if (!structuredConditions || structuredConditions.length === 0)
    return { matched: false, alert_type_ids: [] };

  let overall = null;
  const matchedAlertTypeIds = [];

  for (let i = 0; i < structuredConditions.length; i++) {
    const sc = structuredConditions[i];
    const condOk = evaluateCondition(sc.subconditions, context);

    if (condOk && sc.condition_meta?.alert_type_id) {
      matchedAlertTypeIds.push(sc.condition_meta.alert_type_id);
    }

    if (overall === null) {
      overall = condOk;
    } else {
      const conn = (sc.condition_meta?.connection || '').toUpperCase().trim();
      if (conn === 'AND') overall = overall && condOk;
      else if (conn === 'OR') overall = overall || condOk;
      else overall = overall && condOk; // default AND
    }
  }

  return { matched: !!overall, alert_type_ids: matchedAlertTypeIds };
}

module.exports = { evaluateRule };
