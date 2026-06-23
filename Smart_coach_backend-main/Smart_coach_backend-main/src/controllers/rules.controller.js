const rulesModel = require('../models/rules.model');
const { successResponse, errorResponse } = require('../utils/response');

const rulesController = {
    async createRule(req, res, next) {
        try {
            const {
                rule_name,
                evaluation_frequency,
                evaluation_unit,
                device_ids = [],
                sensor_type_ids = [],
                conditions = [],
                is_active
            } = req.body;

            const created_by = req.user.user_id;

            if (!rule_name) {
                return errorResponse(res, 'Rule name and at least one condition are required.', 400);
            }

            const ruleId = await rulesModel.createRule({
                rule_name,
                evaluation_frequency,
                evaluation_unit,
                device_ids,
                sensor_type_ids,
                conditions,
                created_by,
                is_active
            });

            return successResponse(res, 'Rule created successfully', { rule_id: ruleId }, 201);
        } catch (error) {
            next(error);
        }
    },

    async getRuleById(req, res, next) {
        try {
            const { id } = req.params;
            const rule = await rulesModel.getRuleDetailsById(id);
            if (!rule) {
                return errorResponse(res, 'Rule not found', 404);
            }
            return successResponse(res, 'Rule fetched successfully', rule);
        } catch (error) {
            next(error);
        }
    },

    async getAllRules(req, res, next) {
        try {
            const rules = await rulesModel.getAllRules();
            return successResponse(res, 'All rules fetched successfully', rules);
        } catch (error) {
            next(error);
        }
    },

    async updateRule(req, res, next) {
        try {
            const { id } = req.params;
            const updated_by = req.user.user_id;
            const {
                rule_name,
                evaluation_frequency,
                evaluation_unit,
                device_ids = [],
                sensor_type_ids = [],
                conditions = [],
                is_active
            } = req.body;

            if (!rule_name) {
                return errorResponse(res, 'Rule name and conditions required', 400);
            }

            const updated = await rulesModel.updateRule(id, {
                rule_name,
                evaluation_frequency,
                evaluation_unit,
                device_ids,
                sensor_type_ids,
                conditions,
                updated_by,
                is_active
            });

            return successResponse(res, 'Rule updated successfully', { rule_id: updated }, 200);
        } catch (error) {
            next(error);
        }
    },

    async deleteRule(req, res, next) {
        try {
            const { id } = req.params;

            // Optional: check if rule exists
            const rule = await rulesModel.getRuleDetailsById(id);
            if (!rule) {
                return errorResponse(res, 'Rule not found', 404);
            }

            await rulesModel.deleteRule(id);

            return successResponse(res, 'Rule deleted successfully', 204);
        } catch (error) {
            next(error);
        }
    },

    async getAllAlertTypes(req, res, next) {
        try {
            const alertTypes = await rulesModel.getAllAlertTypes();
            return successResponse(res, 'Alert types fetched successfully', alertTypes);
        } catch (error) {
            next(error);
        }
    }

};

module.exports = rulesController;
