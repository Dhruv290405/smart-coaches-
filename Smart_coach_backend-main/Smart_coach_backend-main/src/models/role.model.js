const supabaseAdmin = require('../config/supabaseAdmin');
const BaseModel = require('./base.model');

class RoleModel extends BaseModel {
  constructor() {
    super('role_master');
  }

  async getRoleNameById(roleId) {
    console.log('Fetching role name for role ID:', roleId);
    const { data, error } = await supabaseAdmin
      .from('role_master')
      .select('name')
      .eq('role_id', roleId)
      .eq('is_active', 1);
    if (error) throw error;
    console.log('Role name query result:', data);
    return data.length > 0 ? data[0].name : null;
  }

  async getRoleIdByUser(userId) {
    console.log('Fetching role ID for user:', userId);
    const { data, error } = await supabaseAdmin
      .from('user_master')
      .select('role_id')
      .eq('user_id', userId);
    if (error) throw error;
    console.log('Role ID query result:', data);
    return data.length > 0 ? data[0].role_id : null;
  }

  async getRoleIdByName(roleName) {
    const { data, error } = await supabaseAdmin
      .from('role_master')
      .select('role_id')
      .eq('name', roleName)
      .eq('is_active', 1);
    if (error) throw error;
    return data.length > 0 ? data[0].role_id : null;
  }

  async getAllActiveRoles() {
    const { data: rows, error } = await supabaseAdmin
      .from('role_master')
      .select('role_id, name')
      .eq('is_active', true)
      .order('name');
    if (error) throw error;
    return rows;
  }

  async isEditorRestrictedRole(roleId) {
    const restrictedRoles = ['Region Operator', 'Train Operator'];
    const roleName = await this.getRoleNameById(roleId);
    return restrictedRoles.includes(roleName);
  }
}

module.exports = new RoleModel();
