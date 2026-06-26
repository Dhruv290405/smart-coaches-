const BaseModel = require("./base.model");

class Sensor_configModel extends BaseModel {
  constructor() {
    super("sensor_config");
  }

  // get sensor_type_id from sensor_device_mapping by device_id
  async getSensorTypeId(device_id) {
    const [rows] = await this.pool.execute(
      `SELECT sensor_id as sensor_type_id FROM sensor_device_mapping WHERE device_id = ?`,
      [device_id]
    );
    return rows.length > 0 ? rows[0].sensor_type_id : null;
  }

  // get rule_id from rule_sensor_mapping by sensor_id
  async getRuleId(sensor_type_id) {
    const [rows] = await this.pool.execute(
      `SELECT rule_id FROM rule_sensor_mapping WHERE sensor_type_id = ?`,
      [sensor_type_id]
    );
    return rows.length > 0 ? rows[0].rule_id : null;
  }

  async insertSensorConfig({
    sensor_id,
    device_id,
    sensor_type_id,
    rule_id,
    sensor_make_id,
    install_date,
    placement,
    location,
    remarks,
    master_module_id,
    coach_id
  }) {
    // Check if the sensor_id already exists
    const [existing] = await this.pool.execute(
      `SELECT sensor_config_id FROM sensor_config WHERE sensor_id = ?`,
      [sensor_id]
    );
  
    if (existing.length > 0) {
      throw new Error(`Sensor with ID "${sensor_id}" already exists.`);
    }
  
    // Insert including new fields
    const [result] = await this.pool.execute(
      `INSERT INTO sensor_config (
        sensor_id,
        device_id,
        sensor_type_id,
        rule_id,
        sensor_make_id,
        install_date,
        placement,
        location,
        remarks,
        master_module_id,
        coach_id
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        sensor_id,
        device_id,
        sensor_type_id,
        rule_id,
        sensor_make_id,
        install_date,
        placement,
        location,
        remarks,
        master_module_id,
        coach_id
      ]
    );
  
    return result.insertId;
  }
  async getAllSensorConfigs() {
    const [rows] = await this.pool.execute(`
      SELECT 
        sc.*,                             
        d.*,                              
        sm.*,                             
        mm.*,                             
        cm.*                            
      FROM sensor_config sc
      LEFT JOIN device_master d ON sc.device_id = d.device_id
      LEFT JOIN sensor_make sm ON sc.sensor_make_id = sm.sensor_make_id
      LEFT JOIN master_module mm ON sc.master_module_id = mm.module_id
      LEFT JOIN coach_master cm ON sc.coach_id = cm.coach_id
    `);
  
    return rows;
  }

  async noOfDevicesAttachedToModule(module_id) {
    const [rows] = await this.pool.query(
      `SELECT COUNT(*) AS device_count FROM module_device_mapping WHERE module_id = ?`,
      [module_id]
    );
    return rows[0].device_count;
  }
  
  async getAllSensorConfigs() {
  const [rows] = await this.pool.execute(`
    SELECT 
      sc.*,
      COALESCE(d.tech_coach_no, '') AS tech_coach_no,
      COALESCE(d.comm_coach_no, '') AS comm_coach_no,
      COALESCE(d.train_no, '') AS train_no,
      COALESCE(d.train_location, '') AS train_location
    FROM sensor_config sc
    LEFT JOIN device_master d ON sc.device_id = d.device_id
    ORDER BY sc.sensor_config_id DESC
  `);

  return rows;
}
  

  async updateSensorConfig(sensor_config_id, {
    sensor_id,
    device_id,
    sensor_make_id,
    install_date,
    placement,
    location,
    remarks
  }) {
    // Check if the new sensor_id exists for a different record
    const [existing] = await this.pool.execute(
      `SELECT sensor_config_id FROM sensor_config WHERE sensor_id = ? AND sensor_config_id != ?`,
      [sensor_id, sensor_config_id]
    );
  
    if (existing.length > 0) {
      throw new Error(`Sensor ID "${sensor_id}" already exists in another config.`);
    }
  
    const [result] = await this.pool.execute(
      `UPDATE sensor_config SET
        sensor_id = ?,
        device_id = ?,
        sensor_make_id = ?,
        install_date = ?,
        placement = ?,
        location = ?,
        remarks = ?
      WHERE sensor_config_id = ?`,
      [sensor_id, device_id, sensor_make_id, install_date, placement, location, remarks, sensor_config_id]
    );
  
    return result.affectedRows > 0; // true if update was successful
  }
  

  async deleteSensorConfig(sensor_config_id) {
    const [result] = await this.pool.execute(
      `DELETE FROM sensor_config WHERE sensor_config_id = ?`,
      [sensor_config_id]
    );

    console.log(`Deleted sensor config with ID ${sensor_config_id}`);

    return result.affectedRows > 0; // true if deletion was successful
  }

  async getTrainAndCoachBySensorId(sensor_id) {
    const [rows] = await this.pool.execute(
      `SELECT coach_id FROM sensor_config WHERE SENSOR_ID = ?`,
      [sensor_id]
    );
    
    const coach_id = rows.length > 0 ? rows[0].coach_id : null;
    
    if (!coach_id) {
      return null; // No coach found for this sensor
    }

    const [coachRows] = await this.pool.execute(
      `SELECT coach_id FROM coach_master WHERE coach_id = ?`,
      [coach_id]
    );
    
    const train_id = null;

    return { coach_id, train_id };
  }
}

module.exports = new Sensor_configModel();