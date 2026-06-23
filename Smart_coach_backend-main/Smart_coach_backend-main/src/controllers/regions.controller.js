const regionsModel = require('../models/regions.model');
const { successResponse, errorResponse } = require('../utils/response');

const regionsController = {
    async getAllRegions(req, res, next) {
        try {
            const regions = await regionsModel.getAllRegions()
            return successResponse(res, 'Regions retrieved successfully', { regions });
        } catch (error) {
            next(error);
        }
    }
};

module.exports = regionsController;
