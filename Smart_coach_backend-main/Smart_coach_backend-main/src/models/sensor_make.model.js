const BaseModel = require("./base.model");

class Sensor_makeModel extends BaseModel {
  constructor() {
    super("sensor_make");
  }

  async getAllSensorMake() {
    const [rows] = await this.pool.query(
      'SELECT * FROM sensor_make',
   
    );
    return rows;
  }
}

module.exports = new Sensor_makeModel();