const { pool } = require('../config/db');

class BaseModel {
  constructor(tableName) {
    this.tableName = tableName;
    this.pool = pool;
  }

  async findOne(conditions) {
    const keys = Object.keys(conditions);
    const values = Object.values(conditions);
    const whereClause = keys.map(key => `${key} = ?`).join(' AND ');

    const [rows] = await this.pool.query(
      `SELECT * FROM ${this.tableName} WHERE ${whereClause} LIMIT 1`,
      values
    );

    return rows[0] || null;
  }

  async findAll(conditions = {}) {
    const keys = Object.keys(conditions);
    let query = `SELECT * FROM ${this.tableName}`;

    if (keys.length > 0) {
      const whereClause = keys.map(key => `${key} = ?`).join(' AND ');
      const values = Object.values(conditions);
      query += ` WHERE ${whereClause}`;
      const [rows] = await this.pool.query(query, values);
      return rows;
    }

    const [rows] = await this.pool.query(query);
    return rows;
  }

  async create(data) {
    const createdDateUTC = new Date();

    // Add created_date to the input data
    const finalData = {
      ...data,
      created_date: createdDateUTC
    };

    const keys = Object.keys(finalData);
    const values = Object.values(finalData);
    const placeholders = keys.map(() => '?').join(', ');
    const columns = keys.join(', ');

    const [result] = await this.pool.query(
      `INSERT INTO ${this.tableName} (${columns}) VALUES (${placeholders})`,
      values
    );

    return { id: result.insertId, ...finalData };
  }


  async update(id, data) {
    const keys = Object.keys(data);
    const values = Object.values(data);
    const setClause = keys.map(key => `${key} = ?`).join(', ');

    await this.pool.query(
      `UPDATE ${this.tableName} SET ${setClause} WHERE id = ?`,
      [...values, id]
    );

    return { id, ...data };
  }

  async delete(id) {
    await this.pool.query(`DELETE FROM ${this.tableName} WHERE id = ?`, [id]);
    return { id };
  }
}

module.exports = BaseModel;
