const supabaseAdmin = require('../config/supabaseAdmin');
const BaseModel = require("./base.model");

class Sensor_makeModel extends BaseModel {
  constructor() {
    super("sensor_make");
  }

  async getAllSensorMake() {
    const { data: rows, error } = await supabaseAdmin
      .from('sensor_make')
      .select('*');
    if (error) throw error;
    return rows;
  }
}

module.exports = new Sensor_makeModel();
