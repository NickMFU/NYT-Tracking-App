import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:namyong_demo/service/local.dart';

class TestNotiPage extends StatefulWidget {
  @override
  _TestNotiPageState createState() => _TestNotiPageState();
}

class _TestNotiPageState extends State<TestNotiPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalNotificationService _notificationService = LocalNotificationService();

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Employee').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          final List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final String firstName = user['Firstname'] ?? '';
              final String deviceToken = user['DeviceToken'] ?? '';

              return ListTile(
                title: Text(firstName),
                onTap: () => _sendNotificationToUser(firstName, deviceToken),
              );
            },
          );
        },
      ),
    );
  }
  void _sendNotificationToUser(String firstName, String deviceToken) async {
    if (deviceToken.isNotEmpty) {
      _sendPushNotification(firstName, deviceToken);
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notification sent to $firstName')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send notification to $firstName')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Device token is not available for $firstName')),
      );
    }
  }

  Future<void> _sendPushNotification(String firstName, String deviceToken) async {
    const String serverKey = 'ya29.c.c0ASRK0GZJIkBB31TXTWxyk7hcBl24HFOpTEtAVc179euO5rrboK1vH8iZBtC3AL0E9xZdoMc3dbeaZoQFCsF847VRdhwS1rMEMrZbD0BZ7gmueJfOwk6p2UHkyto_dCIjSr0YKLUxSP5NdMtJ5BCl8n-LecK6zgMZOgBnqJ9Xy6XrDRrs8ODvRsh2_vDojQn3t0vXF3R78rmN93OzpLs6i-Bp437qz0agwY0q3wOla9g5mCjKlY62PIrbG6VlcoC65U5MQQGJs6IVhZ06plciAHZGkTlObLzfYYpjqj7dxmKDA_4c4mrl0KRqxVczQLrOB5PV_zpdLKZ45Qi9uyZjs3a2CWBViZAwk7lzOsidmBcSFsTLfLQfz9_fH385CfyvyU2u0nmZ_o5m9zqM8uVcqh2sinq9qv_QQXoXJqQMisv0fqv92Br--tamp1MYU65WzttMoxYx9k2xodIOB5MpqRZS3xk_t0_vx9-IwFhrmr8R40k6t-6X_uMlxpqJq62QvXxoI9i9Jfadk5bqgmiuJduFox--gFbqms6Swvq_l6UOq-sjJMB_zliX0tV9IV0ehe39ykS9q7butrcc_RI8mwX2wyJ_JJw7XqjIlc2QIeUZkbqwwatZ0IyeUqz0ZB6FgzcSJS54hZXY2-Zm_wzQulOc6IdJzv4ecp8b6vsRlgkk12rtUMom3JQw_q_4wVB_Yemg2VgbYUYj8I6j396Y6hvwpO-bIcR2Rbj-jZcbBIabMMpuekjSqSXMdk6vkO0IB1gFqpQYgUx27zzcwcRJRonrX3d7V6rU5iZ5dztY-e0mn9Qpj9pUW2pQMgz71bs2zRXz4o44BW6hBMY6_qfXFkkMzZ03ZkhyRx0m4xWi1XmjOnuXQ66tgmdMasRp1gclsW60RlkdVpjyFYUcbl5_rsfc22XUpR40zs0r6f88RF6n8UcdlXZ91yn0pfeOf43QyXgX4ij3iuyff2z_ziRl6yg1g5r81-rRj_498SsJ'; // Replace with your FCM server key
    const String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/namyongapp/messages:send';

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
  }
}
