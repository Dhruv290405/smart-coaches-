const otpStore = new Map();

const OTP_EXPIRY_MS = 5 * 60 * 1000;

setInterval(() => {
  const now = Date.now();
  for (const [key, entry] of otpStore.entries()) {
    if (now - entry.createdAt > OTP_EXPIRY_MS) otpStore.delete(key);
  }
}, 60 * 1000);

const smsService = {
  async sendOtp(mobileNumber) {
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    otpStore.set(mobileNumber, { otp, createdAt: Date.now() });

    console.log(`[SMS] OTP for ${mobileNumber}: ${otp}`);

    return { success: true, message: 'OTP sent successfully', otp };
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
