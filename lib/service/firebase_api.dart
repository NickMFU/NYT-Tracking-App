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
        "type": "service_account",
        "project_id": "namyongapp",
        "private_key_id": "e1d7c620f03d612b56468285d6d46c0fb8f2ac38",
        "private_key":
            "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCdCBAA0Qa+Pwwo\nD7SvkWB0wWaaV/ezdCaJTDFOjvRA1HKEtZyFVRXjfKujraEQ4oE/CaF/vJo+36oP\ngA4DwZ9ss7epioKvXl4J1oEjn2S+tcvBP+/zTgvPim1SJHCnJf6L0rFyjjE/TxsT\nEKHW6b7BHLuxpizoWqVzqXs4kb09erlgjj6HUBfkCdy/s5FdVWpK/8Yzos6G9RWP\ns+F0XgNsA643jd1XRPwniIsf0NPfaJjzTNV2B3O/q88kpgg5AmNzk+1EG22fyKea\nr6q6v1y8+hdaNvyGrlZ6ycDREz1t6QA6k8GPTVFN6QyQnSbIIvrqOSmDCBAX3zSo\n/lJQFWdbAgMBAAECggEAEKhSSkPiGzxE5dsEp7scKEZ7w9OhCwA/NkFG2baAYoAm\nxb0eJWapM8B91JcOhuQAIde7sfknw5OmTo6e7fcUGkvWJ73xrvirsQ94E3dNEI3o\nV0+Y/I5C4nkkr5n9+T0mi16GREihIL4beSJCiLGy8nlBz8545Qz4kBRiZdXP5T18\n7fewVDPkmOR9Q4Nb7eFdCOxIHXntCQQWfpfaSjSLmFXIhY6RtPnEEseJZproaDTI\nywYQly5ofm5w0pBSe+cfvF3o1rIj6Tn9k67LAoGXbXQrc3sBFi28kLAUrYlc9Dtf\ne1icxjyM/vGT6X3H+M9lJ9TFUt/K0ct38O39yknWQQKBgQDOtQOn7JYUGbvbqo/n\nCwgr1q1ehBjgiCfwV+BKh3kOYwcJZ6Qjbja2dHcKnfra294EGb5S8el5LqBqZDla\nRdBIL0iWWXXfU1fLhqssHqaxJ7Wu8dH0ABpR7ExNVrWJuxT+FCwt/+Fo9Z6cFTsh\nTIahYTlXRR+7Y0TVQ9btGuoUNwKBgQDCengXff7rdSC0fRtv8l1W0j+DUAQXuA7b\neLKQEvCG+Qc3sLhDDzmJ4JjcMYxceJj6yRoDWp3X69Fi8naCfUzHxNKo8CJd3JLI\nIbPTHBMAdeh2RDd/f0G5ydORnTMwZjjqoT7rGKcAX2nbAtUnHj+g2tMl6zvJAruY\n+R1tJr97/QKBgQCaRJAQ8EnlgHsqavXw2dPkW9iR1IZ4dEVSY1MabFbVfOSQiU//\nvU6KBwuc2eCRHExqxQe9AZxce4bvQBNpovbaGKfUxblpzdqVI9F2IP4I8vjuMr2d\nm8II6BDeG1trCjuVkFqUjgadfco89L9nj6Repp/T2Nvgzypc+79Yv6B5KwKBgEiw\nG5i0OAZrZcjwBcRGswpTVPfQfWccHTl8mEjvO0VHaKIxA/3Uf+3/q0KJpmudi5gY\neAeO4/YjJsSz2QWWrY7xCsen0UCBw77Xke2yzYtbhoJFpvSZbMhzHgeL2OkbG+Te\nVbTrJuglwVvhaCfRz3hgsZC3pkXQJqvbWFtGo0VFAoGBAK0e51dT3pMyHiKFFbBB\n26wvGytobiTo5APK7xA8f6B7DW8etjJE+BfDRKipY+dhSHFwxZbjuleRtLT2QnRp\nicAt/YvnH8re6Uwp3rXTOlCwiFyXpWaA9KG9JuwGK2Q2UesjsUiSJPLxju0oixRZ\nnFrsEPIJi3QA9DP5Oo1kbgNT\n-----END PRIVATE KEY-----\n",
        "client_email":
            "firebase-adminsdk-mx3d3@namyongapp.iam.gserviceaccount.com",
        "client_id": "113502189183337165580",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url":
            "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url":
            "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-mx3d3%40namyongapp.iam.gserviceaccount.com",
        "universe_domain": "googleapis.com"
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
