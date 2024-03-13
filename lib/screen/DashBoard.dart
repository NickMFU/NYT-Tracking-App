import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namyong_demo/screen/AllWork.dart';
import 'package:namyong_demo/screen/Stats.dart';
import 'package:namyong_demo/screen/login.dart';
import 'package:namyong_demo/Component/bottom_nav.dart';
import 'package:namyong_demo/screen/profile.dart';
import 'package:namyong_demo/screen/regis.dart';
import 'package:namyong_demo/screen/work_status/cancel_work.dart';
import 'package:namyong_demo/screen/work_status/finish_work.dart';
import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String _firstName = '';
  late String _lastName = '';
  int _currentIndex = 0;

  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Employee')
            .doc(user.uid)
            .get();
        setState(() {
          _firstName = userData['Firstname'];
          _lastName = userData['Lastname'];
        });
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the login page after logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 247, 255),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.blue,
            child: Text(
              "Welcome",
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
            ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white),
                const SizedBox(width: 5),
                Text(
                  '$_firstName $_lastName',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                PopupMenuButton(
                  color: Colors.white,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('Profile'), // Profile menu item
                      value: 'profile',
                    ),
                    const PopupMenuItem(
                      child: Text('Logout'),
                      value: 'logout',
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'profile') {
                      // Redirect to profile page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    } else if (value == 'logout') {
                      _signOut();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(224, 14, 94, 253),
                Color.fromARGB(255, 4, 6, 126),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(3.0),
          children: <Widget>[
            makeDashboardItem("Total Work", Icons.work, 'works'),
            makeDashboardItem("Complete", Icons.done, 'complete'),
            makeDashboardItem("On-progress", Icons.rebase_edit, 'on_progress'),
            makeDashboardItem("Cancel", Icons.clear, 'cancel'),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Card makeDashboardItem(String title, IconData icon, String collection) {
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(collection).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            int itemCount = snapshot.data?.docs.length ?? 0;

            return InkWell(
              onTap: () {
                if (title == "Total Work") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllWork()),
                  );
                } else if (title == "Complete") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                } else if (title == "On-progress") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StaticPage()),
                  );
                } else if (title == "Cancel") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NoStatusWorkPage()),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  SizedBox(height: 50.0),
                  Center(
                    child: Icon(
                      icon,
                      size: 40.0,
                      color: Color.fromARGB(196, 14, 94, 253),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Center(
                    child: Text(
                      '$title\n Count: $itemCount',
                      style:
                          const TextStyle(fontSize: 18.0, color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
