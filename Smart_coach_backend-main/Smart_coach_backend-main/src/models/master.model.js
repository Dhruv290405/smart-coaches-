const BaseModel = require('./base.model');

class MasterModel extends BaseModel {
  constructor(tableName) {
    super(tableName);
  }

  async getAllActive(filter = {}, orFilter = {}) {
    const andConditions = ['is_active = TRUE'];
    const orConditions = [];
    const params = [];

    for (const [key, value] of Object.entries(filter)) {
      andConditions.push(`${key} = ?`);
      params.push(value);
    }

    for (const [key, value] of Object.entries(orFilter)) {
      orConditions.push(`${key} = ?`);
      params.push(value);
    }

    let whereClause = '';
    if (orConditions.length > 0) {
      whereClause = `WHERE ${andConditions.join(' AND ')} OR (${orConditions.join(' OR ')})`;
    } else if (andConditions.length > 0) {
      whereClause = `WHERE ${andConditions.join(' AND ')}`;
    }

    const [rows] = await this.pool.query(
      `SELECT * FROM ${this.tableName} ${whereClause} ORDER BY name`,
      params
    );

    return rows;
  }


  async getActiveCount(filter = {}) {
    const conditions = ['is_active = TRUE'];
    const params = [];

    for (const [key, value] of Object.entries(filter)) {
      conditions.push(`${key} = ?`);
      params.push(value);
    }

    const whereClause = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const [rows] = await this.pool.query(
      `SELECT COUNT(*) as count FROM ${this.tableName} ${whereClause}`,
      params
    );

    return rows[0].count;
  }

  // Toggle active status
  async toggleStatus(id) {
    const [result] = await this.pool.query(
      `UPDATE ${this.tableName} SET is_active = !is_active WHERE id = ?`,
      [id]
    );
    return result.affectedRows > 0;
  }
}

// Export instances for each master table
module.exports = {
  zoneModel: new MasterModel('zone_master'),
  divisionModel: new MasterModel('division_master'),
  regionModel: new MasterModel('region_master'),
  roleModel: new MasterModel('role_master')
};
