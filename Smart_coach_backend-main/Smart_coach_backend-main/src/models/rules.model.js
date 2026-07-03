const supabaseAdmin = require('../config/supabaseAdmin');
const { toMySQLDatetime } = require('../middleware/datetime');
const BaseModel = require('./base.model');

class RulesModel extends BaseModel {
    constructor() {
        super('rule_master');
    }

    async createRule(data) {
        const created_at = toMySQLDatetime(new Date());

        const { data: ruleResult, error: ruleError } = await supabaseAdmin
            .from('rule_master')
            .insert([{
                rule_name: data.rule_name,
                evaluation_frequency: data.evaluation_frequency,
                evaluation_unit: data.evaluation_unit,
                created_by: data.created_by,
                created_at: created_at,
                is_active: data.is_active
            }])
            .select();
        if (ruleError) throw new Error('Failed to create rule: ' + ruleError.message);
        const ruleId = ruleResult[0].rule_id;

        if (data.device_ids.length > 0) {
            const deviceValues = data.device_ids.map(deviceId => ({
                rule_id: ruleId,
                device_id: deviceId,
                created_by: data.created_by,
                created_at: created_at
            }));
            const { error: deviceError } = await supabaseAdmin
                .from('rule_device_mapping')
                .insert(deviceValues);
            if (deviceError) throw new Error('Failed to create rule: ' + deviceError.message);
        }

        if (data.sensor_type_ids.length > 0) {
            const sensorValues = data.sensor_type_ids.map(sensorId => ({
                rule_id: ruleId,
                sensor_type_id: sensorId,
                created_by: data.created_by,
                created_at: created_at
            }));
            const { error: sensorError } = await supabaseAdmin
                .from('rule_sensor_mapping')
                .insert(sensorValues);
            if (sensorError) throw new Error('Failed to create rule: ' + sensorError.message);
        }

        for (const condition of data.conditions) {
            const { data: condResult, error: condError } = await supabaseAdmin
                .from('rule_condition_master')
                .insert([{
                    rule_id: ruleId,
                    value_type_id: condition.value_type_id,
                    value_format: condition.value_format,
                    connector: condition.connector || 'NONE',
                    si_unit_id: condition.si_unit_id || null,
                    alert_type_id: condition.alert_type_id,
                    alert_message_template: JSON.stringify(condition.alert_message_template),
                    created_by: data.created_by,
                    created_at: created_at
                }])
                .select();
            if (condError) throw new Error('Failed to create rule: ' + condError.message);

            const conditionId = condResult[0].condition_id;

            const subValues = condition.sub_conditions.map(sc => ({
                condition_id: conditionId,
                operator: sc.operator,
                threshold_value: sc.threshold_value,
                sort_order: sc.sort_order || 1
            }));

            const { error: subError } = await supabaseAdmin
                .from('rule_sub_condition')
                .insert(subValues);
            if (subError) throw new Error('Failed to create rule: ' + subError.message);
        }

        return ruleId;
    }

