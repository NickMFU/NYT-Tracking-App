import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namyong_demo/Component/bottom_nav.dart';
import 'package:namyong_demo/screen/Timeline.dart';

class AcceptWorkPage extends StatefulWidget {
  final String createdWorkID;

  AcceptWorkPage({required this.createdWorkID});

  @override
  _AcceptWorkPageState createState() => _AcceptWorkPageState();
}

class _AcceptWorkPageState extends State<AcceptWorkPage> {
  List<String> works = []; // Placeholder for created works

  @override
  void initState() {
    super.initState();
    // Fetch the list of created works
    fetchWorks();
  }

  // Method to fetch created works (placeholder for demonstration)
  void fetchWorks() {
    // Assuming you have a method to fetch works from a database or storage
    // For demonstration, I'll add the created work ID to the list
    setState(() {
      works = [widget.createdWorkID];
    });
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 2;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "All Work",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
      body: works.isEmpty
          ? Center(
              child: Text('No works available'),
            )
          : ListView.builder(
              itemCount: works.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(works[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () {
                      // Accept the work and navigate to the TimelinePage
                      acceptWork(works[index]);
                    },
                  ),
                );
              },
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

  // Method to accept the work
  void acceptWork(String work) {
    // Navigate to the TimelinePage for the selected work
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimelinePage(workID: work),
      ),
    );
  }
}
