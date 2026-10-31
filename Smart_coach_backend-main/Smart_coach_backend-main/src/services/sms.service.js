const axios = require('axios');

const BASE = process.env.TWO_FACTOR_BASE_URL || 'https://2factor.in/API/V1';

/**
 * Send an OTP via SMS using 2factor.in
 * @param {string} phone - 10-digit Indian mobile number
 * @returns {Promise<{success:boolean, sessionId:string|null, error:string|null}>}
 */
async function sendOtp(phone) {
  const apiKey = process.env.TWO_FACTOR_API_KEY || process.env.AIRTEL_SMS_KEY || '';
  if (!apiKey) return { success: false, sessionId: null, error: 'SMS API key not configured' };
  const clean = String(phone).replace(/\D/g, '').slice(-10);
  try {
    const url = `${BASE}/${apiKey}/SMS/${clean}/AUTOGEN`;
    const { data } = await axios.get(url, { timeout: 15000 });
    if (data && data.Status === 'Success') {
      return { success: true, sessionId: data.Details, error: null };
    }
    return { success: false, sessionId: null, error: data?.Details || 'OTP send failed' };
  } catch (err) {
    return { success: false, sessionId: null, error: err.message };
  }
}

/**
 * Verify an OTP via 2factor.in
 */
async function verifyOtp(sessionId, otp) {
  const apiKey = process.env.TWO_FACTOR_API_KEY || process.env.AIRTEL_SMS_KEY || '';
  if (!apiKey) return { success: false, error: 'SMS API key not configured' };
  try {
    const url = `${BASE}/${apiKey}/SMS/VERIFY/${sessionId}/${otp}`;
    const { data } = await axios.get(url, { timeout: 15000 });
    if (data && data.Status === 'Success') return { success: true, error: null };
    return { success: false, error: data?.Details || 'OTP verify failed' };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

/**
 * Send a transactional SMS (DLT template) via 2factor.in
 * @param {string} phone - 10-digit mobile number
 * @param {string} message - Formatted alert message or dynamic variable
 * @param {string} [templateId] - DLT template id (fallback / reference)
 */
async function sendAlert(phone, message, templateId) {
  const apiKey = process.env.TWO_FACTOR_API_KEY || process.env.AIRTEL_SMS_KEY || '';
  if (!apiKey) return { success: false, error: 'SMS API key not configured' };
  const clean = String(phone).replace(/\D/g, '').slice(-10);
  if (!clean || clean.length < 10) {
    return { success: false, error: 'Invalid phone number' };
  }

  try {
    const templateName = process.env.TWO_FACTOR_TEMPLATE_NAME || 'SmartCoaches Railway Live Alerts';
    const senderId = process.env.SMS_SENDER_ID || 'MIRTHA';

    // Extract dynamic variable part if the full wrapped message was provided
    let var1 = message || '';
    const prefix = 'SmartCoaches Railway Coach Monitoring Alert:';
    if (var1.startsWith(prefix)) {
      var1 = var1.substring(prefix.length).trim();
    }
    if (var1.includes('. Immediate action required for')) {
      var1 = var1.split('. Immediate action required for')[0].trim();
    }
    var1 = var1.replace(/\.+$/, '');

    const payload = {
      From: senderId,
      To: clean,
      TemplateName: templateName,
      VAR1: var1,
    };

    const url = `${BASE}/${apiKey}/ADDON_SERVICES/SEND/TSMS`;
    const { data } = await axios.post(url, payload, {
      headers: { 'Content-Type': 'application/json' },
      timeout: 15000,
    });

    if (data && (data.Status === 'Success' || data.status === 'success')) {
      console.log(`✅ [SMS] Alert sent successfully to ${clean} (Session: ${data.Details})`);
      return { success: true, sessionId: data.Details, error: null };
    }
    return { success: false, error: data?.Details || data?.message || 'SMS send failed' };
  } catch (err) {
    console.error('❌ [SMS] Send error:', err.response?.data || err.message);
    return { success: false, error: err.response?.data?.Details || err.message };
  }
}

module.exports = { sendOtp, verifyOtp, sendAlert };
