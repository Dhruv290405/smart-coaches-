const supabaseAdmin = require('../config/supabaseAdmin');

async function saveFcm({ user_id, fcm_token }) {
    const { data, error } = await supabaseAdmin
        .from('user_fcm_tokens')
        .upsert([{ user_id, fcm_token }], { onConflict: 'user_id,fcm_token' })
        .select();

    console.log('Inserting FCM token:', { user_id, fcm_token });

    return {
        id: data?.[0]?.id,
        user_id,
        fcm_token
    };
}

module.exports = {
    saveFcm
};
