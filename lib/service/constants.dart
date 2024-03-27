import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namyong_demo/main.dart';

class Constants {
  static const String BASE_URL = 'https://fcm.googleapis.com/fcm/send';
  static const String KEY_SERVER =
      'AAAAa2amNh0:APA91bFwHRDkkJCKaYfe2LYnYrh7B_oo3iSvBz278nPof6MVWJNySoAH8AW0_zmVqT5xg6F7Ic1g3aVMS_sUDJ5k0IkjZ3sxNCMpnFGlRES07bwJu9ABT6r2DJRG-InhaMGREfCwwx1u';
  static const String SENDER_ID = '461283669533';
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

Future<void> sendNotificationToChecker(String checkerFirstName) async {
  try {
    final String? checkerToken = await getCheckerDeviceToken(checkerFirstName);
    if (checkerToken != null) {
      final url = Uri.parse(Constants.BASE_URL);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=${Constants.KEY_SERVER}',
      };
      final body = {
        'to': checkerToken,
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
        // Trigger local notification
        showNotification('New Work Available', 'You have a new work assignment to review.');
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
    'your channel id', // Channel ID
    'your channel name', // Channel Name
     // Channel Description
    importance: Importance.high,
    color: Colors.blue,
    playSound: true,
     icon: '@mipmap/ic_launcher', // Icon name from the drawable resources
  );
  
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title, // Notification title
    body, // Notification body
    platformChannelSpecifics,
  );
}

Future<void> sendNotificationToGateOut() async {
  try {
    // Get all users with the role "Gate out"
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Employee').where('Role', isEqualTo: 'Gate out').get();
    // Extract the tokens
    List tokens = querySnapshot.docs.map((doc) => doc['token']).toList();
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
      showNotification('New Work Available', 'You have a new work assignment to review.');
    } else {
      print('Failed to send notification to Gate Out users: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification to Gate Out users: $e');
  }
}