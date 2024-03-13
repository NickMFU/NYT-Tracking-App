import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String _firstName = '';
  late String _lastName = '';
  late String _email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('Employee')
                .doc(user.uid)
                .get();
        if (userData.exists) {
          setState(() {
            _firstName = userData['Firstname'];
            _lastName = userData['Lastname'];
            _email = userData['Email'];
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           CircleAvatar(
  // Use the user's profile picture URL or any other image source
  backgroundImage: NetworkImage('url_to_profile_pic'),
  radius: 50,
),
            SizedBox(height: 20),
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'First Name: $_firstName',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Last Name: $_lastName',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Email: $_email',
              style: TextStyle(fontSize: 16),
            ),
            // Add other user information fields as needed
          ],
        ),
      ),
    );
  }
}