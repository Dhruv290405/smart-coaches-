const BaseModel = require('./base.model');

class RoleModel extends BaseModel {
  constructor() {
    super('role_master');
  }

  /**
   * Get role name by role ID
   * @param {number} roleId
   * @returns {Promise<string|null>}
   */
  async getRoleNameById(roleId) {
    console.log('Fetching role name for role ID:', roleId);
    const [rows] = await this.pool.query(
      'SELECT name FROM role_master WHERE role_id = ? AND is_active = 1',
      [roleId]
    );
    console.log(`Role name query result:`, rows);
    return rows.length > 0 ? rows[0].name : null;
  }

  async getRoleIdByUser(userId) {
    console.log('Fetching role ID for user:', userId);
    const [rows] = await this.pool.query(
      'SELECT role_id FROM user_master WHERE user_id = ?',
      [userId]
    );
    console.log('Role ID query result:', rows);
    return rows.length > 0 ? rows[0].role_id : null;
  }

  /**
   * Get role ID by name
   * @param {string} roleName
   * @returns {Promise<number|null>}
   */
  async getRoleIdByName(roleName) {
    const [rows] = await this.pool.query(
      'SELECT role_id FROM role_master WHERE name = ? AND is_active = 1',
      [roleName]
    );
    return rows.length > 0 ? rows[0].role_id : null;
  }

  /**
   * Get all active roles (useful for dropdowns)
   * @returns {Promise<Array>}
   */
  async getAllActiveRoles() {
    const [rows] = await this.pool.query(
      'SELECT role_id, name FROM role_master WHERE is_active = 1 ORDER BY name ASC'
    );
    return rows;
  }

  /**
   * Check if a role is restricted to be approved only by Editors
   * (used for Region Operator or Train Operator)
   * @param {number} roleId
   * @returns {Promise<boolean>}
   */
  async isEditorRestrictedRole(roleId) {
    const restrictedRoles = ['Region Operator', 'Train Operator'];
    const roleName = await this.getRoleNameById(roleId);
    return restrictedRoles.includes(roleName);
  }
}

module.exports = new RoleModel();
