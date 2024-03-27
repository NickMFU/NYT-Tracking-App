import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:namyong_demo/screen/work_status/onprocess_work.dart';
import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late String _firstName = '';
  late String _lastName = '';
  late String role = '';
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
          role = userData['Role'];
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
      backgroundColor: Color.fromARGB(255, 0, 30, 62),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: Shimmer.fromColors(
            baseColor: Colors.white,
            highlightColor: Colors.blue,
            child: Text(
              "Welcome",
              style: GoogleFonts.dmSans(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '$_firstName $_lastName\nRole: $role',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.person_alt_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    // Show the popup menu
                    showMenu(
                      context: context,
                      position: RelativeRect.fromLTRB(1000, 80, 0, 1000),
                      items: [
                        const PopupMenuItem(
                          child: Text('Profile'), // Profile menu item
                          value: 'profile',
                        ),
                        const PopupMenuItem(
                          child: Text('Statics'), // Profile menu item
                          value: 'Statics',
                        ),
                        const PopupMenuItem(
                          child: Text('Logout'),
                          value: 'logout',
                        ),
                      ],
                      elevation: 8.0,
                    ).then((value) {
                      if (value == 'profile') {
                        // Redirect to profile page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage()),
                        );
                      } else if (value == 'Statics') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StaticPage()),
                        );
                      }
                      else if (value == 'logout') {
                        _signOut();
                      }
                    });
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
        bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      body: Container(
          decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/—Pngtree—a blue wallpaper with white_15428175.jpg"),  // path to your image
            fit: BoxFit.cover,  // adjust as needed
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
        
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(3.0),
          children: <Widget>[
            makeDashboardItem(
                "Total Work", CupertinoIcons.doc_text_fill, 'works'),
            makeDashboardItem(
              "Complete Work",CupertinoIcons.checkmark_alt_circle, 'complete'),
            makeDashboardItem(
                "On-progress Work", CupertinoIcons.car_detailed, 'on_progress'),
            makeDashboardItem(
                "Cancel Work", CupertinoIcons.clear_fill, 'cancel'),
          ],
        ),
        
      ),
      
    );
  }

 Card makeDashboardItem(String title, IconData icon, String collection) {
  return Card(
    elevation: 1.0,
    margin: EdgeInsets.all(8.0),
    child: Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 4, 6, 126),
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // Initialize itemCount to 0
          int itemCount = 0;

          // Filter documents based on the title
          if (title == "Total Work") {
            itemCount = snapshot.data?.docs.length ?? 0;
          } else if (title == "Complete Work") {
            // Count completed works where the last status is "Complete"
            itemCount = snapshot.data?.docs.where((doc) {
              var workData = doc.data() as Map<String, dynamic>;
              List<dynamic> statuses = workData['statuses'];
              String lastStatus = statuses.isNotEmpty ? statuses.last : '';
              return lastStatus == 'Complete';
            }).length ?? 0;
          } else if (title == "On-progress Work" || title == "Cancel Work") {
            // For "On-progress Work" and "Cancel Work", count all documents
            itemCount = snapshot.data?.docs.length ?? 0;
          }

          return InkWell(
            onTap: () {
              // Navigate to different pages based on the title
              if (title == "Total Work") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllWork()),
                );
              } else if (title == "Complete Work") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinishWorkPage()),
                );
              } else if (title == "On-progress Work") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OnProgressWorkPage()),
                );
              } else if (title == "Cancel Work") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CancelWorkPage()),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                const SizedBox(height: 50.0),
                Center(
                  child: Icon(
                    icon,
                    size: 40.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: Text(
                    '$title',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '$itemCount', // Display the count of items
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
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
