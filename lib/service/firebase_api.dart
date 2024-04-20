import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<String?> getFCMToken() async {
  return await _firebaseMessaging.getToken();
}

Future<void> sendPushNotification(String fcmToken) async {
  // Replace 'YOUR_SERVER_KEY' with your Firebase project's server key
  String serverKey = 'AAAAa2amNh0:APA91bFwHRDkkJCKaYfe2LYnYrh7B_oo3iSvBz278nPof6MVWJNySoAH8AW0_zmVqT5xg6F7Ic1g3aVMS_sUDJ5k0IkjZ3sxNCMpnFGlRES07bwJu9ABT6r2DJRG-InhaMGREfCwwx1u';

  // Firebase Cloud Messaging endpoint
  String url = 'https://fcm.googleapis.com/fcm/send';

  // Construct payload
  Map<String, dynamic> payload = {
    'notification': {
      'title': 'Test Notification',
      'body': 'This is a test notification!',
    },
    'to': fcmToken,
  };

  // Send the notification
  await http.post(
    Uri.parse(url),
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    },
    body: jsonEncode(payload),
  );
}

class PushNotificationTestButton extends StatefulWidget {
  @override
  _PushNotificationTestButtonState createState() => _PushNotificationTestButtonState();
}

class _PushNotificationTestButtonState extends State<PushNotificationTestButton> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _retrieveFCMToken();
  }

  Future<void> _retrieveFCMToken() async {
    String? token = await getFCMToken();
    setState(() {
      _fcmToken = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (_fcmToken != null) {
          sendPushNotification(_fcmToken!);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('FCM token not available'),
            ),
          );
        }
      },
      child: Text('Send Test Notification'),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(
        title: Text('Push Notification Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PushNotificationTestButton(),
          ],
        ),
      ),
    ),
  ));
}
