const BaseModel = require('./base.model');
const { pool } = require('../config/db');
const { toMySQLDatetime } = require('../middleware/datetime');

class TrainModel extends BaseModel {
  constructor() {
    super('train_master');
  }

  async createTrain(data) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const created_at = toMySQLDatetime();

      const [trainResult] = await conn.query(
        `INSERT INTO train_master (
        train_number,
        train_name,
        origination_region_id,
        region_id,
        departure_station_id,
        destination_station_id,
        no_of_coaches,
        line,
        train_operator,
        engine_number,
        created_by,
        created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          data.train_number,
          data.train_name,
          data.origination_region_id,
          data.region_id,
          data.departure_station_id,
          data.destination_station_id,
          data.no_of_coaches,
          data.line,
          data.train_operator,
          data.engine_number,
          data.created_by,
          created_at
        ]
      );

      const train_id = trainResult.insertId;

      if (data.coaches.length > 0) {
        for (const coach of data.coaches) {
          const [[coachRow]] = await conn.query(
            'SELECT coach_id FROM coach_master WHERE coach_unique_id = ?',
            [coach.coach_unique_id]
          );

          if (!coachRow) {
          await conn.query(
              `INSERT INTO coach_master (
              entity_type,
              coach_unique_id,
              coach_display_id,
              position,
              train_id,
              created_by,
              created_date
            ) VALUES (?, ?, ?, ?, ?, ?, ?)`,
              [
                coach.entity_type,
                coach.coach_unique_id,
              coach.coach_display_id,
                coach.position,
                train_id,
                data.created_by,
                created_at
              ]
            );
          } else {
            await conn.query(
              `UPDATE coach_master
             SET entity_type = ?, train_id = ?, coach_display_id = ?, position = ?, updated_by = ?, updated_date = ?
             WHERE coach_id = ?`,
              [
                coach.entity_type,
                train_id,
                coach.coach_display_id,
                coach.position,
                data.created_by,
                created_at,
                coachRow.coach_id
            ]
          );
        }
      }
      }

      await conn.commit();
      return train_id;
    } catch (error) {
      await conn.rollback();
      throw new Error('Failed to create train: ' + error.message);
    } finally {
      conn.release();
    }
  }

  async getAllTrains() {
    const [rows] = await pool.query(`
    SELECT 
      t.train_id,
      t.train_number,
      t.train_name,
      t.origination_region_id,
      t.region_id,
      t.departure_station_id,
      t.destination_station_id,
      t.line,
      t.train_operator,
      t.engine_number,
      t.created_at,
      t.updated_at,

      u1.first_name AS created_by,
      u2.first_name AS updated_by,

      r1.name AS origination_region_name,
      r2.name AS region_name,
      r3.name AS departure_station_name,
      r4.name AS destination_station_name,

      c.coach_id,
      c.coach_unique_id,
      c.coach_display_id,
      c.entity_type,
      c.position

    FROM train_master t
    LEFT JOIN user_master u1 ON t.created_by = u1.user_id
    LEFT JOIN user_master u2 ON t.updated_by = u2.user_id
    LEFT JOIN region_master r1 ON t.origination_region_id = r1.region_id
    LEFT JOIN region_master r2 ON t.region_id = r2.region_id
    LEFT JOIN region_master r3 ON t.departure_station_id = r3.region_id
    LEFT JOIN region_master r4 ON t.destination_station_id = r4.region_id
    LEFT JOIN coach_master c ON t.train_id = c.train_id
    ORDER BY t.train_id, c.position;
  `);

    return rows;
  }




  async updateTrain(data) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const updated_at = toMySQLDatetime(new Date());

      await conn.query(`
      UPDATE train_master SET 
        train_number = ?, train_name = ?, origination_region_id = ?, region_id = ?,
        departure_station_id = ?, destination_station_id = ?, no_of_coaches = ?, 
        line = ?, train_operator = ?, engine_number = ?, updated_by = ?, updated_at = ?
      WHERE train_id = ?
    `, [
        data.train_number, data.train_name, data.origination_region_id, data.region_id,
        data.departure_station_id, data.destination_station_id, data.no_of_coaches,
        data.line, data.train_operator, data.engine_number, data.updated_by, updated_at,
        data.train_id
      ]);

      await conn.query(`DELETE FROM train_coach_mapping WHERE train_id = ?`, [data.train_id]);

      
      if (data.coaches?.length > 0) {
        for (const coach of data.coaches) {
          const [rows] = await conn.query(
            `SELECT coach_id FROM coach_master WHERE coach_unique_id = ?`,
            [coach.coach_unique_id]
          );

          if (!rows.length) {
            throw new Error(`Coach with unique number ${coach.coach_unique_id} not found.`);
          }

          const coach_id = rows[0].coach_id;

          await conn.query(
            `INSERT INTO train_coach_mapping 
            (train_id, coach_id, coach_display_id, position, is_active)
           VALUES (?, ?, ?, ?, 1)`,
            [data.train_id, coach_id, coach.coach_display_id, coach.position]
          );
        }
      }

      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw new Error('Failed to update train: ' + err.message);
    } finally {
      conn.release();
    }
  }

  async deleteTrain(train_id, updated_by) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const updated_at = toMySQLDatetime(new Date());

      await conn.query(`
            DELETE FROM train_coach_mapping
            WHERE train_id = ?
        `, [train_id]);

      await conn.query(`
            DELETE FROM train_master WHERE train_id = ?
        `, [train_id]);

      await conn.commit();
    } catch (err) {
      await conn.rollback();
      throw new Error('Failed to delete train: ' + err.message);
    } finally {
      conn.release();
    }
  }

  async getAll(filters = {}) {
    let query = `
    SELECT t.*, 
           orig.name as origination_region_name,
           r.name as region_name, 
           dep.name as departure_station_name,
           dest.name as destination_station_name
    FROM train_master t
    LEFT JOIN region_master orig ON t.origination_region_id = orig.region_id
    LEFT JOIN region_master r ON t.region_id = r.region_id
    LEFT JOIN region_master dep ON t.departure_station_id = dep.region_id
    LEFT JOIN region_master dest ON t.destination_station_id = dest.region_id
    WHERE 
  `;

    const params = [];

    if (filters.onlyTrainIdMinusOne) {
        query += ' t.train_id = -1';
    } else {
        query += ' ( (1=1';

        if (Array.isArray(filters.region_ids) && filters.region_ids.length > 0) {
            const placeholders = filters.region_ids.map(() => '?').join(',');
            query += ` AND t.origination_region_id IN (${placeholders})`;
            params.push(...filters.region_ids);
        }

        query += ')';

        query += ' OR t.train_id = -1 )';

        if (filters.search) {
            query += ' AND (t.train_number LIKE ? OR t.train_name LIKE ?)';
            const searchTerm = `%${filters.search}%`;
            params.push(searchTerm, searchTerm);
        }
    }

    console.log('Final Query:', query);
    console.log('Params:', params);

    try {
        const [rows] = await this.pool.query(query, params);
        return rows;
    } catch (error) {
        console.error('Error in getAll Trains:', error);
        throw error;
    }
}
  // Get trains mapped to a specific user
  async getTrainsMappedToUser(userId) {
    // Step 1: Check if user is mapped to train_id = -1
    const [specialTrainRows] = await this.pool.query(
      'SELECT 1 FROM user_train_mapping WHERE user_id = ? AND train_id = -1',
      [userId]
    );

    if (specialTrainRows.length > 0) {
      // Step 2: Fetch region_ids mapped to the user
      const [regionRows] = await this.pool.query(
        'SELECT region_id FROM user_region_mapping WHERE user_id = ?',
        [userId]
      );

      const regionIds = regionRows.map(r => r.region_id);
      if (regionIds.length === 0) return []; // No regions assigned

      // Step 3: Fetch trains from those regions
      const placeholders = regionIds.map(() => '?').join(',');
      const [trains] = await this.pool.query(
        `
      SELECT t.*, r.name AS region_name
      FROM train_master t
      LEFT JOIN region_master r ON t.origination_region_id = r.region_id
      WHERE t.origination_region_id IN (${placeholders})
      ORDER BY t.train_number
      `,
        regionIds
      );

      return trains;
    }

    // Step 4: Fallback — fetch mapped trains as usual
    const [rows] = await this.pool.query(
      `
    SELECT t.*, r.name AS region_name
    FROM train_master t
    LEFT JOIN region_master r ON t.origination_region_id = r.region_id
    WHERE t.train_id IN (
      SELECT train_id 
      FROM user_train_mapping 
      WHERE user_id = ?
    )
    ORDER BY t.train_number
    `,
      [userId]
    );

    return rows;
  }

  // update train user mapping
  async updateTrainUserMapping(userId, trainIds) {
    const conn = await this.pool.getConnection();
    try {
      await conn.beginTransaction();

      // Remove existing mappings
      await conn.query(
        `DELETE FROM user_train_mapping WHERE user_id = ?`,
        [userId]
      );

      // Add new mappings
      const values = trainIds.map(trainId => [userId, trainId]);
      if (values.length > 0) {
        await conn.query(
          `INSERT INTO user_train_mapping (user_id, train_id) VALUES ?`,
          [values]
        );
      }

      console.log(`Updated train user mapping for user ID: ${userId} with trains: ${trainIds.join(', ')}`);

      await conn.commit();
    } catch (error) {
      console.error('Error updating train user mapping:', error);
      await conn.rollback();
      throw error;
    } finally {
      conn.release();
    }
  }

  // Get train by ID with details
  async getById(id) {
    const [rows] = await this.pool.query(
      `SELECT t.*, 
              z.name as zone_name,
              d.name as division_name,
              r.name as region_name
       FROM train_master t
       LEFT JOIN zones z ON t.zone_id = z.id
       LEFT JOIN divisions d ON t.division_id = d.id
       LEFT JOIN regions r ON t.origination_region_id = r.id
       WHERE t.id = ?`,
      [id]
    );
    return rows[0] || null;
  }

  // Get coaches for a specific train
  async getCoaches(trainId) {
    const [rows] = await this.pool.query(
      'SELECT * FROM coaches WHERE train_id = ? ORDER BY coach_number',
      [trainId]
    );
    return rows;
  }

  // Check if train number already exists
  async trainNumberExists(train_number, excludeId = null) {
    let query = 'SELECT train_id FROM train_master WHERE train_number = ?';
    const params = [train_number];

    if (excludeId) {
      query += ' AND id != ?';
      params.push(excludeId);
    }

    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  async getTrainsForUsers() {

    let query = 'SELECT train_id, train_number, train_name FROM train_master';
    const [rows] = await this.pool.query(query);
    return rows;
    
  }
}

module.exports = new TrainModel();
