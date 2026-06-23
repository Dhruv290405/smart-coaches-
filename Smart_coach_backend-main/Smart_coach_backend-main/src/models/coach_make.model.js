const { pool } = require("../config/db");
const { toMySQLDatetime } = require("../middleware/datetime");
const BaseModel = require("./base.model");

class Coach_makeModel extends BaseModel {
  constructor() {
    super("coach_make");
  }

  async getAllCoachMake(deviceId) {
    const [rows] = await this.pool.query(
      'SELECT * FROM coach_make',
   
    );
    return rows;
  }
}

module.exports = new Coach_makeModel();