    async getRuleDetailsById(ruleId) {
        const { data: rules, error: err1 } = await supabaseAdmin
            .from('rule_master')
            .select('*')
            .eq('rule_id', ruleId);
        if (err1) throw err1;
        const rule = rules[0] || null;
        if (!rule) return null;

        let created_by_user = null;
        let updated_by_user = null;
        if (rule.created_by) {
            const { data: u1 } = await supabaseAdmin.from('user_master').select('first_name').eq('user_id', rule.created_by).single();
            if (u1) created_by_user = u1.first_name;
        }
        if (rule.updated_by) {
            const { data: u2 } = await supabaseAdmin.from('user_master').select('first_name').eq('user_id', rule.updated_by).single();
            if (u2) updated_by_user = u2.first_name;
        }

        const { data: devMappings } = await supabaseAdmin
            .from('rule_device_mapping')
            .select('device_id')
            .eq('rule_id', ruleId);
        let deviceRows = [];
        if (devMappings && devMappings.length > 0) {
            const ids = devMappings.map(d => d.device_id);
            const { data: devices } = await supabaseAdmin
                .from('device_master')
                .select('device_id, device_unique_id, full_name')
                .in('device_id', ids);
            if (devices) deviceRows = devices.map(d => ({ device_id: d.device_id, device_unique_id: d.device_unique_id, name: d.full_name }));
        }

        const { data: sensMappings } = await supabaseAdmin
            .from('rule_sensor_mapping')
            .select('sensor_type_id')
            .eq('rule_id', ruleId);
        let sensorRows = [];
        if (sensMappings && sensMappings.length > 0) {
            const ids = sensMappings.map(s => s.sensor_type_id);
            const { data: sensors } = await supabaseAdmin
                .from('sensor_master')
                .select('sensor_type_id, name')
                .in('sensor_type_id', ids);
            if (sensors) sensorRows = sensors;
        }

        const { data: condRows, error: condErr } = await supabaseAdmin
            .from('rule_condition_master')
            .select('*')
            .eq('rule_id', ruleId);
        if (condErr) throw condErr;

        const valueTypeIds = [...new Set((condRows || []).map(c => c.value_type_id).filter(Boolean))];
        const unitIds = [...new Set((condRows || []).map(c => c.si_unit_id).filter(Boolean))];
        const alertTypeIds = [...new Set((condRows || []).map(c => c.alert_type_id).filter(Boolean))];

        const [valueTypes, units, alertTypes] = await Promise.all([
            valueTypeIds.length > 0
                ? supabaseAdmin.from('value_type_master').select('value_type_id, name').in('value_type_id', valueTypeIds)
                : Promise.resolve({ data: [] }),
            unitIds.length > 0
                ? supabaseAdmin.from('unit_master').select('unit_id, unit').in('unit_id', unitIds)
                : Promise.resolve({ data: [] }),
            alertTypeIds.length > 0
                ? supabaseAdmin.from('alert_type_master').select('alert_type_id, alert_type_name').in('alert_type_id', alertTypeIds)
                : Promise.resolve({ data: [] })
        ]);

        const valueTypeMap = {};
        (valueTypes.data || []).forEach(v => { valueTypeMap[v.value_type_id] = v.name; });
        const unitMap = {};
        (units.data || []).forEach(u => { unitMap[u.unit_id] = u; });
        const alertTypeMap = {};
        (alertTypes.data || []).forEach(a => { alertTypeMap[a.alert_type_id] = a.alert_type_name; });

        const conditionRows = (condRows || []).map(c => ({
            condition_id: c.condition_id,
            rule_id: c.rule_id,
            value_type_id: c.value_type_id,
            value_format: c.value_format,
            connector: c.connector,
            alert_message_template: c.alert_message_template,
            value_type: valueTypeMap[c.value_type_id] || null,
            unit_id: (unitMap[c.si_unit_id] || {}).unit_id || null,
            unit: (unitMap[c.si_unit_id] || {}).unit || null,
            alert_type_id: c.alert_type_id,
            alert_type: alertTypeMap[c.alert_type_id] || null
        }));

        const conditionIds = conditionRows.map(c => c.condition_id);

        let subMap = {};
        if (conditionIds.length > 0) {
            const { data: subRows } = await supabaseAdmin
                .from('rule_sub_condition')
                .select('*')
                .in('condition_id', conditionIds)
                .order('sort_order');
            if (subRows) {
                subRows.forEach(sc => {
                    if (!subMap[sc.condition_id]) subMap[sc.condition_id] = [];
                    subMap[sc.condition_id].push({
                        operator: sc.operator,
                        threshold_value: sc.threshold_value,
                        sort_order: sc.sort_order
                    });
                });
            }
        }

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
            created_by: created_by_user,
            updated_by: updated_by_user,
            devices: deviceRows,
            sensor_types: sensorRows,
            conditions
        };
    }

    async getAllRules() {
        const { data: rules, error: rulesErr } = await supabaseAdmin
            .from('rule_master')
            .select('*')
            .order('created_at', { ascending: false });
        if (rulesErr) throw rulesErr;

        const detailedRules = [];

        for (const rule of rules) {
            let created_by_user = null;
            let updated_by_user = null;
            if (rule.created_by) {
                const { data: u1 } = await supabaseAdmin.from('user_master').select('first_name').eq('user_id', rule.created_by).single();
                if (u1) created_by_user = u1.first_name;
            }
            if (rule.updated_by) {
                const { data: u2 } = await supabaseAdmin.from('user_master').select('first_name').eq('user_id', rule.updated_by).single();
                if (u2) updated_by_user = u2.first_name;
            }

            const { data: devMappings } = await supabaseAdmin
                .from('rule_device_mapping')
                .select('device_id')
                .eq('rule_id', rule.rule_id);
            let deviceRows = [];
            if (devMappings && devMappings.length > 0) {
                const ids = devMappings.map(d => d.device_id);
                const { data: devices } = await supabaseAdmin
                    .from('device_master')
                    .select('device_id, device_unique_id, full_name')
                    .in('device_id', ids);
                if (devices) deviceRows = devices.map(d => ({ device_id: d.device_id, device_unique_id: d.device_unique_id, name: d.full_name }));
            }

            const { data: sensMappings } = await supabaseAdmin
                .from('rule_sensor_mapping')
                .select('sensor_type_id')
                .eq('rule_id', rule.rule_id);
            let sensorRows = [];
            if (sensMappings && sensMappings.length > 0) {
                const ids = sensMappings.map(s => s.sensor_type_id);
                const { data: sensors } = await supabaseAdmin
                    .from('sensor_master')
                    .select('sensor_type_id, name')
                    .in('sensor_type_id', ids);
                if (sensors) sensorRows = sensors;
            }

            const { data: condRows } = await supabaseAdmin
                .from('rule_condition_master')
                .select('*')
                .eq('rule_id', rule.rule_id);

            const valueTypeIds = [...new Set((condRows || []).map(c => c.value_type_id).filter(Boolean))];
            const unitIds = [...new Set((condRows || []).map(c => c.si_unit_id).filter(Boolean))];
            const alertTypeIds = [...new Set((condRows || []).map(c => c.alert_type_id).filter(Boolean))];

            const [valueTypes, units, alertTypes] = await Promise.all([
                valueTypeIds.length > 0
                    ? supabaseAdmin.from('value_type_master').select('value_type_id, name').in('value_type_id', valueTypeIds)
                    : Promise.resolve({ data: [] }),
                unitIds.length > 0
                    ? supabaseAdmin.from('unit_master').select('unit_id, unit').in('unit_id', unitIds)
                    : Promise.resolve({ data: [] }),
                alertTypeIds.length > 0
                    ? supabaseAdmin.from('alert_type_master').select('alert_type_id, alert_type_name').in('alert_type_id', alertTypeIds)
                    : Promise.resolve({ data: [] })
            ]);

            const valueTypeMap = {};
            (valueTypes.data || []).forEach(v => { valueTypeMap[v.value_type_id] = v.name; });
            const unitMap = {};
            (units.data || []).forEach(u => { unitMap[u.unit_id] = u; });
            const alertTypeMap = {};
            (alertTypes.data || []).forEach(a => { alertTypeMap[a.alert_type_id] = a.alert_type_name; });

            const conditionRows = (condRows || []).map(c => ({
                condition_id: c.condition_id,
                rule_id: c.rule_id,
                value_type_id: c.value_type_id,
                value_format: c.value_format,
                connector: c.connector,
                alert_message_template: c.alert_message_template,
                value_type: valueTypeMap[c.value_type_id] || null,
                unit_id: (unitMap[c.si_unit_id] || {}).unit_id || null,
                unit: (unitMap[c.si_unit_id] || {}).unit || null,
                alert_type_id: c.alert_type_id,
                alert_type: alertTypeMap[c.alert_type_id] || null
            }));

            const conditionIds = conditionRows.map(c => c.condition_id);

            let subMap = {};
            if (conditionIds.length > 0) {
                const { data: subRows } = await supabaseAdmin
                    .from('rule_sub_condition')
                    .select('*')
                    .in('condition_id', conditionIds)
                    .order('sort_order');
                if (subRows) {
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
            }

            const conditions = conditionRows.map(c => {
                const subConditions = subMap[c.condition_id] || [];

                const parts = subConditions.map(sc => {
                    const expr = `${c.value_type} ${sc.operator} ${parseFloat(sc.threshold_value)}`;
                    return sc.connector === 'NONE' ? expr : `${expr} ${sc.connector}`;
                });

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
                created_by: created_by_user,
                updated_by: updated_by_user,
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
        const updated_at = toMySQLDatetime(new Date());

        const { error: updateError } = await supabaseAdmin
            .from('rule_master')
            .update({
                rule_name: data.rule_name,
                evaluation_frequency: data.evaluation_frequency,
                evaluation_unit: data.evaluation_unit,
                updated_by: data.updated_by,
                updated_at: updated_at,
                is_active: data.is_active
            })
            .eq('rule_id', ruleId);
        if (updateError) throw new Error('Rule update failed: ' + updateError.message);

        await supabaseAdmin.from('rule_device_mapping').delete().eq('rule_id', ruleId);
        await supabaseAdmin.from('rule_sensor_mapping').delete().eq('rule_id', ruleId);

        if (data.device_ids.length > 0) {
            const deviceValues = data.device_ids.map(id => ({
                rule_id: ruleId,
                device_id: id,
                created_by: data.updated_by,
                updated_by: data.updated_by,
                updated_at: updated_at,
                created_at: updated_at
            }));
            const { error: insDevError } = await supabaseAdmin
                .from('rule_device_mapping')
                .insert(deviceValues);
            if (insDevError) throw new Error('Rule update failed: ' + insDevError.message);
        }

        if (data.sensor_type_ids.length > 0) {
            const sensorValues = data.sensor_type_ids.map(id => ({
                rule_id: ruleId,
                sensor_type_id: id,
                created_by: data.updated_by,
                updated_by: data.updated_by,
                updated_at: updated_at,
                created_at: updated_at
            }));
            const { error: insSensError } = await supabaseAdmin
                .from('rule_sensor_mapping')
                .insert(sensorValues);
            if (insSensError) throw new Error('Rule update failed: ' + insSensError.message);
        }

        const { data: oldConditions } = await supabaseAdmin
            .from('rule_condition_master')
            .select('condition_id')
            .eq('rule_id', ruleId);
        const oldConditionIds = (oldConditions || []).map(c => c.condition_id);

        if (oldConditionIds.length > 0) {
            await supabaseAdmin.from('rule_sub_condition').delete().in('condition_id', oldConditionIds);
        }
        await supabaseAdmin.from('rule_condition_master').delete().eq('rule_id', ruleId);

        for (const cond of data.conditions) {
            const { data: condRes, error: insCondError } = await supabaseAdmin
                .from('rule_condition_master')
                .insert([{
                    rule_id: ruleId,
                    value_type_id: cond.value_type_id,
                    value_format: cond.value_format,
                    connector: cond.connector || 'NONE',
                    si_unit_id: cond.si_unit_id || null,
                    alert_type_id: cond.alert_type_id,
                    alert_message_template: JSON.stringify(cond.alert_message_template),
                    created_by: data.updated_by,
                    updated_by: data.updated_by,
                    created_at: updated_at,
                    updated_at: updated_at
                }])
                .select();
            if (insCondError) throw new Error('Rule update failed: ' + insCondError.message);
            const condId = condRes[0].condition_id;

            const subValues = cond.sub_conditions.map(sc => ({
                condition_id: condId,
                operator: sc.operator,
                threshold_value: sc.threshold_value,
                sort_order: sc.sort_order || 1
            }));

            const { error: insSubError } = await supabaseAdmin
                .from('rule_sub_condition')
                .insert(subValues);
            if (insSubError) throw new Error('Rule update failed: ' + insSubError.message);
        }

        return ruleId;
    }

    async deleteRule(ruleId) {
        const { data: condRows } = await supabaseAdmin
            .from('rule_condition_master')
            .select('condition_id')
            .eq('rule_id', ruleId);
        const conditionIds = (condRows || []).map(c => c.condition_id);

        if (conditionIds.length > 0) {
            await supabaseAdmin.from('rule_sub_condition').delete().in('condition_id', conditionIds);
        }

        await supabaseAdmin.from('rule_condition_master').delete().eq('rule_id', ruleId);
        await supabaseAdmin.from('rule_device_mapping').delete().eq('rule_id', ruleId);
        await supabaseAdmin.from('rule_sensor_mapping').delete().eq('rule_id', ruleId);

        const { error } = await supabaseAdmin.from('rule_master').delete().eq('rule_id', ruleId);
        if (error) throw new Error('Failed to delete rule: ' + error.message);
    }

    async getAllAlertTypes() {
        const { data: rows, error } = await supabaseAdmin
            .from('alert_type_master')
            .select('alert_type_id, alert_type_name')
            .order('alert_type_name');
        if (error) throw error;
        return rows;
    }
}

module.exports = new RulesModel();
