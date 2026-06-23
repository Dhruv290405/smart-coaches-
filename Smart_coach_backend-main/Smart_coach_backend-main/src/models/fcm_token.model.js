const { pool } = require('../config/db');

async function saveFcm({ user_id, fcm_token }) {
    const [result] = await pool.query(
        "INSERT IGNORE INTO user_fcm_tokens (user_id, fcm_token) VALUES (?, ?)",
        [user_id, fcm_token]
    );

    console.log('Inserting FCM token:', { user_id, fcm_token });

    return {
        id: result.insertId,
        user_id,
        fcm_token
    };
}

module.exports = {
    saveFcm
};
