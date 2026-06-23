const stationModel = require('../models/stations.model');
const { successResponse, errorResponse } = require('../utils/response');

const regionsController = {
    async getAllStations(req, res, next) {
        try {
            const stations = await stationModel.getAllStations()
            return successResponse(res, 'Stations retrieved successfully', { stations });
        } catch (error) {
            next(error);
        }
    }
};

module.exports = regionsController;
