const BREVO_API_URL = 'https://api.brevo.com/v3/smtp/email';
const OTP_EXPIRY_MS = 5 * 60 * 1000;

const otpStore = new Map();
const verifiedEmails = new Set();

setInterval(() => {
  const now = Date.now();
  for (const [email, entry] of otpStore.entries()) {
    if (now - entry.createdAt > OTP_EXPIRY_MS) otpStore.delete(email);
  }
}, 60 * 1000);

function normaliseEmail(email) {
  return email.trim().toLowerCase();
}

function getConfigurationError() {
  if (!process.env.BREVO_API_KEY) {
    return 'OTP service is not configured (BREVO_API_KEY missing). Please contact the administrator.';
  }
  if (!process.env.BREVO_SENDER_EMAIL) {
    return 'OTP service is not configured (BREVO_SENDER_EMAIL missing). Please contact the administrator.';
  }
  return null;
}

async function sendBrevoEmail(email, otp) {
  const configurationError = getConfigurationError();
  if (configurationError) throw new Error(configurationError);

  const senderName = process.env.BREVO_SENDER_NAME || 'Smart Coach';
  const response = await fetch(BREVO_API_URL, {
    method: 'POST',
    headers: {
      accept: 'application/json',
      'api-key': process.env.BREVO_API_KEY,
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      sender: { name: senderName, email: process.env.BREVO_SENDER_EMAIL },
      to: [{ email }],
      subject: 'Your Smart Coach verification code',
      htmlContent: `
        <p>Your Smart Coach verification code is:</p>
        <p style="font-size: 24px; font-weight: bold; letter-spacing: 4px;">${otp}</p>
        <p>This code expires in 5 minutes. If you did not request it, you can ignore this email.</p>
      `,
    }),
  });

  if (!response.ok) {
    const details = await response.text();
    console.error(`[OTP] Brevo email failed (${response.status}): ${details}`);
    throw new Error('Unable to send OTP email. Please try again later.');
  }
}

module.exports = {
  async sendOtp(email) {
    const normalisedEmail = normaliseEmail(email);
    const otp = randomInt(100000, 1000000).toString();

    await sendBrevoEmail(normalisedEmail, otp);
    otpStore.set(normalisedEmail, { otp, createdAt: Date.now() });
    console.log(`[OTP] Brevo verification email sent to ${normalisedEmail}`);

    return { success: true, message: 'OTP sent successfully' };
  },

  isVerified(email) {
    return verifiedEmails.has(normaliseEmail(email));
  },

  consumeVerification(email) {
    verifiedEmails.delete(normaliseEmail(email));
  },

  verifyOtp(email, otp) {
    const normalisedEmail = normaliseEmail(email);
    const entry = otpStore.get(normalisedEmail);
    if (!entry) return { success: false, message: 'No OTP requested for this email' };
    if (Date.now() - entry.createdAt > OTP_EXPIRY_MS) {
      otpStore.delete(normalisedEmail);
      return { success: false, message: 'OTP has expired' };
    }
    if (entry.otp !== otp) return { success: false, message: 'Invalid OTP' };

    otpStore.delete(normalisedEmail);
    verifiedEmails.add(normalisedEmail);
    return { success: true, message: 'OTP verified successfully' };
  },
};
const { randomInt } = require('crypto');
