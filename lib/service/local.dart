import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';



class LocalNotificationService {
  static const String BASE_URL = 'https://fcm.googleapis.com/fcm/send';
  static const String KEY_SERVER =
      'AAAAa2amNh0:APA91bFwHRDkkJCKaYfe2LYnYrh7B_oo3iSvBz278nPof6MVWJNySoAH8AW0_zmVqT5xg6F7Ic1g3aVMS_sUDJ5k0IkjZ3sxNCMpnFGlRES07bwJu9ABT6r2DJRG-InhaMGREfCwwx1u';
  static const String SENDER_ID = '461283669533';

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.notification.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Permission not granted');
    }

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    handleForegroundNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
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
      final String? checkerDeviceToken =
          await getCheckerDeviceToken(checkerFirstName);
      if (checkerDeviceToken != null) {
        final notification = {
          'to': checkerDeviceToken,
          'notification': {
            'title': 'New Work Available',
            'body':
                'You have a new work assignment to review please check your notification.',
            'icon': 'ic_notification',
            'sound': 'default',
          },
        }; // Send the notification using FCM
        final response = await http.post(
          Uri.parse(BASE_URL),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$KEY_SERVER',
          },
          body: jsonEncode(notification),
        );
        if (response.statusCode == 200) {
          print('Notification sent successfully to checker.');

          // Show a local notification when sending notification is successful
          await showNotification(
            'Sent work to Check complete',
            'Waiting Checker to accept works',
          );
        } else {
          print(
              'Failed to send notification to checker: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } else {
        print('Checker device token not found.');
      }
    } catch (e) {
      print('Error sending notification to checker: $e');
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
          Uri.parse(BASE_URL),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': 'key=$KEY_SERVER',
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
      await showNotification(
        'Send work to Gate Out complete',
        'Waiting Gate out to update work.',
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
    // Fetch the work document from Firestore
    final DocumentSnapshot workDoc = await FirebaseFirestore.instance
        .collection('works')
        .doc(workID)
        .get();

    // Check if the work document exists
    if (!workDoc.exists) {
      print('Work document not found.');
      return;
    }

    // Retrieve the dispatcherID from the work document
    final String? dispatcherID = workDoc['dispatcherID'];
    if (dispatcherID == null || dispatcherID.isEmpty) {
      print('Dispatcher ID not found in the work document.');
      return;
    }

    // Query Firestore for the dispatcher based on the retrieved dispatcherID
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Firstname', isEqualTo: dispatcherID)
        .limit(1)
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isEmpty) {
      print('Dispatcher with the specified Firstname not found.');
      return;
    }

    // Retrieve the device token from the dispatcher's document
    final DocumentSnapshot dispatcherDoc = querySnapshot.docs.first;
    final String? dispatcherDeviceToken = dispatcherDoc['DeviceToken'];
    if (dispatcherDeviceToken == null || dispatcherDeviceToken.isEmpty) {
      print('Dispatcher device token not found.');
      return;
    }

    // Construct the notification payload
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
      Uri.parse(BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$KEY_SERVER',
      },
      body: jsonEncode(notification),
    );

    // Check the response status code
    if (response.statusCode == 200) {
      print('Notification sent successfully to the dispatcher.');

      // Show a local notification upon success
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


Future<void> sendNotificationBackToChecker(String workID) async {
  try {
    // Fetch the work document from Firestore
    final DocumentSnapshot workDoc = await FirebaseFirestore.instance
        .collection('works')
        .doc(workID)
        .get();

    // Check if the work document exists
    if (!workDoc.exists) {
      print('Work document not found.');
      return;
    }

    // Retrieve the employeeId (checker ID) from the work document
    final String? employeeId = workDoc['employeeId'];
    if (employeeId == null || employeeId.isEmpty) {
      print('Checker ID not found in the work document.');
      return;
    }

    // Query Firestore for the checker based on the retrieved employeeId
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Firstname', isEqualTo: employeeId)
        .limit(1)
        .get();

    // Check if the query returned any documents
    if (querySnapshot.docs.isEmpty) {
      print('Checker with the specified Firstname not found.');
      return;
    }

    // Retrieve the device token from the checker's document
    final DocumentSnapshot checkerDoc = querySnapshot.docs.first;
    final String? checkerToken = checkerDoc['DeviceToken'];
    if (checkerToken == null || checkerToken.isEmpty) {
      print('Checker device token not found.');
      return;
    }

    // Construct the notification payload
    final notification = {
      'to': checkerToken,
      'notification': {
        'title': 'Work Update',
        'body': 'There is an update regarding your work assignment.',
        'sound': 'default',
      },
    };

    // Send the notification using FCM
    final response = await http.post(
      Uri.parse(BASE_URL),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$KEY_SERVER',
      },
      body: jsonEncode(notification),
    );

    // Check the response status code
    if (response.statusCode == 200) {
      print('Notification sent successfully to the checker.');

      // Show a local notification upon success
      await showNotification(
        'Work Update Sent',
        'The work update has been sent to the checker.',
      );
    } else {
      print('Failed to send notification to checker: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification to checker: $e');
  }
}

  

  Future<void> _sendPushNotification(
      String firstName, String deviceToken) async {
    const String serverKey =
        'AAAAa2amNh0:APA91bFwHRDkkJCKaYfe2LYnYrh7B_oo3iSvBz278nPof6MVWJNySoAH8AW0_zmVqT5xg6F7Ic1g3aVMS_sUDJ5k0IkjZ3sxNCMpnFGlRES07bwJu9ABT6r2DJRG-InhaMGREfCwwx1u'; // Replace with your FCM server key
    const String fcmEndpoint = 'https://fcm.googleapis.com/fcm/send';

    final Map<String, dynamic> notification = {
      'title': 'Hello,$firstName!',
      'body': 'You have a new notification.',
      'sound': 'default',
    };

    final Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'first_name': firstName,
    };

    final Map<String, dynamic> payload = {
      'to': deviceToken,
      'notification': notification,
      'data': data,
    };

    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: json.encode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send notification: ${response.body}');
    }

    // Show the notification locally as well
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // channel ID
      'your_channel_name', // channel name
      channelDescription: 'your channel description', // channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      0, // Notification ID
      notification['title'],
      notification['body'],
      platformChannelSpecifics,
      payload: 'Not present',
    );
  }

  void handleForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'your_channel_id', // channel ID
              'your_channel_name', // channel name
              channelDescription:
                  'your channel description', // channel description
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background message
  print('Handling a background message: ${message.messageId}');
  // Optionally, you can display a local notification here as well
  if (message.notification != null) {
    final FlutterLocalNotificationsPlugin notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await notificationsPlugin.show(
      0,
      message.notification!.title,
      message.notification!.body,
      platformChannelSpecifics,
    );
  }
}

}
