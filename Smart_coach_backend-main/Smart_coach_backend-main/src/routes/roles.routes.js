const express = require('express');
const { body, param } = require('express-validator');
const rolesController = require('../controllers/roles.controller');
const router = express.Router();

// List all items for a master table
router.get(
  '/',
  rolesController.list
);
router.get('/get-all-roles', rolesController.getRoleList);

module.exports = router;
