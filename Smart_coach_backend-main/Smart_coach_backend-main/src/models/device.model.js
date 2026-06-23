const BaseModel = require('./base.model');

class DeviceModel extends BaseModel {
  constructor() {
    super('device_master');
  }

  // Get all devices with optional filters
  async getAll(filters = {}, page = 1, limit = 10) {
    const offset = (page - 1) * limit;
    let query = `
      SELECT d.*, 
             mm.name as master_module_name,
             mm.serial_number as master_module_serial,
             c.coach_number,
             t.number as train_number,
             t.name as train_name,
             dt.name as device_type_name,
             dt.model as device_model
      FROM devices d
      LEFT JOIN master_modules mm ON d.master_module_id = mm.id
      LEFT JOIN coaches c ON mm.coach_id = c.id
      LEFT JOIN trains t ON c.train_id = t.id
      LEFT JOIN device_types dt ON d.device_type_id = dt.id
      WHERE 1=1
    `;

    const params = [];

    // Add filters
    if (filters.master_module_id) {
      query += ' AND d.master_module_id = ?';
      params.push(filters.master_module_id);
    }

    if (filters.device_type_id) {
      query += ' AND d.device_type_id = ?';
      params.push(filters.device_type_id);
    }

    if (filters.status) {
      query += ' AND d.status = ?';
      params.push(filters.status);
    }

    if (filters.search) {
      query += ' AND (d.name LIKE ? OR d.serial_number LIKE ? OR d.mac_address LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }

    // Add pagination
    query += ' ORDER BY mm.name, d.name LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const [rows] = await this.pool.query(query, params);
    return rows;
  }

  // Get device by ID with details
  async getById(id) {
    const [rows] = await this.pool.query(
      `SELECT * FROM device_master WHERE device_id = ?`,
      [id]
    );
    return rows[0] || null;
  }

  async getByMasterModuleId(master_module_id) {
    const [rows] = await this.pool.query(
      `
      SELECT 
        d.*,  
        mm.seriel_number AS master_module_serial,  
        c.coach_unique_id,  
        t.train_number,  
        t.train_name,  
        dt.full_name AS device_type_name,  
        dt.short_name AS device_model,  
        u1.first_name AS created_by,  
        u2.first_name AS updated_by
  
      FROM device_master d  
        LEFT JOIN master_module mm ON d.master_module_id = mm.module_id  
        LEFT JOIN coach_master c ON mm.coach_id = c.coach_id  
        LEFT JOIN train_master t ON c.train_id = t.train_id  
        LEFT JOIN device_master dt ON d.device_id = dt.device_id  
        LEFT JOIN user_master u1 ON d.created_by = u1.user_id  
        LEFT JOIN user_master u2 ON d.updated_by = u2.user_id  
  
      WHERE d.master_module_id = ?
      `,
      [master_module_id]
    );
  
    return rows; // returns all devices under that master_module_id
  }
  

  // Check if serial number already exists
  async serialNumberExists(serialNumber, excludeId = null) {
    let query = 'SELECT id FROM devices WHERE serial_number = ?';
    const params = [serialNumber];

    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }

    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  // Check if MAC address already exists
  async macAddressExists(macAddress, excludeId = null) {
    if (!macAddress) return false;

    let query = 'SELECT id FROM devices WHERE mac_address = ?';
    const params = [macAddress];

    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }

    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  // Get all sensors for a device
  async getSensors(deviceId) {
    const [rows] = await this.pool.query(
      'SELECT * FROM sensors WHERE device_id = ? ORDER BY name',
      [deviceId]
    );
    return rows;
  }

  // Get latest readings for a device's sensors
  async getLatestReadings(deviceId, limit = 10) {
    const [rows] = await this.pool.query(
      `SELECT s.id as sensor_id, s.name as sensor_name, sr.* 
       FROM sensors s
       LEFT JOIN (
         SELECT sensor_id, MAX(reading_time) as latest_reading
         FROM sensor_readings
         WHERE device_id = ?
         GROUP BY sensor_id
       ) latest ON s.id = latest.sensor_id
       LEFT JOIN sensor_readings sr ON latest.sensor_id = sr.sensor_id 
         AND latest.latest_reading = sr.reading_time
         AND sr.device_id = ?
       WHERE s.device_id = ?
       ORDER BY s.name
       LIMIT ?`,
      [deviceId, deviceId, deviceId, limit]
    );
    return rows;
  }

  // delete a device
  async delete(id) {
    // Delete the device
    await this.pool.query('DELETE FROM device_master WHERE device_id = ?', [id]);
    return { status: true, message: 'Device deleted successfully'};
  }
}

module.exports = new DeviceModel();
