const supabaseAdmin = require('../config/supabaseAdmin');
const { toMySQLDatetime } = require("../middleware/datetime");
const BaseModel = require("./base.model");

class Coach_makeModel extends BaseModel {
  constructor() {
    super("coach_make");
  }

  async getAllCoachMake(deviceId) {
    const { data: rows, error } = await supabaseAdmin
      .from('coach_make')
      .select('*')
      .order('name');
    if (error) throw error;
    return rows;
  }
}

module.exports = new Coach_makeModel();
