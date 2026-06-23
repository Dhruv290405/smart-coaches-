const { pool } = require("../config/db");
const { toMySQLDatetime } = require("../middleware/datetime");
const BaseModel = require("./base.model");

class CoachModel extends BaseModel {
  constructor() {
    super("coaches");
  }

  async createCoach(data) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      const created_date = toMySQLDatetime();

      // Check for duplicate coach_unique_id
      const [[existingCoach]] = await conn.query(
        "SELECT coach_id FROM coach_master WHERE coach_unique_id = ?",
        [data.coach_unique_id]
      );

      if (existingCoach) {
        throw new Error(
          `Coach with unique ID "${data.coach_unique_id}" already exists.`
        );
      }

      // Insert into coach_master - Added coach_display_id here
      const [coachResult] = await conn.query(
        `INSERT INTO coach_master (
          entity_type,
          coach_unique_id,
          coach_display_id,
          make_of_coach,
          type_of_coach,
          manufacturing_year,
          no_of_master_module,
          coach_status,
          created_by,
          created_date
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          data.entity_type,
          data.coach_unique_id,
          data.coach_display_id,
          data.make_of_coach,
          data.type_of_coach,
          data.manufacturing_year,
          data.no_of_master_module,
          data.coach_status,
          data.created_by,
          created_date,
        ]
      );

      await conn.commit();
      return coachResult.insertId;
    } catch (error) {
      await conn.rollback();
      throw new Error("Failed to create coach: " + error.message);
    } finally {
      conn.release();
    }
  }

  async updateCoach(data) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Check if the new coach_unique_id already exists for another coach
      const [[duplicateCoach]] = await conn.query(
        "SELECT coach_id FROM coach_master WHERE coach_unique_id = ? AND coach_id != ?",
        [data.coach_unique_id, data.coach_id]
      );

      if (duplicateCoach) {
        throw new Error(
          `Coach Unique ID "${data.coach_unique_id}" is already used by another coach.`
        );
      }

      // Perform the update
      await conn.query(
        `UPDATE coach_master SET
          entity_type = ?,
          coach_unique_id = ?,
          coach_display_id = ?,
          make_of_coach = ?,
          type_of_coach = ?,
          manufacturing_year = ?,
          position = ?,
          no_of_master_module = ?,
          coach_status = ?,
          updated_by = ?
        WHERE coach_id = ?`,
        [
          data.entity_type,
          data.coach_unique_id,
          data.coach_display_id,
          data.make_of_coach,
          data.type_of_coach,
          data.manufacturing_year,
          data.position,
          data.no_of_master_module,
          data.coach_status,
          data.updated_by,
          data.coach_id,
        ]
      );

      await conn.commit();
      return true;
    } catch (error) {
      await conn.rollback();
      throw new Error("Failed to update coach: " + error.message);
    } finally {
      conn.release();
    }
  }

  async deleteCoach(coach_id) {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();
  
      // Step 1: Set coach_id to NULL in master_module
      await conn.query(
        'UPDATE master_module SET coach_id = NULL WHERE coach_id = ?',
        [coach_id]
      );
  
      // Step 3: Delete the coach from coach_master
      const [result] = await conn.query(
        'DELETE FROM coach_master WHERE coach_id = ?',
        [coach_id]
      );
  
      await conn.commit();
  
      if (result.affectedRows === 0) {
        return false; // Coach not found
      }
  
      return true;
    } catch (error) {
      await conn.rollback();
      throw new Error("Failed to delete coach: " + error.message);
    } finally {
      conn.release();
    }
  }
  
  
  

  // Check if coach number already exists in a train
  async coachNumberExists(trainId, coachNumber, excludeId = null) {
    let query =
      "SELECT id FROM coaches WHERE train_id = ? AND coach_number = ?";
    const params = [trainId, coachNumber];

    if (excludeId) {
      query += " AND id != ?";
      params.push(excludeId);
    }

    const [rows] = await this.pool.query(query, params);
    return rows.length > 0;
  }

  async findUnmappedCoaches() {
    const query = `
    SELECT c.*
    FROM coach_master c
    LEFT JOIN master_module mm ON c.coach_id = mm.coach_id
    WHERE mm.coach_id IS NULL
  `;

    const [rows] = await this.pool.query(query);
    return rows;
  }

  // async getAllCoaches() {
  //   const query = `SELECT * FROM coach_master`;

  //   const [rows] = await this.pool.query(query);
  //   return rows;
  // }
  async getAllCoachesWithDetails() {
    const conn = await pool.getConnection();
    try {
      const [rows] = await conn.query(`
        SELECT 
          c.coach_id,
          c.coach_unique_id,
          c.coach_display_id,
          c.position,
          c.no_of_master_module,
          c.created_by,
          c.coach_status,
          c.entity_type,
          c.manufacturing_year,
          cu.first_name AS created_by_name,
          c.created_date,
          c.updated_by,
          uu.first_name AS updated_by_name,
          c.updated_date,
          cm.name AS make_of_coach_name,
          cm.id AS make_of_coach_id,
          ct.code AS type_of_coach_code,
          ct.id AS type_of_coach_id
        FROM coach_master c
        LEFT JOIN coach_make cm ON c.make_of_coach = cm.id
        LEFT JOIN coach_type ct ON c.type_of_coach = ct.id
        LEFT JOIN user_master cu ON c.created_by = cu.user_id
        LEFT JOIN user_master uu ON c.updated_by = uu.user_id
      `);
      return rows;
    } catch (err) {
      throw new Error("Failed to fetch coaches: " + err.message);
    } finally {
      conn.release();
    }
  }

  async getCoachForTrain(trainId) {
    const query = `
      SELECT coach_id, coach_unique_id FROM coach_master
      WHERE train_id = ?
    `;
    const [rows] = await this.pool.query(query, [trainId]);
    return rows;
  }
}

module.exports = new CoachModel();