
const { successResponse } = require('../utils/response');
const coach_typeModel = require('../models/coach_type.model.js');

const coachTypeController = {
    // Register a new user
    async getAllCoachType(req, res, next) {
        try {
          const coaches = await coach_typeModel.getAllCoachType();
    
          if (!coaches || coaches.length === 0) {
            return successResponse(res, "No coaches found.", []);
          }
    
          return successResponse(res, "coaches retrieved successfully.", coaches);
        } catch (error) {
          next(error);
        }
      },
  }
  
  module.exports = coachTypeController;