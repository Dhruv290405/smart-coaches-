const supabaseAdmin = require('../config/supabaseAdmin');
const { toMySQLDatetime } = require("../middleware/datetime");
const BaseModel = require("./base.model");

class Coach_typeModel extends BaseModel {
  constructor() {
    super("coach_type");
  }

  async getAllCoachType(deviceId) {
    const { data: rows, error } = await supabaseAdmin
      .from('coach_type')
      .select('*');
    if (error) throw error;
    return rows;
  }
}

module.exports = new Coach_typeModel();
