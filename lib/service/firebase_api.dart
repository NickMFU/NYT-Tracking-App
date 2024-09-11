import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class LNotificationService {
  static const String BASE_URL =
      'https://fcm.googleapis.com/v1/projects/namyongapp/messages:send';
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize the service
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

  // Send FCM Notification using Access Token
  Future<void> sendNotificationToChecker(String checkerFirstName) async {
    try {
      final String? checkerDeviceToken =
          await getCheckerDeviceToken(checkerFirstName);
      if (checkerDeviceToken != null) {
        final String accessToken = await getAccessToken(); // Get Access Token
        final notification = {
          'message': {
            'token': checkerDeviceToken,
            'notification': {
              'title': 'New Work Available',
              'body':
                  'You have a new work assignment to review, please check your notification.',
            },
          },
        };

        final response = await http.post(
          Uri.parse(BASE_URL),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer $accessToken', // Use Access Token for Authorization
          },
          body: jsonEncode(notification),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully to checker.');
          await showNotification(
            'Sent work to Checker complete',
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
    final String accessToken = await getAccessToken();
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Employee')
        .where('Role', isEqualTo:'Gate out')
        .get();
    List<String> tokens = querySnapshot.docs
        .map((doc) => doc['DeviceToken'] as String)
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isNotEmpty) {
      // Loop through each token and send a notification
      for (String token in tokens) {
        // Construct the notification payload
        final notification = {
          'message': {
            'token': token,
            'notification': {
              'title': 'New Work Available',
              'body':
                  'You have a new work assignment to review, please check your notification.',
            },
          },
        };
        final response = await http.post(
          Uri.parse(BASE_URL),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer $accessToken', // Use Access Token for Authorization
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
    final String accessToken = await getAccessToken();
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
          'message': {
            'token': dispatcherDeviceToken,
            'notification': {
              'title': 'New Work Available',
              'body':
                  'You have a new work assignment to review, please check your notification.',
            },
          },
        };

    // Send the notification using FCM
  final response = await http.post(
          Uri.parse(BASE_URL),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer $accessToken', // Use Access Token for Authorization
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
    final String accessToken = await getAccessToken();
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
          'message': {
            'token': checkerToken,
            'notification': {
              'title': 'New Work Available',
              'body':
                  'You have a new work assignment to review, please check your notification.',
            },
          },
        };
    // Send the notification using FCM
    final response = await http.post(
          Uri.parse(BASE_URL),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer $accessToken', // Use Access Token for Authorization
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
              'your_channel_id',
              'your_channel_name',
              channelDescription: 'your channel description',
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
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
        return doc['DeviceToken'];
      }
    } catch (e) {
      print('Error fetching checker device token: $e');
    }
    return null;
  }

  // Get Access Token from Service Account
  Future<String> getAccessToken() async {
    try {
      final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
      final serviceAccountCredentials =
          auth.ServiceAccountCredentials.fromJson({
       // YOUR_KEY_FIREBASEADMIN_SDK
      });

      final client = await auth.clientViaServiceAccount(
        serviceAccountCredentials,
        scopes,
      );

      final accessToken = client.credentials.accessToken.data;
      client.close();
      print('Access Token: $accessToken');
      return accessToken;
    } catch (error) {
      print('Error fetching access token: $error');
      return 'Error fetching access token';
    }
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
