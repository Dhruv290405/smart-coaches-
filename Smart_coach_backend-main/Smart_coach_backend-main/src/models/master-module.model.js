const BaseModel = require('./base.model');

class MasterModuleModel extends BaseModel {
  constructor() {
    super('master_module');
  }

  async createWithDevices(data, deviceIds) {
    const conn = await this.pool.getConnection();

    try {
      await conn.beginTransaction();

      // Step 1: Check if coach_id is valid and within limit
      const [coachRows] = await conn.query(
        `SELECT no_of_master_module FROM coach_master WHERE coach_id = ?`,
        [data.coach_id]
      );

      if (coachRows.length === 0) {
        await conn.rollback();
        return { error: true, message: 'Invalid coach_id provided.' };
      }

      const noOfAllowedModules = coachRows[0].no_of_master_module;

      const [existingModules] = await conn.query(
        `SELECT COUNT(*) as count FROM master_module WHERE coach_id = ?`,
        [data.coach_id]
      );

      const currentCount = existingModules[0].count;

      if (currentCount >= noOfAllowedModules) {
        await conn.rollback();
        return {
          error: true,
          message: `Module limit reached for this coach (allowed: ${noOfAllowedModules}, current: ${currentCount})`
        };
      }

      // Step 2: Insert into master_module
      const [moduleResult] = await conn.query(
        `INSERT INTO master_module (
        coach_id, module_unique_id, make_model, firmware_version, seriel_number,
        installation_date, location, placement_type, sim_no, recharge_date,
        service_provider_primary, service_provider_secondary, activation_date, sim_status,
        battery_replacement_date, dual_profile_supported, lora_enabled, esim_enabled,
        battery_capacity, battery_type, battery_recharge_date,
        created_by, created_date
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          data.coach_id,
          data.module_unique_id,
          data.make_model,
          data.firmware_version,
          data.seriel_number,
          data.installation_date,
          data.location,
          data.placement_type,
          data.sim_no,
          data.recharge_date,
          data.service_provider_primary,
          data.service_provider_secondary || null,
          data.activation_date,
          data.sim_status,
          data.battery_replacement_date,
          data.dual_profile_supported,
          data.lora_enabled,
          data.esim_enabled,
          data.battery_capacity || null,
          data.battery_type || null,
          data.battery_recharge_date,
          data.created_by,
          data.created_date
        ]
      );

      const moduleId = moduleResult.insertId;

      // Step 3: Validate device IDs
      if (deviceIds.length > 0) {
        const [validDevices] = await conn.query(
          `SELECT device_id FROM device_master WHERE device_id IN (?)`,
          [deviceIds]
        );

        const validDeviceIds = validDevices.map(d => d.device_id);

        if (validDeviceIds.length !== deviceIds.length) {
          await conn.rollback();
          return { error: true, message: 'Some device_ids are invalid or do not exist in device_master' };
        }

        // Step 4: Insert mappings using INSERT IGNORE to avoid duplicates
        const values = validDeviceIds.map(deviceId => [moduleId, deviceId]);

        await conn.query(
          `INSERT IGNORE INTO module_device_mapping (module_id, device_id) VALUES ?`,
          [values]
        );
      }

      await conn.commit();
      return { error: false, moduleId };

    } catch (error) {
      await conn.rollback();
      throw error;
    } finally {
      conn.release();
    }
  }

  // async findByUserId(userId) {
  //   const query = `
  //   SELECT
  //     c.*,
  //     mm.*,
  //     t.train_id,
  //     t.train_number,
  //     t.train_name,

  //     u1.first_name AS train_created_by_name,
  //     u2.first_name AS train_updated_by_name,
  //     u3.first_name AS coach_created_by_name,
  //     u4.first_name AS coach_updated_by_name,
  //     u5.first_name AS module_created_by_name,
  //     u6.first_name AS module_updated_by_name,

  //     dm.device_id AS mapped_device_id,
  //     dm.device_unique_id,
  //     dm.short_name AS device_short_name,
  //     dm.full_name AS device_full_name

  //   FROM coach_master c

  //   JOIN train_master t ON c.train_id = t.train_id
  //   JOIN user_train_mapping utm ON t.train_id = utm.train_id AND utm.user_id = ?

  //   LEFT JOIN master_module mm ON mm.coach_id = c.coach_id
  //   LEFT JOIN module_device_mapping mdm ON mm.module_id = mdm.module_id
  //   LEFT JOIN device_master dm ON mdm.device_id = dm.device_id

  //   LEFT JOIN user_master u1 ON t.created_by = u1.user_id
  //   LEFT JOIN user_master u2 ON t.updated_by = u2.user_id
  //   LEFT JOIN user_master u3 ON c.created_by = u3.user_id
  //   LEFT JOIN user_master u4 ON c.updated_by = u4.user_id
  //   LEFT JOIN user_master u5 ON mm.created_by = u5.user_id
  //   LEFT JOIN user_master u6 ON mm.updated_by = u6.user_id

  //   ORDER BY t.train_id, c.position, mm.module_id;
  // `;

  //   const [rows] = await this.pool.query(query, [userId]);
  //   return rows;
  // }


  async findByUserId(userId) {
    const query = `
    SELECT
      mm.*,
      c.coach_id,
      c.coach_unique_id,
      c.coach_display_id,
      c.position,

      t.train_id,
      t.train_number,
      t.train_name,

      u1.first_name AS module_created_by_name,
      u2.first_name AS module_updated_by_name,
      u3.first_name AS coach_created_by_name,
      u4.first_name AS coach_updated_by_name,
      u5.first_name AS train_created_by_name,
      u6.first_name AS train_updated_by_name,

      dm.device_id AS mapped_device_id,
      dm.device_unique_id,
      dm.short_name AS device_short_name,
      dm.full_name AS device_full_name,

      CASE WHEN utm.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_train_mapped_to_user

    FROM master_module mm

    LEFT JOIN coach_master c ON mm.coach_id = c.coach_id
    LEFT JOIN train_master t ON c.train_id = t.train_id
    LEFT JOIN user_train_mapping utm ON t.train_id = utm.train_id AND utm.user_id = ?

    LEFT JOIN module_device_mapping mdm ON mm.module_id = mdm.module_id
    LEFT JOIN device_master dm ON mdm.device_id = dm.device_id

    LEFT JOIN user_master u1 ON mm.created_by = u1.user_id
    LEFT JOIN user_master u2 ON mm.updated_by = u2.user_id
    LEFT JOIN user_master u3 ON c.created_by = u3.user_id
    LEFT JOIN user_master u4 ON c.updated_by = u4.user_id
    LEFT JOIN user_master u5 ON t.created_by = u5.user_id
    LEFT JOIN user_master u6 ON t.updated_by = u6.user_id

    ORDER BY mm.module_id;
  `;

    const [rows] = await this.pool.query(query, [userId]);
    return rows;
  }

  async findByCoachId(coach_id) {
    console.log(`test: ${coach_id}`);
    const [rows] = await this.pool.query(
      `SELECT mm.*, cm.coach_unique_id from master_module AS mm
      JOIN coach_master AS cm ON mm.coach_id = cm.coach_id
      WHERE mm.coach_id = ?`,
      [coach_id]
   
    );
    return rows;
  }

  async noOfDevicesAttachedToModule(module_id) {
    const [rows] = await this.pool.query(
      `SELECT COUNT(*) AS device_count FROM module_device_mapping WHERE module_id = ?`,
      [module_id]
    );
    return rows[0].device_count;
  }

  async updateWithDevices(moduleId, data, deviceIds) {
    const conn = await this.pool.getConnection();

    try {
      await conn.beginTransaction();

      // 1. Update master_module
      const updateFields = Object.keys(data).map(key => `${key} = ?`).join(', ');
      const updateValues = Object.values(data);

      await conn.query(
        `UPDATE master_module SET ${updateFields} WHERE module_id = ?`,
        [...updateValues, moduleId]
      );

      // 2. Validate devices
      if (deviceIds.length > 0) {
        const [validDevices] = await conn.query(
          `SELECT device_id FROM device_master WHERE device_id IN (?)`,
          [deviceIds]
        );

        const validDeviceIds = validDevices.map(d => d.device_id);
        if (validDeviceIds.length !== deviceIds.length) {
          throw new Error('Some device_ids are invalid or do not exist in device_master');
        }

        // 3. Delete old mappings
        await conn.query(`DELETE FROM module_device_mapping WHERE module_id = ?`, [moduleId]);

        // 4. Insert new mappings
        const values = validDeviceIds.map(deviceId => [moduleId, deviceId]);
        await conn.query(
          `INSERT IGNORE INTO module_device_mapping (module_id, device_id) VALUES ?`,
          [values]
        );
      } else {
        // If deviceIds empty, remove all mappings
        await conn.query(`DELETE FROM module_device_mapping WHERE module_id = ?`, [moduleId]);
      }

      await conn.commit();
    } catch (error) {
      await conn.rollback();
      throw error;
    } finally {
      conn.release();
    }
  }

  async deleteById(moduleId) {
    const conn = await this.pool.getConnection();
    try {
      await conn.beginTransaction();

      // Delete from module_device_mapping first (if exists)
      await conn.query(`DELETE FROM module_device_mapping WHERE module_id = ?`, [moduleId]);

      // Then delete the module
      await conn.query(`DELETE FROM master_module WHERE module_id = ?`, [moduleId]);

      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw err;
    } finally {
      conn.release();
    }
  }


  async exists(moduleId) {
    const [rows] = await this.pool.query(
      `SELECT 1 FROM master_module WHERE module_id = ? LIMIT 1`,
      [moduleId]
    );
    return rows.length > 0;
  }
}

module.exports = new MasterModuleModel();
