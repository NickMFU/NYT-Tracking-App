import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();
    String? token = await FirebaseMessaging.instance.getToken();
    print('FCM Token: $token');
  }

  static void onMessageReceived(RemoteMessage message) {
    // Handle incoming notification messages here
    // You can display a notification using a local notification plugin
    // or update the UI based on the message content (e.g., work ID)
    print('Received message: $message');
  }

  static void onMessageOpenedApp(RemoteMessage message) {
    // Handle notification taps that open the app
    // You can navigate to the AcceptWorkPage or perform other actions
    print('Notification tapped: $message');
  }
}


