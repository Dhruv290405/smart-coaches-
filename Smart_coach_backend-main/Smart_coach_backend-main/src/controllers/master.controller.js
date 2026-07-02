const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const {
  zoneModel,
  divisionModel,
  regionModel,
  roleModel
} = require('../models/master.model');

const models = {
  'zones': zoneModel,
  'divisions': divisionModel,
  'regions': regionModel,
  'roles': roleModel,
};

const masterController = {
  async list(req, res, next) {
    try {
      const { type } = req.params;
      const { zone_id, division_id } = req.query;

      const model = models[type];
      if (!model) {
        return errorResponse(res, 'Invalid master table type', 400);
      }

      // Validation
      if (type === 'divisions' && (zone_id === undefined || zone_id === '')) {
        return errorResponse(res, 'zone_id is required when type is divisions', 400);
      }

      if (type === 'regions' && (division_id === undefined || division_id === '')) {
        return errorResponse(res, 'division_id is required when type is regions', 400);
      }

      let filter = {};
      let orFilter = {};

      if (type === 'divisions') {
        filter.zone_id = parseInt(zone_id);
      } else if (type === 'regions') {
        filter.division_id = parseInt(division_id);
      }

      const [items, total] = await Promise.all([
        model.getAllActive(filter, orFilter),
        model.getActiveCount(filter) // optional count logic
      ]);

      return successResponse(res, 'Items retrieved successfully', {
        items,
      });
    } catch (error) {
      next(error);
    }
  },


  // Create a new item in a master table
  async create(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { type } = req.params;
      const model = models[type];

      if (!model) {
        return errorResponse(res, 'Invalid master table type', 400);
      }

      const newItem = await model.create(req.body);
      return successResponse(res, 'Item created successfully', newItem, 201);
    } catch (error) {
      next(error);
    }
  },

  // Toggle active status of an item
  async toggleStatus(req, res, next) {
    try {
      const { type, id } = req.params;
      const model = models[type];

      if (!model) {
        return errorResponse(res, 'Invalid master table type', 400);
      }

      const success = await model.toggleStatus(id);
      if (!success) {
        return errorResponse(res, 'Item not found', 404);
      }

      return successResponse(res, 'Status updated successfully');
    } catch (error) {
      next(error);
    }
  }
};

module.exports = masterController;
