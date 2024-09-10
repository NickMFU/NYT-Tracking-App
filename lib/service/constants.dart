import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;

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

Future<String?> getdispatcherDeviceToken(String distoken) async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('work')
        .where('dispatcherID', isEqualTo: distoken)
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
    final String? checkerDeviceToken = await getCheckerDeviceToken(checkerFirstName);
    if (checkerDeviceToken != null) {
      final notification = {
      'to': checkerDeviceToken,
      'notification': {
        'title': 'New Work Available',
        'body': 'You have a new work assignment to review please check your notification.',
        'icon': 'ic_notification',
        'sound': 'default',
      },
    };// Send the notification using FCM
    final response = await http.post(
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.KEY_SERVER}',
        },
        body: jsonEncode(notification),
      );
      if (response.statusCode == 200) {
        print('Notification sent successfully to checker.');
        
        // Show a local notification when sending notification is successful
        await showNotification(
          'Sent work to Checker complete',
          'Waiting Checker to accept works',
        );
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
    'your_channel_id',
    'your_channel_name',
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


Future<void> sendNotificationToGateOut() async {
  try {
    // Device token to send notification
    String deviceToken =
        'fUDZVoROQTWfUvY9_JqsEb:APA91bErpGYU0zQGcmFx9fpSzcItJXkfwTKwYoTnkzB92PitPxpTGwBa8XjZCl9TYB2ongO33gS39tiMnflOsn9v00iez1ci1ZA8yZlp5O0Uhe0nDSOZZQtycjtjLvR3GR5r7RmZaQ35';
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
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.KEY_SERVER}',
        },
        body: jsonEncode(notification),
      );
      
    await showNotification(
        'Send work to Gate Out complete',
        'Waiting Dispatcher to update work.',
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

Future<void> sendNotificationToCdevice() async {
  try {
    // Device token to send notification
    String deviceToken =
        'dMEkORusS-my45BJ1w1X76:APA91bFFwgj5XkaXALfJxhTnyjQPeXEQDHJhq7GdWM8vceejjukDQZrz2Mphrp8kCtTJ2PRfHCc-96r_rNmS8t2Lt6E5Jp-t9IVxcaDO-X4hEblvRuI8LMoWI86joKAzZyXFCCUldm00';
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
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.KEY_SERVER}',
        },
        body: jsonEncode(notification),
      );
      await showNotification(
          'Sent work to Checker complete',
          'Waiting Checker to accept works',
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

Future<void> sendNotificationToDdevice() async {
  try {
    // Device token to send notification
    String deviceToken =
        'cEUy8ewjS3mBFCzYnRsY-B:APA91bFu4A9kg_PcJX9fw40nXC9AzPS9mO924pcK86bOF_KEDvRxWgozPx27olv2KtdFXlTPBM0R8VlcL_17ET7o6SgsM1w4ZbzO1WOW8j3cpnAloEd0O-_9q1wweRE8WZUOWJaol0s-';
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
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.KEY_SERVER}',
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


Future<void> notificationToGateOut() async {
  try {
    // Retrieve all employees with the role 'Gate out'
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Role', isEqualTo: 'Gate out')
        .get();

    // Extract the device tokens from the query result
    List<String> tokens = querySnapshot.docs
        .map((doc) => doc['DeviceToken'] as String)
        .where((token) => token.isNotEmpty)
        .toList();

    if (tokens.isNotEmpty) {
      // Loop through each token and send a notification
      for (String token in tokens) {
        // Construct the notification payload
        final notification = {
          'to': token,
          'notification': {
            'title': 'New Work Available',
            'body': 'You have a new work assignment to review please check your notification..',
            'sound': 'default',
          },
        };

        // Send the notification using FCM
        final response = await http.post(
          Uri.parse(Constants.BASE_URL),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=${Constants.KEY_SERVER}',
          },
          body: jsonEncode(notification),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully to Gate Out user with token: $token');
        } else {
          print('Failed to send notification to Gate Out user with token: $token');
          print('Response body: ${response.body}');
        }
      }

      // Show a local notification when sending notifications is successful
      await showNotification(
        'Send work to Gate Out complete',
        'Waiting Dispatcher to update work.',
      );
    } else {
      print('No device tokens found for Gate Out role.');
    }
  } catch (e) {
    print('Error sending notification to Gate Out users: $e');
  }
}

Future<void> sendNotificationBackToDispatcher(String workID) async {
  try {
    final DocumentSnapshot workDoc = await FirebaseFirestore.instance
        .collection('works')
        .doc(workID)
        .get();

    if (!workDoc.exists) {
      print('Work document not found.');
      return;
    }
    final String? dispatcherID = workDoc['dispatcherID'];
    if (dispatcherID == null || dispatcherID.isEmpty) {
      print('Dispatcher ID not found in the work document.');
      return;
    }
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Firstname', isEqualTo: dispatcherID)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('Dispatcher with the specified Firstname not found.');
      return;
    }

    final DocumentSnapshot dispatcherDoc = querySnapshot.docs.first;
    final String? dispatcherDeviceToken = dispatcherDoc['DeviceToken'];
    if (dispatcherDeviceToken == null || dispatcherDeviceToken.isEmpty) {
      print('Dispatcher device token not found.');
      return;
    }

    final notification = {
      'to': dispatcherDeviceToken,
      'notification': {
        'title': 'Work Update',
        'body': 'There is an update regarding your work assignment.',
        'sound': 'default',
      },
    };

    // Send the notification using FCM
    final response = await http.post(
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.KEY_SERVER}',
        },
        body: jsonEncode(notification),
      );

    if (response.statusCode == 200) {
      print('Notification sent successfully to the dispatcher.');

      // Show a local notification when sending notification is successful
      await showNotification(
        'Work Update Sent',
        'The work update has been sent to the dispatcher.',
      );
    } else {
      print('Failed to send notification to dispatcher: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification to dispatcher: $e');
  }
}


