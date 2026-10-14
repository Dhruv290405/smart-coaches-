const twilio = require('twilio');

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

const twilioClient =
  accountSid && authToken ? twilio(accountSid, authToken) : null;

const otpStore = new Map();
const verifiedMobiles = new Set();

const OTP_EXPIRY_MS = 5 * 60 * 1000;

setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of otpStore.entries()) {
    if (now - entry.createdAt > OTP_EXPIRY_MS) otpStore.delete(key);
  }
}, 60 * 1000);

function buildVoiceTwiML(otp) {
  const digits = otp.split('').join(', ');
  return (
    `<Response>` +
    `<Say voice="alice" language="en">Your verification code is, ${digits}. I repeat, ${digits}.</Say>` +
    `</Response>`
  );
}

async function placeVoiceOtpCall(mobileNumber, otp) {
  if (!twilioClient) {
    throw new Error(
      'OTP service is not configured (TWILIO_ACCOUNT_SID/TWILIO_AUTH_TOKEN missing). Please contact the administrator.'
    );
  }
  if (!twilioPhoneNumber) {
    throw new Error('OTP service is not configured (TWILIO_PHONE_NUMBER missing). Please contact the administrator.');
  }
  await twilioClient.calls.create({
    to: mobileNumber,
    from: twilioPhoneNumber,
    twiml: buildVoiceTwiML(otp),
  });
  console.log(`[OTP] Twilio voice call placed to ${mobileNumber}`);
}

function isConfigured() {
  return !!(twilioClient && twilioPhoneNumber);
}

const smsService = {
  isConfigured,

  async sendOtp(mobileNumber) {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore.set(mobileNumber, { otp, createdAt: Date.now() });

    console.log(`[OTP] OTP for ${mobileNumber}: ${otp}`);

    try {
      await placeVoiceOtpCall(mobileNumber, otp);
    } catch (error) {
      console.error(`[OTP] Twilio voice call failed for ${mobileNumber}: ${error.message}`);
      otpStore.delete(mobileNumber);
      if (error.code === 20003 || /account .*not active|authentication failed/i.test(error.message)) {
        throw new Error(
          'OTP service is unavailable because the Twilio account is inactive or its credentials are invalid. Please contact the administrator.'
        );
      }
      throw error;
    }

    return {
      success: true,
      message: 'OTP sent successfully',
    };
  },

  isVerified(mobileNumber) { return verifiedMobiles.has(mobileNumber); },
  consumeVerification(mobileNumber) { verifiedMobiles.delete(mobileNumber); },

  verifyOtp(mobileNumber, otp) {
    const entry = otpStore.get(mobileNumber);
    if (!entry) return { success: false, message: 'No OTP requested for this number' };
    if (Date.now() - entry.createdAt > OTP_EXPIRY_MS) {
      otpStore.delete(mobileNumber);
      return { success: false, message: 'OTP has expired' };
    }
    if (entry.otp !== otp) return { success: false, message: 'Invalid OTP' };

    otpStore.delete(mobileNumber);
    verifiedMobiles.add(mobileNumber);
    return { success: true, message: 'OTP verified successfully' };
  },
};

module.exports = smsService;