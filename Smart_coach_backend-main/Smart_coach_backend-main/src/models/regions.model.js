const { toMySQLDatetime } = require('../middleware/datetime');
const { pool } = require('../config/db');
const BaseModel = require('./base.model');

class RegionsModel extends BaseModel {
    constructor() {
        super('region_master');
    }

    async getAllRegions() {
        const [rows] = await this.pool.query(
            `SELECT * FROM region_master WHERE is_region = 1 AND region_id != -1`
        )
        return rows
    }
}

module.exports = new RegionsModel();