Future<void> sendNotificationBackTochecker(String workID) async {
  try {
    final DocumentSnapshot workDoc = await FirebaseFirestore.instance
        .collection('works')
        .doc(workID)
        .get();
    if (!workDoc.exists) {
      print('Work document not found.');
      return;
    }
    final String? employeeId = workDoc['employeeId'];
    if (employeeId == null || employeeId.isEmpty) {
      print('checkerID not found in the work document.');
      return;
    }
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Firstname', isEqualTo: employeeId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('checker with the specified Firstname not found.');
      return;
    }
    final DocumentSnapshot checkerDoc = querySnapshot.docs.first;
    final String? checkerToken = checkerDoc['DeviceToken'];
    if (checkerToken == null || checkerToken.isEmpty) {
      print('Checker device token not found.');
      return;
    }
    final notification = {
      'to': checkerToken,
      'notification': {
        'title': 'Work Update',
        'body': 'There is an update regarding your work assignment.',
        'sound': 'default',
      },
    };
    final response = await http.post(
        Uri.parse(Constants.BASE_URL),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=${Constants.KEY_SERVER}',
        },
        body: jsonEncode(notification),
      );

    if (response.statusCode == 200) {
      print('Notification sent successfully to the Checker.');

      // Show a local notification when sending notification is successful
      await showNotification(
        'Work Update Sent',
        'The work update has been sent to the Checker.',
      );
    } else {
      print('Failed to send notification to Checker: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification to Checkerr: $e');
  }
}

// Schedule a notification for the selected time
void scheduleAlarmNotification(TimeOfDay pickedTime) async {
  // Get the current date and selected time
  final now = DateTime.now();
  final scheduledTime = DateTime(
    now.year,
    now.month,
    now.day,
    pickedTime.hour,
    pickedTime.minute,
  );

  // Check if the scheduled time is in the future, otherwise schedule for the next day
  final adjustedTime = scheduledTime.isAfter(now)
      ? scheduledTime
      : scheduledTime.add(const Duration(days: 1));

  // Convert DateTime to TZDateTime in the local timezone
  final tzAdjustedTime = tz.TZDateTime.from(adjustedTime, tz.local);

  // Set up notification details
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_channel',
    'Alarm Notifications',
    channelDescription: 'Notification channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    icon: '@mipmap/ic_launcher', // Ensure this matches your app's icon resource
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Schedule the notification
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Work Due Time Alert',
    'Your work is due now!',
    tzAdjustedTime,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // Triggers daily at the specified time
  );
}


  void handleForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id', // channel ID
              'your_channel_name', // channel name
              channelDescription: 'your channel description', // channel description
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }




