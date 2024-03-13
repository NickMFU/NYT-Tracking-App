// index.js (Cloud Function file)

const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendWorkNotification = functions.firestore
  .document('works/{workId}')
  .onCreate(async (snapshot, context) => {
    const workData = snapshot.data();
    const checkerId = workData.employeeId;

    // Get message details (adapt these based on your notification service)
    const message = {
      notification: {
        title: 'New Work Assigned',
        body: `Work ID: ${workData.workID} has been assigned to you.`,
      },
      android: {
        priority: 'high',
        vibrate: true,
      },
      token: await getCheckerDeviceToken(checkerId), // Replace with your logic to retrieve device token
    };

    // Send notification using your notification service (e.g., Firebase Cloud Messaging)
    await admin.messaging().send(message);
  });

// Function to retrieve device token (replace with your implementation)
async function getCheckerDeviceToken(checkerId) {
  // Implement logic to fetch the device token associated with the checker ID
  // This could involve querying a separate collection storing device tokens
  // or using a user authentication system with device token registration.
  console.warn('Placeholder implementation for retrieving device token.');
  return 'YOUR_PLACEHOLDER_TOKEN'; // Replace with actual token retrieval logic
}
