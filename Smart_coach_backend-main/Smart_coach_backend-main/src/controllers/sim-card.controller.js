const { validationResult } = require('express-validator');
const { successResponse, errorResponse } = require('../utils/response');
const simCardModel = require('../models/sim-card.model');
const masterModuleModel = require('../models/master-module.model');
const carrierModel = require('../models/master.model').carrierModel;

const simCardController = {
  // Get all SIM cards with optional filters
  async getAllSimCards(req, res, next) {
    try {
      const { 
        page = 1, 
        limit = 10, 
        master_module_id, 
        carrier_id,
        status,
        search 
      } = req.query;

      const filters = {};
      if (master_module_id) filters.master_module_id = master_module_id;
      if (carrier_id) filters.carrier_id = carrier_id;
      if (status) filters.status = status;
      if (search) filters.search = search;

      const [simCards, total] = await Promise.all([
        simCardModel.getAll(filters, parseInt(page), parseInt(limit)),
        simCardModel.count(filters)
      ]);

      return successResponse(res, 'SIM cards retrieved successfully', {
        sim_cards: simCards,
        pagination: {
          total,
          page: parseInt(page),
          limit: parseInt(limit),
          totalPages: Math.ceil(total / limit)
        }
      });
    } catch (error) {
      next(error);
    }
  },

  // Get a single SIM card by ID
  async getSimCardById(req, res, next) {
    try {
      const { id } = req.params;
      const simCard = await simCardModel.getById(id);
      
      if (!simCard) {
        return errorResponse(res, 'SIM card not found', 404);
      }
      
      return successResponse(res, 'SIM card retrieved successfully', simCard);
    } catch (error) {
      next(error);
    }
  },

  // Create a new SIM card
  async createSimCard(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { 
        carrier_id, 
        master_module_id, 
        phone_number, 
        iccid, 
        imsi, 
        apn,
        pin1,
        puk1,
        pin2,
        puk2,
        plan_details,
        activation_date,
        expiry_date,
        status = 'ACTIVE',
        notes 
      } = req.body;

      // Check if carrier exists
      if (carrier_id) {
        const carrier = await carrierModel.getById(carrier_id);
        if (!carrier) {
          return errorResponse(res, 'Carrier not found', 404);
        }
      }

      // Check if master module exists and is not already assigned a SIM
      if (master_module_id) {
        const masterModule = await masterModuleModel.getById(master_module_id);
        if (!masterModule) {
          return errorResponse(res, 'Master module not found', 404);
        }

        const hasSim = await simCardModel.masterModuleHasSim(master_module_id);
        if (hasSim) {
          return errorResponse(
            res, 
            'This master module already has a SIM card assigned', 
            400
          );
        }
      }

      // Check if phone number already exists
      const phoneExists = await simCardModel.phoneNumberExists(phone_number);
      if (phoneExists) {
        return errorResponse(
          res, 
          'A SIM card with this phone number already exists', 
          400
        );
      }

      // Check if ICCID already exists
      const iccidExists = await simCardModel.iccidExists(iccid);
      if (iccidExists) {
        return errorResponse(
          res, 
          'A SIM card with this ICCID already exists', 
          400
        );
      }

      // Check if IMSI already exists if provided
      if (imsi) {
        const imsiExists = await simCardModel.imsiExists(imsi);
        if (imsiExists) {
          return errorResponse(
            res, 
            'A SIM card with this IMSI already exists', 
            400
          );
        }
      }

      const newSimCard = await simCardModel.create({
        carrier_id: carrier_id || null,
        master_module_id: master_module_id || null,
        phone_number,
        iccid,
        imsi: imsi || null,
        apn: apn || null,
        pin1: pin1 || null,
        puk1: puk1 || null,
        pin2: pin2 || null,
        puk2: puk2 || null,
        plan_details: plan_details || null,
        activation_date: activation_date || null,
        expiry_date: expiry_date || null,
        status,
        notes: notes || null
      });

      return successResponse(
        res,
        'SIM card created successfully',
        newSimCard,
        201
      );
    } catch (error) {
      next(error);
    }
  },

  // Update a SIM card
  async updateSimCard(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { id } = req.params;
      const { 
        carrier_id,
        master_module_id,
        phone_number,
        iccid,
        imsi,
        apn,
        pin1,
        puk1,
        pin2,
        puk2,
        plan_details,
        activation_date,
        expiry_date,
        status,
        notes
      } = req.body;

      // Check if SIM card exists
      const existingSimCard = await simCardModel.getById(id);
      if (!existingSimCard) {
        return errorResponse(res, 'SIM card not found', 404);
      }

      // If carrier_id is being updated, check if the new carrier exists
      if (carrier_id && carrier_id !== existingSimCard.carrier_id) {
        const carrier = await carrierModel.getById(carrier_id);
        if (!carrier) {
          return errorResponse(res, 'Carrier not found', 404);
        }
      }

      // If master_module_id is being updated, check if the new module exists and is available
      if (master_module_id !== undefined && master_module_id !== existingSimCard.master_module_id) {
        if (master_module_id) {
          const masterModule = await masterModuleModel.getById(master_module_id);
          if (!masterModule) {
            return errorResponse(res, 'Master module not found', 404);
          }

          const hasSim = await simCardModel.masterModuleHasSim(master_module_id, id);
          if (hasSim) {
            return errorResponse(
              res, 
              'This master module already has a SIM card assigned', 
              400
            );
          }
        }
      }

      // Check if phone number is being updated and already exists
      if (phone_number && phone_number !== existingSimCard.phone_number) {
        const phoneExists = await simCardModel.phoneNumberExists(phone_number, id);
        if (phoneExists) {
          return errorResponse(
            res, 
            'A SIM card with this phone number already exists', 
            400
          );
        }
      }

      // Check if ICCID is being updated and already exists
      if (iccid && iccid !== existingSimCard.iccid) {
        const iccidExists = await simCardModel.iccidExists(iccid, id);
        if (iccidExists) {
          return errorResponse(
            res, 
            'A SIM card with this ICCID already exists', 
            400
          );
        }
      }

      // Check if IMSI is being updated and already exists
      if (imsi !== undefined && imsi !== existingSimCard.imsi) {
        if (imsi) {
          const imsiExists = await simCardModel.imsiExists(imsi, id);
          if (imsiExists) {
            return errorResponse(
              res, 
              'A SIM card with this IMSI already exists', 
              400
            );
          }
        }
      }

      const updatedSimCard = await simCardModel.update(id, {
        carrier_id: carrier_id !== undefined ? carrier_id : existingSimCard.carrier_id,
        master_module_id: master_module_id !== undefined ? master_module_id : existingSimCard.master_module_id,
        phone_number: phone_number || existingSimCard.phone_number,
        iccid: iccid || existingSimCard.iccid,
        imsi: imsi !== undefined ? imsi : existingSimCard.imsi,
        apn: apn !== undefined ? apn : existingSimCard.apn,
        pin1: pin1 !== undefined ? pin1 : existingSimCard.pin1,
        puk1: puk1 !== undefined ? puk1 : existingSimCard.puk1,
        pin2: pin2 !== undefined ? pin2 : existingSimCard.pin2,
        puk2: puk2 !== undefined ? puk2 : existingSimCard.puk2,
        plan_details: plan_details !== undefined ? plan_details : existingSimCard.plan_details,
        activation_date: activation_date !== undefined ? activation_date : existingSimCard.activation_date,
        expiry_date: expiry_date !== undefined ? expiry_date : existingSimCard.expiry_date,
        status: status || existingSimCard.status,
        notes: notes !== undefined ? notes : existingSimCard.notes,
        updated_at: new Date()
      });

      return successResponse(res, 'SIM card updated successfully', updatedSimCard);
    } catch (error) {
      next(error);
    }
  },

  // Delete a SIM card
  async deleteSimCard(req, res, next) {
    try {
      const { id } = req.params;

      // Check if SIM card exists
      const simCard = await simCardModel.getById(id);
      if (!simCard) {
        return errorResponse(res, 'SIM card not found', 404);
      }

      await simCardModel.delete(id);
      return successResponse(res, 'SIM card deleted successfully', null, 204);
    } catch (error) {
      next(error);
    }
  },

  // Assign SIM card to master module
  async assignToMasterModule(req, res, next) {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const { id } = req.params;
      const { master_module_id } = req.body;

      // Check if SIM card exists
      const simCard = await simCardModel.getById(id);
      if (!simCard) {
        return errorResponse(res, 'SIM card not found', 404);
      }

      // If unassigning (setting master_module_id to null)
      if (!master_module_id) {
        const updatedSimCard = await simCardModel.update(id, {
          master_module_id: null,
          updated_at: new Date()
        });
        return successResponse(res, 'SIM card unassigned successfully', updatedSimCard);
      }

      // Check if master module exists
      const masterModule = await masterModuleModel.getById(master_module_id);
      if (!masterModule) {
        return errorResponse(res, 'Master module not found', 404);
      }

      // Check if master module already has a SIM card assigned
      const hasSim = await simCardModel.masterModuleHasSim(master_module_id, id);
      if (hasSim) {
        return errorResponse(
          res, 
          'This master module already has a SIM card assigned', 
          400
        );
      }

      // Update SIM card with new master module assignment
      const updatedSimCard = await simCardModel.update(id, {
        master_module_id,
        updated_at: new Date()
      });

      return successResponse(res, 'SIM card assigned to master module successfully', updatedSimCard);
    } catch (error) {
      next(error);
    }
  }
};

module.exports = simCardController;
