const supabaseAdmin = require('../config/supabaseAdmin');

async function saveFcm({ user_id, fcm_token }) {
    // A device token has one active account owner; remove stale ownership first.
    const { error: ownershipError } = await supabaseAdmin
        .from('user_fcm_tokens').delete().eq('fcm_token', fcm_token).neq('user_id', user_id);
    if (ownershipError) throw ownershipError;

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

async function deleteFcm({ user_id, fcm_token }) { const { error } = await supabaseAdmin.from('user_fcm_tokens').delete().eq('user_id', user_id).eq('fcm_token', fcm_token); if (error) throw error; }

module.exports = { saveFcm, deleteFcm };
