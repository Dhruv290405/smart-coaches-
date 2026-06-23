const { successResponse, errorResponse } = require('../utils/response');
const rolesModel = require('../models/roles.model');

const rolesController = {
  async list(req, res, next) {
    try {
      const { zone_id, division_id, region_id, train_ids } = req.query;

      if (
        zone_id === undefined ||
        division_id === undefined ||
        region_id === undefined
      ) {
        return errorResponse(res, 'Missing required query parameters', 400);
      }

      const parsedZoneId = parseInt(zone_id);
      const parsedDivisionId = parseInt(division_id);
      const parsedRegionId = region_id
        .split(',')
        .map(id => parseInt(id.trim()))
        .filter(id => !isNaN(id));


      let parsedTrainId = [];
      if (train_ids !== undefined) {
        parsedTrainId = train_ids
          .split(',')
          .map(id => parseInt(id.trim()))
          .filter(id => !isNaN(id));
      }

      const items = await rolesModel.getDefaultList(
        parsedZoneId,
        parsedDivisionId,
        parsedRegionId,
        parsedTrainId
      );

      return successResponse(res, 'Items retrieved successfully', { items });
    } catch (error) {
      next(error);
    }
  },
  async getRoleList(req, res, next) {
    try {
      const roles = await rolesModel.getAllRoles();
      return successResponse(res, 'Roles fetched successfully', roles);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = rolesController;
