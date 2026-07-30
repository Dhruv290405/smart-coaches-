const supabaseAdmin = require('../config/supabaseAdmin');
const BaseModel = require('./base.model');

class RolesModel extends BaseModel {
  constructor() {
    super('role_master');
  }

  async getAllRoles() {
    const { data: rows, error } = await supabaseAdmin
        .from('role_master')
        .select('role_id, name')
        .eq('is_active', 1);
    if (error) throw error;
    return rows;
}

  async getDefaultList(zoneId, divisionId, regionIds, trainIds) {
    let roleIdsToFetch = [];

    const isTrainIdsProvided = Array.isArray(trainIds) && trainIds.length > 0;
    const isSingleTrainId = isTrainIdsProvided && trainIds.length === 1 && trainIds[0] !== -1;
    const isMultipleTrainIdsOrMinusOne = isTrainIdsProvided && (trainIds.includes(-1) || trainIds.length > 1);
    const isRegionValid = Array.isArray(regionIds) && regionIds.length > 0 && !regionIds.includes(-1);
    const isMultipleRegions = Array.isArray(regionIds) && regionIds.length > 1;

    if (zoneId === -1 && divisionId === -1 && regionIds.includes(-1) && trainIds.includes(-1)) {
      roleIdsToFetch = [2];
    } else if (zoneId !== -1 && divisionId === -1 && regionIds.includes(-1) && trainIds.includes(-1)) {
      roleIdsToFetch = [3];
    } else if (zoneId !== -1 && divisionId !== -1 && regionIds.includes(-1) && trainIds.includes(-1)) {
      roleIdsToFetch = [4];
    } else if (zoneId !== -1 && divisionId !== -1 && isRegionValid) {
      if (isMultipleRegions) {
        roleIdsToFetch = [5, 6];
      } else if (!isTrainIdsProvided) {
        roleIdsToFetch = [5, 6];
      } else if (isSingleTrainId) {
        roleIdsToFetch = [7];
      } else if (isMultipleTrainIdsOrMinusOne) {
        roleIdsToFetch = [5, 6];
      }
    }

    console.log('Role IDs to fetch:', roleIdsToFetch);
    if (roleIdsToFetch.length === 0) return [];

    const { data: rows, error } = await supabaseAdmin
      .from('role_master')
      .select('*')
      .in('role_id', roleIdsToFetch);
    if (error) throw error;

    return rows;
  }

  async getAllRolesExcludingSuperAdmin() {
    const { data: rows, error } = await supabaseAdmin
      .from('role_master')
      .select('role_id, name')
      .eq('is_active', 1)
      .neq('role_id', 1);
    if (error) throw error;
    return rows;
  }
}

module.exports = new RolesModel();
