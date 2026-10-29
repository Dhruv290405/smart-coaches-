const axios = require('axios');

const API_KEY = process.env.TWO_FACTOR_API_KEY || process.env.AIRTEL_SMS_KEY || '';
const BASE = process.env.TWO_FACTOR_BASE_URL || 'https://2factor.in/API/V1';

/**
 * Send an OTP via SMS using 2factor.in
 * @param {string} phone - 10-digit Indian mobile number
 * @returns {Promise<{success:boolean, sessionId:string|null, error:string|null}>}
 */
async function sendOtp(phone) {
  if (!API_KEY) return { success: false, sessionId: null, error: 'SMS API key not configured' };
  const clean = String(phone).replace(/\D/g, '').slice(-10);
  try {
    const url = `${BASE}/${API_KEY}/SMS/${clean}/AUTOGEN`;
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
  if (!API_KEY) return { success: false, error: 'SMS API key not configured' };
  try {
    const url = `${BASE}/${API_KEY}/SMS/VERIFY/${sessionId}/${otp}`;
    const { data } = await axios.get(url, { timeout: 15000 });
    if (data && data.Status === 'Success') return { success: true, error: null };
    return { success: false, error: data?.Details || 'OTP verify failed' };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

/**
 * Send a transactional SMS (DLT template) via 2factor.in
 * @param {string} phone
 * @param {string} message
 * @param {string} [templateId] - DLT template id
 */
async function sendAlert(phone, message, templateId) {
  if (!API_KEY) return { success: false, error: 'SMS API key not configured' };
  const clean = String(phone).replace(/\D/g, '').slice(-10);
  try {
    const params = new URLSearchParams();
    params.append('To', clean);
    params.append('From', process.env.SMS_SENDER_ID || 'SMRTCH');
    params.append('Msg', message);
    if (templateId) params.append('TemplateId', templateId);
    const url = `${BASE}/${API_KEY}/ADDON_SERVICES/SEND/TSMS`;
    const { data } = await axios.post(url, params.toString(), {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      timeout: 15000,
    });
    if (data && (data.Status === 'Success' || data.status === 'success')) {
      return { success: true, error: null };
    }
    return { success: false, error: data?.Details || data?.message || 'SMS send failed' };
  } catch (err) {
    return { success: false, error: err.message };
  }
}

module.exports = { sendOtp, verifyOtp, sendAlert };