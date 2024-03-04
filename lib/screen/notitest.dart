import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationTestPage extends StatefulWidget {
  @override
  _NotificationTestPageState createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _configureFirebaseListeners();
  }

  void _configureFirebaseListeners() {
    // Listen for incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Message received while app in foreground: ${message.notification!.body}");
      // You can handle the message here, such as displaying a notification or updating the UI
    });

    // Listen for incoming messages when the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened from terminated state: ${message.notification!.body}");
      // You can handle the message here, such as navigating to a specific page or performing an action
    });

    // Handle the initial notification tap when the app is in the terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print("Initial message opened from terminated state: ${message.notification!.body}");
        // You can handle the message here, such as navigating to a specific page or performing an action
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'This is a test page to receive notifications.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _subscribeToTopic('test_topic');
              },
              child: Text('Subscribe to Test Topic'),
            ),
          ],
        ),
      ),
    );
  }

  void _subscribeToTopic(String topic) {
    _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }
}