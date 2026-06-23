const { successResponse, errorResponse } = require('../utils/response');
const coach_makeModel = require('../models/coach_make.model.js');

const coachMakeController = {
    // Register a new user
    async getAllCoachMake(req, res, next) {
        try {
          const coaches = await coach_makeModel.getAllCoachMake();
    
          if (!coaches || coaches.length === 0) {
            return successResponse(res, "No coaches found.", []);
          }
    
          return successResponse(res, "coaches retrieved successfully.", coaches);
        } catch (error) {
          next(error);
        }
      },
  }
  
  module.exports = coachMakeController;