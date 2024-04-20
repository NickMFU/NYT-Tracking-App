import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class Constants {
  static const String BASE_URL = 'https://fcm.googleapis.com/fcm/send';
  static const String KEY_SERVER =
      'AAAAa2amNh0:APA91bFwHRDkkJCKaYfe2LYnYrh7B_oo3iSvBz278nPof6MVWJNySoAH8AW0_zmVqT5xg6F7Ic1g3aVMS_sUDJ5k0IkjZ3sxNCMpnFGlRES07bwJu9ABT6r2DJRG-InhaMGREfCwwx1u';
  static const String SENDER_ID = '461283669533';
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  importance: Importance.high,
  playSound: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set foreground notification presentation options
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<String?> getCheckerDeviceToken(String checkerFirstName) async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Firstname', isEqualTo: checkerFirstName)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot doc = querySnapshot.docs.first;
      final String? deviceToken = doc['DeviceToken'];
      return deviceToken;
    }
  } catch (e) {
    print('Error fetching checker device token: $e');
  }
  return null;
}

Future<String?> getgateoutDeviceToken(String gateoutrole) async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Role', isEqualTo: gateoutrole)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot doc = querySnapshot.docs.first;
      final String? deviceToken = doc['DeviceToken'];
      return deviceToken;
    }
  } catch (e) {
    print('Error fetching checker device token: $e');
  }
  return null;
}

Future<void> sendNotificationToChecker(String checkerFirstName) async {
  try {
    final String? checkerDeviceToken =
        await getCheckerDeviceToken(checkerFirstName);
    if (checkerDeviceToken != null) {
      final url = Uri.parse(Constants.BASE_URL);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.KEY_SERVER}',
      };

      final body = {
        'to': checkerDeviceToken,
        'notification': {
          'title': 'New Work Available',
          'body': 'You have a new work assignment to review.',
          'sound': 'default',
        },
      };
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully to checker.');
       showNotification('Sent work to Check complete',
              'Waiting Checker accept works');
      } else {
        print('Failed to send notification to checker: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } else {
      print('Checker device token not found.');
    }
  } catch (e) {
    print('Error sending notification to checker: $e');
  }
}

Future<void> showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your channel id',
    'your channel name',
    importance: Importance.high,
    color: Colors.blue,
    playSound: true,
    icon: '@mipmap/ic_launcher',
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

// Function to get the user ID of the checker
Future<String?> getCheckerUserID(String checkerFirstName) async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Firstname', isEqualTo: checkerFirstName)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot doc = querySnapshot.docs.first;
      final String? userID = doc.id; // Use the document ID as the user ID
      return userID;
    }
  } catch (e) {
    print('Error fetching checker user ID: $e');
  }
  return null;
}

Future<void> sendNotificationToGateOut() async {
  try {
    // Device token to send notification
    String deviceToken =
        'eJ6YHcYzTJG0Lv7FXuhym7:APA91bFhf8K4FVQaNWdgS-xx9G-FuS_8OQ0oGCr6rZ8iWRhVLKR2-PODyWgZ1svHzVf_BzuHFx0w8kO-e0KIvD1WqSPscoPMaFfCddjbW-uUJ1SLbtcbQ4oK0N5fuSrD3OenJ_lW8xgd';

    // Construct the notification payload
    var notification = {
      'notification': {
        'title': 'New Work Available',
        'body': 'You have a new work assignment to review.',
        'sound': 'default'
      },
      'to': deviceToken,
    };

    // Send the notification
    final response = await http.post(
      Uri.parse(
          Constants.BASE_URL), // Replace with your FCM send endpoint
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAa2amNh0:APA91bFwHRDkkJCKaYfe2LYnYrh7B_oo3iSvBz278nPof6MVWJNySoAH8AW0_zmVqT5xg6F7Ic1g3aVMS_sUDJ5k0IkjZ3sxNCMpnFGlRES07bwJu9ABT6r2DJRG-InhaMGREfCwwx1u', // Replace with your Firebase server key
      },
      body: jsonEncode(notification),
    );

    // Check the response status
    if (response.statusCode == 200) {
      print(
          'Notification sent successfully to Gate Out user with device token: $deviceToken');
    } else {
      print(
          'Failed to send notification to Gate Out user with device token: $deviceToken');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification to Gate Out user: $e');
  }
}

Future<void> NotificationToGateOut() async {
  try {
    // Get all users with the role "Gate out"
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Employee').where('Role', isEqualTo: 'Dispatcher').get();
    // Extract the tokens
    List tokens = querySnapshot.docs.map((doc) => doc['DeviceToken']).toList();
    // Prepare the notification message
    var notification = {
      'notification': {'title': 'New Work Available', 'body': 'You have a new work assignment to review.', 'sound': 'default'},
      'registration_ids': tokens,
    };
    // Send the notification to FCM
    final response = await http.post(
      Uri.parse(Constants.BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.KEY_SERVER}',
      },
      body: jsonEncode(notification),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully to Gate Out users.');
      // Trigger local notification
      showNotification('Send work back to Dispatcher Complete', 'Waiting Dispatcher update work.');
    } else {
      print('Failed to send notification to Gate Out users: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification to Gate Out users: $e');
  }
}


Future<void> sendNotification(String userToken) async {
  try {
    // Server key from Firebase Console
    String serverKey =
        'AAAAa2amNh0:APA91bFwHRDkkJCKaYfe2LYnYrh7B_oo3iSvBz278nPof6MVWJNySoAH8AW0_zmVqT5xg6F7Ic1g3aVMS_sUDJ5k0IkjZ3sxNCMpnFGlRES07bwJu9ABT6r2DJRG-InhaMGREfCwwx1u';

    // Firebase Cloud Messaging endpoint
    String url = 'https://fcm.googleapis.com/fcm/send';

    // Construct payload
    Map<String, dynamic> payload = {
      'notification': {
        'title': 'Test Notification',
        'body': 'This is a test notification!',
      },
      'to': userToken,
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
  } catch (e) {
    print('Error sending notification: $e');
  }
}
