const { pool } = require("../config/db");
const { toMySQLDatetime } = require("../middleware/datetime");
const BaseModel = require("./base.model");

class Coach_typeModel extends BaseModel {
  constructor() {
    super("coach_type");
  }

  async getAllCoachType(deviceId) {
    const [rows] = await this.pool.query(
      'SELECT * FROM coach_type',
   
    );
    return rows;
  }
}

module.exports = new Coach_typeModel();