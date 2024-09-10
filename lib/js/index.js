// index.js in your Firebase Functions directory
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNewWorkNotification = functions.firestore
  .document('works/{workId}')
  .onCreate(async (snap, context) => {
    const workData = snap.data();
    const title = 'New Work Notification';
    const body = `New work available: ${workData.blNo}`;

    // Get device tokens of relevant users (e.g., users with the role 'Checker' or 'Gate out')
    const tokens = await getRelevantUserTokens(workData);

    // Send a message to the devices corresponding to the provided tokens.
    if (tokens.length > 0) {
      const message = {
        notification: {
          title: title,
          body: body,
        },
        tokens: tokens,
      };

      try {
        await admin.messaging().sendMulticast(message);
        console.log('Notification sent successfully');
      } catch (error) {
        console.error('Error sending notification:', error);
      }
    }
  });

// Function to fetch relevant user tokens from Firestore based on roles
async function getRelevantUserTokens(workData) {
  const usersSnapshot = await admin
    .firestore()
    .collection('Employee')
    .where('Role', 'in', ['Checker', 'Gate out']) // Add specific roles if needed
    .get();

  const tokens = [];
  usersSnapshot.forEach((doc) => {
    const user = doc.data();
    if (user.fcmToken) {
      tokens.push(user.fcmToken); // Assume users have fcmToken field
    }
  });

  return tokens;
}
