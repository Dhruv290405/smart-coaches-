const { successResponse, errorResponse } = require("../utils/response");
const coachModel = require("../models/coach.model");
const { toMySQLDatetime } = require("../middleware/datetime");

const coachController = {
  // Create a new coach
  async createCoach(req, res, next) {
    try {
      const {
        entity_type,
        coach_unique_id,
        coach_display_id,
        make_of_coach,
        type_of_coach,
        manufacturing_year,
        no_of_master_module,
        coach_status,
      } = req.body;
      const created_by = req.user.user_id;
      const created_date = toMySQLDatetime();
      const newCoach = await coachModel.createCoach({
        entity_type,
        coach_unique_id,
        coach_display_id, // Passed to model
        make_of_coach,
        type_of_coach,
        manufacturing_year,
        no_of_master_module,
        coach_status,
        created_date,
        created_by,
      });

      return successResponse(res, "Coach created successfully", newCoach, 201);
    } catch (error) {
      if (
        error.message.includes("Coach with unique ID") ||
        error.message.includes("already exists")
      ) {
        return errorResponse(res, error.message, 400); // or 409 Conflict
      }
      next(error);
    }
  },

  async updateCoach(req, res, next) {
    try {
      const {
        entity_type,
        coach_unique_id,
        coach_display_id,
        make_of_coach,
        type_of_coach,
        manufacturing_year,
        position,
        no_of_master_module,
        coach_status,
      } = req.body;
      const coach_id = req.params.coach_id;
      const updated_by = req.user.user_id;

      const result = await coachModel.updateCoach({
        coach_id,
        entity_type,
        coach_unique_id,
        coach_display_id,
        make_of_coach,
        type_of_coach,
        manufacturing_year,
        position,
        no_of_master_module,
        coach_status,
        updated_by
      });

      return successResponse(res, "Coach updated successfully", null, 200);
    } catch (error) {
      if (error.message.includes("not found")) {
        return errorResponse(res, error.message, 404);
      }
      next(error);
    }
  },

  async deleteCoach(req, res, next) {
    try {
      const coach_id = req.params.coach_id;

      const result = await coachModel.deleteCoach(coach_id);

      if (!result) {
        return errorResponse(res, `Coach with ID "${coach_id}" not found.`, 404);
      }

      return successResponse(res, "Coach deleted successfully", null, 200);
    } catch (error) {
      next(error);
    }
  },


  async getUnmappedCoaches(req, res, next) {
    try {
      const coaches = await coachModel.findUnmappedCoaches();

      if (!coaches || coaches.length === 0) {
        return successResponse(res, "No unmapped coaches found.", []);
      }
      const updatedCoaches = coaches.map(coach => ({
        ...coach,
        created_date: coach.created_date ? new Date(coach.created_date).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata', hour12: true }) : null,
      }));

      return successResponse(
        res,
        "Unmapped coaches retrieved successfully.",
        coaches
      );
    } catch (error) {
      next(error);
    }
  },

  async getAllCoaches(req, res, next) {
    try {
      const coaches = await coachModel.getAllCoachesWithDetails();

      if (!coaches || coaches.length === 0) {
        return successResponse(res, "No coaches found.", []);
      }
      const updatedCoaches = coaches.map(coach => ({
        ...coach,
        created_date: coach.created_date ? new Date(coach.created_date).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata', hour12: true }) : null,
        updated_date: coach.updated_date ? new Date(coach.updated_date).toLocaleString('en-IN', { timeZone: 'Asia/Kolkata', hour12: true }) : null,
      }));


      return successResponse(res, "coaches retrieved successfully.", updatedCoaches);
    } catch (error) {
      next(error);
    }
  },

  async getCoachForTrain(req, res, next) {
    try {
      const { train_id } = req.query;

      if (!train_id) {
        return errorResponse(res, "train_id is required", 400);
      }

      const coach = await coachModel.getCoachForTrain(train_id);

      if (!coach || coach.length === 0) {
        return successResponse(res, "No coach found for the given train.", []);
      }

      return successResponse(res, "Coach retrieved successfully.", coach);
    } catch (error) {
      next(error);
    }
  },

  async getCoachById(req, res, next) {
    try {
      const { id } = req.params;
      const { data: coach, error } = await require('../config/supabaseAdmin')
        .from('coach_master')
        .select('*')
        .eq('coach_id', id)
        .single();

      if (error || !coach) {
        return errorResponse(res, `Coach with ID "${id}" not found.`, 404);
      }

      return successResponse(res, "Coach retrieved successfully.", coach);
    } catch (error) {
      next(error);
    }
  },
};

module.exports = coachController;