const { toMySQLDatetime } = require('../middleware/datetime');
const { pool } = require('../config/db');
const BaseModel = require('./base.model');

class StationModel extends BaseModel {
    constructor() {
        super('region_master');
    }

    async getAllStations() {
        const [rows] = await this.pool.query(
            `SELECT * FROM region_master WHERE is_station = 1 AND region_id != -1`
        )
        return rows
    }
}

module.exports = new StationModel();
