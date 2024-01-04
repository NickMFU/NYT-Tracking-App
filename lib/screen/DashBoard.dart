// Dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namyong_demo/screen/AllWork.dart';
import 'package:namyong_demo/screen/RecordDamage.dart';
import 'package:namyong_demo/screen/allwork2.dart';
import 'package:namyong_demo/screen/login.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: Text(
          "DashBoard",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(224, 14, 94, 253),
                Color.fromARGB(196, 14, 94, 253),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
      
      
      body: Container(
        
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 2.0),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(3.0),
          children: <Widget>[
            makeDashboardItem("Total", Icons.work, 'works'),
            makeDashboardItem("Complete", Icons.done, 'complete'),
            makeDashboardItem("On-progress", Icons.rebase_edit, 'on_progress'),
            makeDashboardItem("Cancel", Icons.clear, 'cancel'),
          ],
        ),
      ),
      
    );
  }

  // ... rest of the code ...

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
              if (title == "Total") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AllWork()),
                );
              } else if (title == "Complete") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>DisplayScreen()),
                );
              } else if (title == "On-progress") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } else if (title == "Cancel") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordDamagePage()),
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
                      '$title\nCount: $itemCount',
                      style: const TextStyle(fontSize: 18.0, color: Colors.black),
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
