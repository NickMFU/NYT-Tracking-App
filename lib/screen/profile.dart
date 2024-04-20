import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Stream<DocumentSnapshot> _userDataStream;

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance
        .collection('Employee')
        .doc(widget.user!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No data available'));
          }

          // Extract user data
          Map<String, dynamic> userData = snapshot.data!.data() as Map<String, dynamic>;

          // Get profile picture URL from Firestore
          String? profileImageUrl = userData['ProfileImageURL'];

          String profileImage = 'https://images.ctfassets.net/h6goo9gw1hh6/2sNZtFAWOdP1lmQ33VwRN3/24e953b920a9cd0ff2e1d587742a2472/1-intro-photo-final.jpg?w=1200&h=992&fl=progressive&q=70&fm=jpg';

          // Build profile menu
          return ListView(
            children: [
              if (profileImageUrl != null) ...[
                ListTile(
                  title: Text('Profile Picture'),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profileImage),
                  ),
                ),
              ],
              ListTile(
                title: Text('Email'),
                subtitle: Text(userData['Email']),
              ),
              ListTile(
                title: Text('Employee ID'),
                subtitle: Text(userData['EmployeeID']),
              ),
              ListTile(
                title: Text('First Name'),
                subtitle: Text(userData['Firstname']),
              ),
              ListTile(
                title: Text('Last Name'),
                subtitle: Text(userData['Lastname']),
              ),
              ListTile(
                title: Text('Role'),
                subtitle: Text(userData['Role']),
              ),
              // Add more ListTile widgets for other user data
            ],
          );
        },
      ),
    );
  }
}
