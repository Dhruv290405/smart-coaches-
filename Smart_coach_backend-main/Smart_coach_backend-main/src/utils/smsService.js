const twilio = require('twilio');

const accountSid = process.env.TWILIO_ACCOUNT_SID;
const authToken = process.env.TWILIO_AUTH_TOKEN;
const twilioPhoneNumber = process.env.TWILIO_PHONE_NUMBER;

const twilioClient =
  accountSid && authToken ? twilio(accountSid, authToken) : null;

const otpStore = new Map();

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
    const msg =
      'Twilio is not configured (TWILIO_ACCOUNT_SID/AUTH_TOKEN missing). Set these env vars on Railway.';
    console.error(`[OTP] ${msg}`);
    throw new Error(msg);
  }
  await twilioClient.calls.create({
    to: mobileNumber,
    from: twilioPhoneNumber,
    twiml: buildVoiceTwiML(otp),
  });
  console.log(`[OTP] Twilio voice call placed to ${mobileNumber}`);
}

const smsService = {
  async sendOtp(mobileNumber) {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore.set(mobileNumber, { otp, createdAt: Date.now() });

    console.log(`[OTP] OTP for ${mobileNumber}: ${otp}`);

    try {
      await placeVoiceOtpCall(mobileNumber, otp);
    } catch (error) {
      console.error(`[OTP] Twilio voice call failed for ${mobileNumber}: ${error.message}`);
      throw error;
    }

    const isProduction = process.env.NODE_ENV === 'production';
    return {
      success: true,
      message: 'OTP sent successfully',
      otp: isProduction ? undefined : otp,
    };
  },

  verifyOtp(mobileNumber, otp) {
    const entry = otpStore.get(mobileNumber);
    if (!entry) return { success: false, message: 'No OTP requested for this number' };
    if (Date.now() - entry.createdAt > OTP_EXPIRY_MS) {
      otpStore.delete(mobileNumber);
      return { success: false, message: 'OTP has expired' };
    }
    if (entry.otp !== otp) return { success: false, message: 'Invalid OTP' };

    otpStore.delete(mobileNumber);
    return { success: true, message: 'OTP verified successfully' };
  },
};

module.exports = smsService;