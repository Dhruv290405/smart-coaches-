const BaseModel = require('./base.model');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

class UserModel extends BaseModel {
  constructor() {
    super('user_master');
  }

  async create(userData) {
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(userData.password, salt);

    const conn = await this.pool.getConnection();
    try {
      await conn.beginTransaction();

      // 1. Insert into user_master
      const [result] = await conn.query(
        `INSERT INTO user_master (
        first_name,
        last_name,
        email,
        password_hash,
        mobile_number,
        gender,
        organisation_type,
        organisation_name,
        zone_id,
        division_id,
        role_id,
        status,
        approval_status,
        created_date,
        employee_id,
        pan_card_no,
        pan_card_image,
        aadhar_no,
        aadhar_img,
        company_id,
        user_image
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          userData.first_name,
          userData.last_name || null,
          userData.email,
          hashedPassword,
          userData.mobile_number,
          userData.gender || null,
          userData.organisation_type,
          userData.organisation_name || null,
          userData.zone_id,
          userData.division_id,
          userData.role_id,
          userData.status || 'Inactive',
          userData.approval_status || 'Pending',
          new Date(), // created_date
          userData.employee_id || null,
          userData.pan_card_no || null,
          userData.pan_card_image || null,
          userData.aadhar_no || null,
          userData.aadhar_img || null,
          userData.company_id || null,
          userData.user_image || null
        ]
      );

      const userId = result.insertId;

      // 2. Insert into user_region_mapping 
      if (userData.region_id && Array.isArray(userData.region_id) && userData.region_id.length > 0) {
        const regionValues = userData.region_id.map(id => [userId, id]);
        await conn.query(
          'INSERT INTO user_region_mapping (user_id, region_id) VALUES ?',
          [regionValues]
        );
      }

      // 3. Insert into user_train_mapping
      if (userData.train_ids && Array.isArray(userData.train_ids) && userData.train_ids.length > 0) {
        const trainValues = userData.train_ids.map(id => [userId, id]);
        await conn.query(
          'INSERT INTO user_train_mapping (user_id, train_id) VALUES ?',
          [trainValues]
        );
      }

      await conn.commit();

      const [rows] = await conn.query(
        'SELECT * FROM user_master WHERE user_id = ?',
        [userId]
      );

      const user = rows[0];
      if (user) {
        delete user.password_hash;
      }

      return user;
    } catch (error) {
      await conn.rollback();
      console.error("Database Transaction Error:", error);
      throw error;
    } finally {
      conn.release();
    }
  }

  async findByEmail(email) {
    const [users] = await this.pool.query(
      'SELECT * FROM user_master WHERE email = ?',
      [email]
    );
    return users[0] || null;
  }

  async validatePassword(user, password) {
    return await bcrypt.compare(password, user.password_hash);
  }

  generateAuthToken(user) {
    const payload = {
      user_id: user.user_id,
      email: user.email,
      role_id: user.role_id
    };

    return jwt.sign(
      payload,
      process.env.JWT_SECRET || 'your_jwt_secret',
      { expiresIn: '30d' }
    );
  }

  async getPendingUsersByScope(currentUser, filters = {}) {
    const queryParams = [];
    let whereClause = 'WHERE u.role_id > ?'; // base filter
    queryParams.push(currentUser.role_id);

    switch (currentUser.role_id) {
      case 3: // Admin
        whereClause += ` AND (
        (u.role_id = 4 AND u.zone_id = ?)
        OR (u.role_id IN (5, 6) AND u.division_id IN (
          SELECT division_id FROM division_master WHERE zone_id = ?
        ))
        OR (u.role_id = 7 AND u.region_id IN (
          SELECT region_id FROM region_master WHERE division_id IN (
            SELECT division_id FROM division_master WHERE zone_id = ?
          )
        ))
      )`;
        queryParams.push(currentUser.zone_id, currentUser.zone_id, currentUser.zone_id);
        break;

      case 4: // Manager
        whereClause += ` AND (
        (u.role_id IN (5, 6) AND u.division_id = ?)
        OR (u.role_id = 7 AND u.region_id IN (
          SELECT region_id FROM region_master WHERE division_id = ?
        ))
      )`;
        queryParams.push(currentUser.division_id, currentUser.division_id);
        break;

      case 5: // Editor
        whereClause += ` AND (
        u.role_id = 7 AND u.region_id IN (
          SELECT region_id FROM region_master WHERE division_id = ?
        )
      )`;
        queryParams.push(currentUser.division_id);
        break;
    }

    if (filters.status) {
      const statuses = Array.isArray(filters.status) ? filters.status : [filters.status];
      const placeholders = statuses.map(() => '?').join(', ');
      whereClause += ` AND u.approval_status IN (${placeholders})`;
      queryParams.push(...statuses);
    }

    if (filters.organisation_type) {
      const orgTypes = Array.isArray(filters.organisation_type) ? filters.organisation_type : [filters.organisation_type];
      const placeholders = orgTypes.map(() => '?').join(', ');
      whereClause += ` AND u.organisation_type IN (${placeholders})`;
      queryParams.push(...orgTypes);
    }

    if (filters.from_date) {
      whereClause += ` AND DATE(u.created_date) >= ?`;
      queryParams.push(filters.from_date);
    }

    if (filters.to_date) {
      whereClause += ` AND DATE(u.created_date) <= ?`;
      queryParams.push(filters.to_date);
    }

    const [rows] = await this.pool.query(
      `
    SELECT 
      u.user_id,
      u.first_name,
      u.last_name,
      u.email,
      u.mobile_number,
      u.organisation_type,
      u.created_date,
      r.name AS role,
      u.employee_id,
      u.zone_id,
      z.name AS zone_name,
      u.division_id,
      d.name AS division_name,
      u.pan_card_no,
      u.aadhar_no,
      u.role_id,
      u.approval_status,
      IFNULL(GROUP_CONCAT(DISTINCT urm.region_id), u.region_id) AS region_ids,
      IFNULL(GROUP_CONCAT(DISTINCT rm_map.name), rm.name) AS region_names
    FROM user_master u
    JOIN role_master r ON u.role_id = r.role_id
    LEFT JOIN user_region_mapping urm ON u.user_id = urm.user_id
    LEFT JOIN region_master rm_map ON urm.region_id = rm_map.region_id
    LEFT JOIN zone_master z ON u.zone_id = z.zone_id
    LEFT JOIN division_master d ON u.division_id = d.division_id
    LEFT JOIN region_master rm ON u.region_id = rm.region_id
    ${whereClause}
    GROUP BY u.user_id
    `,
      queryParams
    );

    return rows;
  }

  async approveUserWithRoleChange(userId, approvalStatus, roleId) {
    let updateQuery = `UPDATE user_master SET updated_date = NOW()`;
    const params = [];

    if (approvalStatus !== undefined && approvalStatus !== null && approvalStatus !== '') {
      updateQuery += `, approval_status = ?`;
      params.push(approvalStatus);
    }

    if (roleId !== undefined && roleId !== null && roleId !== '') {
      updateQuery += `, role_id = ?`;
      params.push(roleId);
    }

    updateQuery += ` WHERE user_id = ?`;
    params.push(userId);

    await this.pool.query(updateQuery, params);
  }

  isApproverAuthorized(currentUser, targetUser, currentUserRole) {
    return true
  }

  async findOne(criteria) {
    const key = Object.keys(criteria)[0];
    const value = criteria[key];
    const [rows] = await this.pool.query(
      `SELECT u.*, z.name as zone_name, d.name as division_name, rm.name as region_name 
       FROM user_master u
       LEFT JOIN zone_master z ON u.zone_id = z.zone_id
       LEFT JOIN division_master d ON u.division_id = d.division_id
       LEFT JOIN region_master rm ON u.region_id = rm.region_id
       WHERE u.${key} = ?`,
      [value]
    );
    return rows[0] || null;
  }
  
  async update(userId, updateData) {
    const fields = [];
    const values = [];

    Object.keys(updateData).forEach(key => {
      if (updateData[key] !== undefined) {
        fields.push(`${key} = ?`);
        values.push(updateData[key]);
      }
    });

    if (fields.length === 0) return null;

    values.push(userId);
    const query = `UPDATE user_master SET ${fields.join(', ')}, updated_date = NOW() WHERE user_id = ?`;
    
    await this.pool.query(query, values);
    return true;
  }

  async getFullUserDetail(userId) {
    const [rows] = await this.pool.query(
      `SELECT 
        u.*, 
        r.name AS role_name,
        z.name AS zone_name,
        d.name AS division_name,
        rm.name AS region_name,
        (SELECT GROUP_CONCAT(train_id) FROM user_train_mapping WHERE user_id = u.user_id) AS mapped_trains
      FROM user_master u
      LEFT JOIN role_master r ON u.role_id = r.role_id
      LEFT JOIN zone_master z ON u.zone_id = z.zone_id
      LEFT JOIN division_master d ON u.division_id = d.division_id
      LEFT JOIN region_master rm ON u.region_id = rm.region_id
      WHERE u.user_id = ?`,
      [userId]
    );
    return rows[0] || null;
  }
}

module.exports = new UserModel();