import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Initialize Firebase Cloud Messaging
  void initialize() {
    // Handle incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      print('Received foreground message: ${message.notification?.title}');
      // Handle displaying notification in the app UI
    });

    // Handle when the app is in the background but opened due to tapping on a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app from terminated state!');
      // Handle navigating to a specific page
    });
  }

  // Subscribe to a topic for notifications
  void subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
  }

  // Unsubscribe from a topic
  void unsubscribeFromTopic(String topic) {
    _firebaseMessaging.unsubscribeFromTopic(topic);
  }
}

