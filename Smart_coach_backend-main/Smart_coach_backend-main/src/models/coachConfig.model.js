const { pool } = require("../config/db");

class CoachConfigModel {
    async getDetailsByCoach(coachNo) {
        const query = `SELECT * FROM coach_configurations WHERE coach_no = ?`;
        const [rows] = await pool.query(query, [coachNo]);
        return rows[0];
    }
}

module.exports = new CoachConfigModel();