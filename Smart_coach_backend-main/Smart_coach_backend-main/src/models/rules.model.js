const { toMySQLDatetime } = require('../middleware/datetime');
const { pool } = require('../config/db');
const BaseModel = require('./base.model');

class RulesModel extends BaseModel {
    constructor() {
        super('rule_master');
    }

    async createRule(data) {
        const conn = await pool.getConnection();
        try {
            await conn.beginTransaction();

            const created_at = toMySQLDatetime(new Date());

            // 1. Insert into rule_master
            const [ruleResult] = await conn.query(
                `INSERT INTO rule_master (rule_name, evaluation_frequency, evaluation_unit, created_by, created_at, is_active)
         VALUES (?, ?, ?, ?, ?, ?)`,
                [data.rule_name, data.evaluation_frequency, data.evaluation_unit, data.created_by, created_at, data.is_active]
            );
            const ruleId = ruleResult.insertId;

            // 2. Insert rule_device_mapping
            if (data.device_ids.length > 0) {
                const deviceValues = data.device_ids.map(deviceId => [ruleId, deviceId, data.created_by, created_at]);
                await conn.query(
                    `INSERT INTO rule_device_mapping (rule_id, device_id, created_by, created_at) VALUES ?`,
                    [deviceValues]
                );
            }

            // 3. Insert rule_sensor_mapping
            if (data.sensor_type_ids.length > 0) {
                const sensorValues = data.sensor_type_ids.map(sensorId => [ruleId, sensorId, data.created_by, created_at]);
                await conn.query(
                    `INSERT INTO rule_sensor_mapping (rule_id, sensor_type_id, created_by, created_at) VALUES ?`,
                    [sensorValues]
                );
            }

            // 4. Insert rule_condition_master and sub-conditions
            for (const condition of data.conditions) {
                const [condResult] = await conn.query(
                    `INSERT INTO rule_condition_master (
             rule_id, value_type_id, value_format, connector, si_unit_id, alert_type_id,
             alert_message_template, created_by, created_at
           ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                    [
                        ruleId,
                        condition.value_type_id,
                        condition.value_format,
                        condition.connector || 'NONE',
                        condition.si_unit_id || null,
                        condition.alert_type_id,
                        JSON.stringify(condition.alert_message_template),
                        data.created_by,
                        created_at
                    ]
                );

                const conditionId = condResult.insertId;

                const subValues = condition.sub_conditions.map(sc => [
                    conditionId,
                    sc.operator,
                    sc.threshold_value,
                    sc.sort_order || 1
                ]);

                await conn.query(
                    `INSERT INTO rule_sub_condition (
             condition_id, operator, threshold_value, sort_order
           ) VALUES ?`,
                    [subValues]
                );
            }

            await conn.commit();
            return ruleId;
        } catch (error) {
            await conn.rollback();
            throw new Error('Failed to create rule: ' + error.message);
        } finally {
            conn.release();
        }
    }

    async getRuleDetailsById(ruleId) {
        // 1. Get rule
        const [[rule]] = await this.pool.query(
            `SELECT 
                rm.rule_id,
                rm.rule_name,
                rm.evaluation_frequency,
                rm.evaluation_unit,
                rm.is_active,
                rm.created_at,
                rm.updated_at,
                rm.created_by,
                u1.first_name AS created_by_user,
                rm.updated_by,
                u2.first_name AS updated_by_user
                FROM rule_master rm
                LEFT JOIN user_master u1 ON rm.created_by = u1.user_id
                LEFT JOIN user_master u2 ON rm.updated_by = u2.user_id
                WHERE rm.rule_id = ?`,
            [ruleId]
        );

        if (!rule) return null;

        // 2. Devices
        const [deviceRows] = await this.pool.query(
            `SELECT dm.device_id, dm.device_unique_id, dm.full_name AS name
     FROM rule_device_mapping rdm
     JOIN device_master dm ON rdm.device_id = dm.device_id
     WHERE rdm.rule_id = ?`,
            [ruleId]
        );

        // 3. Sensors
        const [sensorRows] = await this.pool.query(
            `SELECT sm.sensor_type_id, sm.name
     FROM rule_sensor_mapping rsm
     JOIN sensor_master sm ON rsm.sensor_type_id = sm.sensor_type_id
     WHERE rsm.rule_id = ?`,
            [ruleId]
        );

        // 4. Conditions with joins
        const [conditionRows] = await this.pool.query(
            `SELECT rc.condition_id, rc.rule_id, rc.value_type_id, rc.value_format, rc.connector, rc.alert_message_template,
            vtm.name AS value_type, um.unit_id, um.unit AS unit, atm.alert_type_id, atm.alert_type_name AS alert_type
     FROM rule_condition_master rc
     JOIN value_type_master vtm ON rc.value_type_id = vtm.value_type_id
     LEFT JOIN unit_master um ON rc.si_unit_id = um.unit_id
     JOIN alert_type_master atm ON rc.alert_type_id = atm.alert_type_id
     WHERE rc.rule_id = ?`,
            [ruleId]
        );

        const conditionIds = conditionRows.map(c => c.condition_id);

        // 5. Sub-conditions
        let subMap = {};
        if (conditionIds.length > 0) {
            const [subRows] = await this.pool.query(
                `SELECT * FROM rule_sub_condition WHERE condition_id IN (?) ORDER BY sort_order`,
                [conditionIds]
            );
            subRows.forEach(sc => {
                if (!subMap[sc.condition_id]) subMap[sc.condition_id] = [];
                subMap[sc.condition_id].push({
                    operator: sc.operator,
                    threshold_value: sc.threshold_value,
                    sort_order: sc.sort_order
                });
            });
        }

        // Merge sub-conditions into conditions
        const conditions = conditionRows.map(c => ({
            condition_id: c.condition_id,
            value_type: c.value_type,
            value_type_id: c.value_type_id,
            value_format: c.value_format,
            connector: c.connector,
            unit_id: c.unit_id,
            unit: c.unit,
            alert_type_id: c.alert_type_id,
            alert_type: c.alert_type,
            alert_message_template: JSON.parse(c.alert_message_template),
            sub_conditions: subMap[c.condition_id] || []
        }));

        return {
            rule_id: rule.rule_id,
            rule_name: rule.rule_name,
            evaluation_frequency: rule.evaluation_frequency,
            evaluation_unit: rule.evaluation_unit,
            is_active: Boolean(rule.is_active),
            created_at: rule.created_at,
            updated_at: rule.updated_at,
            created_by: rule.created_by_user,
            updated_by: rule.updated_by_user,
            devices: deviceRows,
            sensor_types: sensorRows,
            conditions
        };
    }

    async getAllRules() {
        const [rules] = await this.pool.query(
            `SELECT 
      rm.rule_id,
      rm.rule_name,
        rm.evaluation_frequency,
        rm.evaluation_unit,
        rm.is_active,
      rm.created_at,
      rm.updated_at,
      rm.created_by,
      u1.first_name AS created_by_user,
      rm.updated_by,
      u2.first_name AS updated_by_user
     FROM rule_master rm
     LEFT JOIN user_master u1 ON rm.created_by = u1.user_id
     LEFT JOIN user_master u2 ON rm.updated_by = u2.user_id
     ORDER BY rm.created_at DESC`
        );

        const detailedRules = [];

        for (const rule of rules) {
            // 1. Devices
            const [deviceRows] = await this.pool.query(
                `SELECT dm.device_id, dm.device_unique_id, dm.full_name AS name
       FROM rule_device_mapping rdm
       JOIN device_master dm ON rdm.device_id = dm.device_id
       WHERE rdm.rule_id = ?`,
                [rule.rule_id]
            );

            // 2. Sensors
            const [sensorRows] = await this.pool.query(
                `SELECT sm.sensor_type_id, sm.name
       FROM rule_sensor_mapping rsm
       JOIN sensor_master sm ON rsm.sensor_type_id = sm.sensor_type_id
       WHERE rsm.rule_id = ?`,
                [rule.rule_id]
            );

            // 3. Conditions
            const [conditionRows] = await this.pool.query(
                `SELECT rc.condition_id, rc.rule_id, rc.value_type_id, rc.value_format, rc.connector, rc.alert_message_template,
              vtm.name AS value_type, um.unit_id, um.unit AS unit, atm.alert_type_id, atm.alert_type_name AS alert_type
       FROM rule_condition_master rc
       JOIN value_type_master vtm ON rc.value_type_id = vtm.value_type_id
       LEFT JOIN unit_master um ON rc.si_unit_id = um.unit_id
       JOIN alert_type_master atm ON rc.alert_type_id = atm.alert_type_id
       WHERE rc.rule_id = ?`,
                [rule.rule_id]
            );

            const conditionIds = conditionRows.map(c => c.condition_id);

            let subMap = {};
            if (conditionIds.length > 0) {
                const [subRows] = await this.pool.query(
                    `SELECT * FROM rule_sub_condition WHERE condition_id IN (?) ORDER BY sort_order`,
                    [conditionIds]
                );
                subRows.forEach(sc => {
                    if (!subMap[sc.condition_id]) subMap[sc.condition_id] = [];
                    subMap[sc.condition_id].push({
                        operator: sc.operator,
                        threshold_value: sc.threshold_value,
                        sort_order: sc.sort_order,
                        connector: conditionRows.find(c => c.condition_id === sc.condition_id)?.connector || 'NONE'
                    });
                });
            }

            const conditions = conditionRows.map(c => {
                const subConditions = subMap[c.condition_id] || [];

                // 🧠 Build readable expression like: "(Temperature > 95 AND Temperature <= 120)"
                const parts = subConditions.map(sc => {
                    const expr = `${c.value_type} ${sc.operator} ${parseFloat(sc.threshold_value)}`;
                    return sc.connector === 'NONE' ? expr : `${expr} ${sc.connector}`;
                });

                // Merge into single string (remove trailing connector)
                const expression = parts.join(' ').replace(/\s(AND|OR)\s?$/, '');

                return {
                    condition_id: c.condition_id,
                    value_type: c.value_type,
                    value_type_id: c.value_type_id,
                    value_format: c.value_format,
                    connector: c.connector,
                    unit: c.unit,
                    unit_id: c.unit_id,
                    alert_type_id: c.alert_type_id,
                    alert_type: c.alert_type,
                    alert_message_template: JSON.parse(c.alert_message_template),
                    condition_expression: `(${expression})`,
                    sub_conditions: subConditions
                };
            });


            detailedRules.push({
                rule_id: rule.rule_id,
                rule_name: rule.rule_name,
                evaluation_frequency: rule.evaluation_frequency,
                evaluation_unit: rule.evaluation_unit,
                is_active: Boolean(rule.is_active),
                created_by: rule.created_by_user,
                updated_by: rule.updated_by_user,
                created_at: rule.created_at,
                updated_at: rule.updated_at,
                devices: deviceRows,
                sensor_types: sensorRows,
                conditions
            });
        }

        return detailedRules;
    }


    async updateRule(ruleId, data) {
        const conn = await this.pool.getConnection();
        try {
            await conn.beginTransaction();

            const updated_at = toMySQLDatetime(new Date());

            // 1. Update rule_master
            await conn.query(
                `UPDATE rule_master SET rule_name = ?, evaluation_frequency = ?, evaluation_unit = ?, updated_by = ?, updated_at = ?, is_active = ? WHERE rule_id = ?`,
                [data.rule_name, data.evaluation_frequency, data.evaluation_unit, data.updated_by, updated_at, data.is_active, ruleId]
            );

            // 2. Reset device and sensor mappings
            await conn.query(`DELETE FROM rule_device_mapping WHERE rule_id = ?`, [ruleId]);
            await conn.query(`DELETE FROM rule_sensor_mapping WHERE rule_id = ?`, [ruleId]);

            if (data.device_ids.length > 0) {
                const deviceValues = data.device_ids.map(id => [ruleId, id, data.updated_by, data.updated_by, updated_at]);
                await conn.query(
                    `INSERT INTO rule_device_mapping (rule_id, device_id, created_by, updated_by, updated_at, created_at) VALUES ?`,
                    [deviceValues.map(([rule_id, device_id, created_by, updated_by, ts]) => [rule_id, device_id, created_by, updated_by, ts, ts])]
                );
            }

            if (data.sensor_type_ids.length > 0) {
                const sensorValues = data.sensor_type_ids.map(id => [ruleId, id, data.updated_by, data.updated_by, updated_at]);
                await conn.query(
                    `INSERT INTO rule_sensor_mapping (rule_id, sensor_type_id, created_by, updated_by, updated_at, created_at) VALUES ?`,
                    [sensorValues.map(([rule_id, sensor_type_id, created_by, updated_by, ts]) => [rule_id, sensor_type_id, created_by, updated_by, ts, ts])]
                );
            }

            // 3. Delete existing conditions + subconditions
            const [oldConditions] = await conn.query(
                `SELECT condition_id FROM rule_condition_master WHERE rule_id = ?`,
                [ruleId]
            );
            const oldConditionIds = oldConditions.map(c => c.condition_id);

            if (oldConditionIds.length > 0) {
                await conn.query(`DELETE FROM rule_sub_condition WHERE condition_id IN (?)`, [oldConditionIds]);
            }
            await conn.query(`DELETE FROM rule_condition_master WHERE rule_id = ?`, [ruleId]);

            // 4. Insert updated conditions and sub-conditions
            for (const cond of data.conditions) {
                const [condRes] = await conn.query(
                    `INSERT INTO rule_condition_master (
          rule_id, value_type_id, value_format, connector, si_unit_id, alert_type_id,
          alert_message_template, created_by, updated_by, created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
                    [
                        ruleId,
                        cond.value_type_id,
                        cond.value_format,
                        cond.connector || 'NONE',
                        cond.si_unit_id || null,
                        cond.alert_type_id,
                        JSON.stringify(cond.alert_message_template),
                        data.updated_by,
                        data.updated_by,
                        updated_at,
                        updated_at
                    ]
                );
                const condId = condRes.insertId;

                const subValues = cond.sub_conditions.map(sc => [
                    condId,
                    sc.operator,
                    sc.threshold_value,
                    sc.sort_order || 1
                ]);

                await conn.query(
                    `INSERT INTO rule_sub_condition (
          condition_id, operator, threshold_value, sort_order
        ) VALUES ?`,
                    [subValues]
                );
            }

            await conn.commit();
            return ruleId;
        } catch (err) {
            await conn.rollback();
            throw new Error('Rule update failed: ' + err.message);
        } finally {
            conn.release();
        }
    }


    async deleteRule(ruleId) {
        const conn = await this.pool.getConnection();
        try {
            await conn.beginTransaction();

            // 1. Delete sub-conditions
            const [condRows] = await conn.query(
                `SELECT condition_id FROM rule_condition_master WHERE rule_id = ?`,
                [ruleId]
            );
            const conditionIds = condRows.map(c => c.condition_id);

            if (conditionIds.length > 0) {
                await conn.query(
                    `DELETE FROM rule_sub_condition WHERE condition_id IN (?)`,
                    [conditionIds]
                );
            }

            // 2. Delete conditions
            await conn.query(
                `DELETE FROM rule_condition_master WHERE rule_id = ?`,
                [ruleId]
            );

            // 3. Delete device mappings
            await conn.query(
                `DELETE FROM rule_device_mapping WHERE rule_id = ?`,
                [ruleId]
            );

            // 4. Delete sensor mappings
            await conn.query(
                `DELETE FROM rule_sensor_mapping WHERE rule_id = ?`,
                [ruleId]
            );

            // 5. Finally delete the rule itself
            await conn.query(
                `DELETE FROM rule_master WHERE rule_id = ?`,
                [ruleId]
            );

            await conn.commit();
        } catch (err) {
            await conn.rollback();
            throw new Error('Failed to delete rule: ' + err.message);
        } finally {
            conn.release();
        }
    }

    async getAllAlertTypes() {
        const [rows] = await this.pool.query(
            `SELECT alert_type_id, alert_type_name FROM alert_type_master ORDER BY alert_type_name`
        );
        return rows;
    }
}

module.exports = new RulesModel();
