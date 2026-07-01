const { insertIoTData, getWaterLevelData, getWaterLevelDataForCoach,
  findRulesForSensor, getConditionsForRule, getSubConditionsForCondition
} = require('../models/iot_water_level.model');
const { evaluateRule } = require('../utils/ruleEvaluator');
const { successResponse, errorResponse } = require('../utils/response');
const { sendPushNotification } = require("../utils/notificationService");
const supabaseAdmin = require('../config/supabaseAdmin');
const { get } = require('../..');
const { getAlerts } = require('./sensor.controller');

// const { io } = require('../socket');

// exports.addIoTData = async (req, res) => {
//   try {
//     const { sensor_id, water_level, timestamp } = req.query;

//     if (!sensor_id || water_level == null || timestamp == null) {
//       return res.status(400).json({ error: 'Missing required fields' });
//     }

//     const savedData = await insertIoTData({ sensor_id, water_level, timestamp });

//     // Emit to frontend
//     // io.emit('new-iot-data', savedData);

//     res.status(201).json({ message: 'IoT data saved', data: savedData });
//   } catch (err) {
//     console.error('Error saving IoT data:', err);
//     res.status(500).json({ error: 'Failed to save IoT data' });
//   }
// };

exports.addIoTData = async (req, res) => {
  try {
    const { sensor_id, water_level, timestamp } = req.query;

    if (!sensor_id || water_level == null || timestamp == null) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    const savedData = await insertIoTData({ sensor_id, water_level, timestamp });

    const rules = await findRulesForSensor(sensor_id);
    const matchedAlertTypes = new Set();

    for (const rule of rules) {
      const ruleId = rule.rule_id || rule.id || rule.ruleId;
      const conditions = await getConditionsForRule(ruleId);
      
      const structuredConditions = [];
      for (const condRow of conditions) {
        const condId = condRow.condition_id;
        const subconds = await getSubConditionsForCondition(condId);
        structuredConditions.push({
          condition_meta: condRow,
          subconditions: subconds
        });
      }

      const context = { water_level: Number(water_level), sensor_id };

      const result = evaluateRule(structuredConditions, context);

      console.log(`Rule ${ruleId} evaluation result:`, result);

      if (result.matched) {
        
        if (result.alert_type_ids && result.alert_type_ids.length) {
          result.alert_type_ids.forEach(id => matchedAlertTypes.add(id));
        } else {
          structuredConditions.forEach(sc => {
            if (sc.condition_meta && sc.condition_meta.alert_type_id) {
              matchedAlertTypes.add(sc.condition_meta.alert_type_id);
            }
          });
        }
      }
    }

    if (matchedAlertTypes.size > 0) {
      const alertTypeIds = Array.from(matchedAlertTypes);

      const alerts = await getAlertsByIds(alertTypeIds);

      let getUserFcmTokens = async (sensor_id) => {
        const { data: rows, error } = await supabaseAdmin
          .from('user_fcm_tokens')
          .select('fcm_token');

        if (error) throw error;
        return rows;
      };

      const userTokens = await getUserFcmTokens(sensor_id);

      for (const alert of alerts) {
        for (const token of userTokens) {
          await sendPushNotification(
            token.fcm_token,
            alert.alert_type_name,
            `${alert.description} (Sensor ID: ${sensor_id})`,
            { sensor_id, water_level });
        }
      }
    }

    res.status(201).json({
      message: 'IoT data saved',
      data: savedData,
      matched_alert_type_ids: Array.from(matchedAlertTypes)
    });
  } catch (err) {
    console.error('Error saving IoT data or evaluating rules:', err);
    res.status(500).json({ error: 'Failed to save IoT data or evaluate rules' });
  }
};

// Get alerts by IDs
async function getAlertsByIds(alertIds) {
  try {
    if (!Array.isArray(alertIds) || alertIds.length === 0) {
      throw new Error("alertIds must be a non-empty array");
    }

    const { data: rows, error } = await supabaseAdmin
      .from('alert_type_master')
      .select('alert_type_name, description')
      .in('alert_type_id', alertIds);

    if (error) throw error;
    return rows;
  } catch (error) {
    console.error("Error in getAlertsByIds:", error);
    throw error;
  }
}

exports.getWaterLevelData = async (req, res) => {
  try {
    const { sensor_id } = req.query;

    if (!sensor_id) {
      return errorResponse(res, 'Missing sensor_id', 400);
    }

    const data = await getWaterLevelData(sensor_id);

    if (!data) {
      return errorResponse(res, 'No data found for this sensor', 404);
    }

    return successResponse(res, 'Sensor data retrieved successfully', data, 200);
  } catch (err) {
    console.error('Error fetching water level data:', err);
    return errorResponse(res, 'Failed to fetch water level data', 500);
  };
}

// New function to get data for a specific coach
exports.getDataForCoach = async (req, res) => {
  try {
    const { coach_id } = req.query;

    if (!coach_id) {
      return errorResponse(res, 'Missing coach_id', 400);
    }

    const data = await getWaterLevelDataForCoach(coach_id);

    if (!data) {
      return errorResponse(res, 'No data found for this coach', 404);
    }

    return successResponse(res, 'Coach data retrieved successfully', data, 200);
  } catch (err) {
    console.error('Error fetching coach data:', err);
    return errorResponse(res, 'Failed to fetch coach data', 500);
  }
};
