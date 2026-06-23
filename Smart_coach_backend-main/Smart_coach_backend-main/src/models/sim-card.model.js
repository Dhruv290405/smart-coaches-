const BaseModel = require('./base.model');

class SimCardModel extends BaseModel {
  constructor() {
    super('sim_cards');
  }

  // Get all SIM cards with optional filters
  async getAll(filters = {}, page = 1, limit = 10) {
    const offset = (page - 1) * limit;
    let query = `
      SELECT sc.*, 
             mm.name as master_module_name,
             mm.serial_number as master_module_serial,
             c.coach_number,
             t.number as train_number,
             t.name as train_name,
             c2.name as carrier_name
      FROM sim_cards sc
      LEFT JOIN master_modules mm ON sc.master_module_id = mm.id
      LEFT JOIN coaches c ON mm.coach_id = c.id
      LEFT JOIN trains t ON c.train_id = t.id
      LEFT JOIN carriers c2 ON sc.carrier_id = c2.id
      WHERE 1=1
    `;
    
    const params = [];
    
    // Add filters
    if (filters.master_module_id) {
      query += ' AND sc.master_module_id = ?';
      params.push(filters.master_module_id);
    }
    
    if (filters.carrier_id) {
      query += ' AND sc.carrier_id = ?';
      params.push(filters.carrier_id);
    }
    
    if (filters.status) {
      query += ' AND sc.status = ?';
      params.push(filters.status);
    }
    
    if (filters.search) {
      query += ' AND (sc.phone_number LIKE ? OR sc.iccid LIKE ? OR sc.imsi LIKE ?)';
      const searchTerm = `%${filters.search}%`;
      params.push(searchTerm, searchTerm, searchTerm);
    }
    
    // Add pagination
    query += ' ORDER BY sc.phone_number LIMIT ? OFFSET ?';
    params.push(limit, offset);
    
    const [rows] = await this.pool.query(query, params);
    return rows;
  }

  // Get SIM card by ID with details
  async getById(id) {
    const [rows] = await this.pool.query(
      `SELECT sc.*, 
              mm.name as master_module_name,
              mm.serial_number as master_module_serial,
              c.coach_number,
              t.id as train_id,
              t.number as train_number,
              t.name as train_name,
              c2.name as carrier_name
       FROM sim_cards sc
       LEFT JOIN master_modules mm ON sc.master_module_id = mm.id
       LEFT JOIN coaches c ON mm.coach_id = c.id
       LEFT JOIN trains t ON c.train_id = t.id
       LEFT JOIN carriers c2 ON sc.carrier_id = c2.id
       WHERE sc.id = ?`,
      [id]
    );
    return rows[0] || null;
  }

  // Check if phone number already exists
  async phoneNumberExists(phoneNumber, excludeId = null) {
    let query = 'SELECT id FROM sim_cards WHERE phone_number = ?';
    const params = [phoneNumber];
    
    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }
    
    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  // Check if ICCID already exists
  async iccidExists(iccid, excludeId = null) {
    let query = 'SELECT id FROM sim_cards WHERE iccid = ?';
    const params = [iccid];
    
    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }
    
    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  // Check if IMSI already exists
  async imsiExists(imsi, excludeId = null) {
    if (!imsi) return false;
    
    let query = 'SELECT id FROM sim_cards WHERE imsi = ?';
    const params = [imsi];
    
    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }
    
    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  // Check if master module already has a SIM card assigned
  async masterModuleHasSim(masterModuleId, excludeId = null) {
    if (!masterModuleId) return false;
    
    let query = 'SELECT id FROM sim_cards WHERE master_module_id = ?';
    const params = [masterModuleId];
    
    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }
    
    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }
}

module.exports = new SimCardModel();
