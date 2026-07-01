const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const trainModel = require('../models/train.model');
const coachModel = require('../models/coach.model');
const supabaseAdmin = require('../config/supabaseAdmin');
const userModel = require('../models/user.model');
const jwt = require('jsonwebtoken');

const trainController = {

  async createTrain(req, res, next) {
    try {
      const {
        train_number,
        train_name,
        origination_region_id,
        region_id,
        departure_station_id,
        destination_station_id,
        no_of_coaches,
        line,
        train_operator,
        engine_number,
        coaches = []
      } = req.body;

      const created_by = req.user.user_id;

      if (!train_number || !train_name || !region_id || coaches.length === 0) {
        return errorResponse(res, 'Train number, name, region, and at least one coach are required.', 400);
      }

      const train_id = await trainModel.createTrain({
        train_number,
        train_name,
        origination_region_id,
        region_id,
        departure_station_id,
        destination_station_id,
        no_of_coaches,
        line,
        train_operator,
        engine_number,
        created_by,
        coaches
      });

      return successResponse(res, 'Train created successfully', { train_id }, 201);
    } catch (err) {
      next(err);
    }
  },

  async getTrains(req, res, next) {
    try {
      const rows = await trainModel.getAllTrains();

      const trainsMap = new Map();

      for (const row of rows) {
        const {
          train_id,
          coach_id,
          coach_unique_id,
          coach_display_id,
          entity_type,
          is_active,
          position,
          ...trainData
        } = row;

        if (!trainsMap.has(train_id)) {
          trainsMap.set(train_id, {
            ...trainData,
            train_id,
            coaches: [],
          });
        }

        const train = trainsMap.get(train_id);

        if (coach_id) {
          train.coaches.push({
            coach_id,
            coach_unique_id,
            coach_display_id,
            entity_type,
            is_active,
            position,
          });
        }
      }

      const trains = Array.from(trainsMap.values());


      return successResponse(res, 'Trains fetched successfully', trains, 200);
    } catch (error) {
      next(error);
    }
  },

  async getAllTrains(req, res, next) {
    try {
      const { zone_id, division_id, region_id, search, targer_user_id } = req.query;

      // Get token from header
      const authHeader = req.header('Authorization');
      const token = authHeader?.split(' ')[1];
      let user_id = null;

      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your_jwt_secret');
        user_id = targer_user_id
      } catch (err) {
        if (err.name === 'TokenExpiredError') {
          console.log('Token expired:', err.message);
        }
        if (err.name === 'JsonWebTokenError') {
          console.log('Invalid token:', err.message);
        }
        console.log(`Error decoding token: ${err.message}`);
      }

      let regionIds = [];
      const onlyTrainIdMinusOne = region_id === '-1';

      const zoneId = parseInt(zone_id);
      const divisionId = parseInt(division_id);

      if (onlyTrainIdMinusOne) {
        regionIds = null;
      } else if (zoneId === -1 && region_id && region_id !== '-1') {
        regionIds = region_id
          .split(',')
          .map(rid => parseInt(rid.trim()))
          .filter(id => !isNaN(id));
      } else if (zoneId === -1) {
        regionIds = null;
      } else if (zoneId !== -1 && divisionId === -1) {
        const { data: divisions, error: divErr } = await supabaseAdmin
          .from('division_master')
          .select('division_id')
          .eq('zone_id', zoneId);
        if (divErr) throw divErr;
        const divisionIds = (divisions || []).map(d => d.division_id);
        if (divisionIds.length > 0) {
          const { data: regions, error: regErr } = await supabaseAdmin
            .from('region_master')
            .select('region_id')
            .in('division_id', divisionIds);
          if (regErr) throw regErr;
          regionIds = (regions || []).map(r => r.region_id);
        }
      } else if (zoneId !== -1 && divisionId !== -1) {
        if (region_id) {
          regionIds = region_id
            .split(',')
            .map(rid => parseInt(rid.trim()))
            .filter(id => !isNaN(id));
        }
      }

      const filters = {
        region_ids: regionIds,
        search,
        onlyTrainIdMinusOne,
      };

      const trains = await trainModel.getAll(filters);

      // ✅ Inject is_mapped flag if user is available
      let userMappedTrainIds = [];
      if (user_id) {
        console.log(`Fetching mapped trains for user ID: ${user_id}`);
        const userId = user_id;
        const { data: mappedRows, error: mapErr } = await supabaseAdmin
          .from('user_train_mapping')
          .select('train_id')
          .eq('user_id', userId);
        if (mapErr) throw mapErr;
        userMappedTrainIds = (mappedRows || []).map(row => row.train_id);
      }

      const enrichedTrains = trains.map(train => ({
        ...train,
        is_mapped: userMappedTrainIds.includes(train.train_id),
      }));

      return successResponse(res, 'Trains retrieved successfully', { trains: enrichedTrains });
    } catch (error) {
      next(error);
    }
  },

  async getTrainsMappedToUser(req, res, next) {
    try {
      const { user_id } = req.query
      const trains = await trainModel.getTrainsMappedToUser(user_id);
      return successResponse(res, 'Trains mapped to user retrieved successfully', { trains });
    } catch (error) {
      next(error);
    }
  },

  // update train user mapping
  async updateTrainUserMapping(req, res, next) {
    try {
      const { user_id, train_ids } = req.body;

      console.log(`Updating train user mapping for user ID: ${user_id} with trains: ${train_ids.join(', ')}`);

      // Update the train-user mapping
      await trainModel.updateTrainUserMapping(user_id, train_ids);

      return successResponse(res, 'Train user mapping updated successfully');
    } catch (error) {
      console.error('Error updating train user mapping:', error);
      next(error);
    }
  },

  // Get a single train by ID
  async getTrainById(req, res, next) {
    try {
      const { id } = req.params;
      const train = await trainModel.getById(id);

      if (!train) {
        return errorResponse(res, 'Train not found', 404);
      }

      // Get coaches for this train
      const coaches = await trainModel.getCoaches(id);

      return successResponse(res, 'Train retrieved successfully', {
        ...train,
        coaches
      });
    } catch (error) {
      next(error);
    }
  },

  // Update a train
  async updateTrain(req, res, next) {
    try {
      const train_id = req.params.id;
      const updated_by = req.user.user_id;
      const trainData = { ...req.body, train_id, updated_by };

      await trainModel.updateTrain(trainData);
      return successResponse(res, 'Train updated successfully', null, 200);
    } catch (error) {
      next(error);
    }
  },

  // Delete a train
  async deleteTrain(req, res, next) {
    try {
      const train_id = req.params.id;
      const updated_by = req.user.user_id;

      await trainModel.deleteTrain(train_id, updated_by);
      return successResponse(res, 'Train deleted successfully', null, 200);
    } catch (error) {
      next(error);
    }
  },

  async getTrainsForUsers(req, res, next) {
    try {
      const trains = await trainModel.getTrainsForUsers();
      return successResponse(res, 'Trains retrieved successfully', trains);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = trainController;
