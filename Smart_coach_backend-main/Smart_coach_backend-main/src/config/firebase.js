const admin = require("firebase-admin");

let serviceAccount;

try {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } else {
    const path = require("path");
    serviceAccount = require(path.join(__dirname, '../../firebase-service-account.json'));
  }

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
} catch (error) {
  console.error("Firebase Initialization Error:", error.message);
}

module.exports = admin;