import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namyong_demo/Component/bottom_nav.dart';
import 'package:namyong_demo/model/Work.dart';

class AcceptWorkPage extends StatefulWidget {
  @override
  _AcceptWorkPageState createState() => _AcceptWorkPageState();
}

class _AcceptWorkPageState extends State<AcceptWorkPage> {
  late Stream<QuerySnapshot> _worksStream;

  @override
  void initState() {
    super.initState();
    _worksStream = _fetchWorks();
  }

  Stream<QuerySnapshot> _fetchWorks() {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final currentUserID = currentUser.uid;
    return FirebaseFirestore.instance
        .collection('works')
        .where('statuses', arrayContainsAny: ['NoStatus', 'Waiting']) // Include works with status "NoStatus" or "Waiting"
        .snapshots();
  } else {
    // Handle if user is not authenticated
    return Stream.empty();
  }
}
  

  

  Future<String> _getCheckerFirstName(String checkerID) async {
    final DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
        .collection('Employee')
        .doc(checkerID)
        .get();
    return employeeDoc['Firstname'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 2;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 202, 228, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Work Notification",
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
                Color.fromARGB(255, 4, 6, 126),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
      ),
     body: StreamBuilder<QuerySnapshot>(
  stream: _worksStream,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (snapshot.hasError) {
      return Center(
        child: Text('Error: ${snapshot.error}'),
      );
    }
    final works = snapshot.data?.docs ?? [];
    if (works.isEmpty) {
      return Center(
        child: Text('No works available'),
      );
    }
    final filteredWorks = works.where((doc) {
      var workData = doc.data() as Map<String, dynamic>;
      Work work = Work.fromMap(workData);
      String lastStatus = work.statuses.isNotEmpty ? work.statuses.last : 'NoStatus';
      return lastStatus == 'NoStatus' || lastStatus == 'Waiting'; // Include works with status "NoStatus" or "Waiting"
    }).toList();
    if (filteredWorks.isEmpty) {
      return Center(
        child: Text('No works with status "NoStatus" or "Waiting" available'),
      );
    }
    return ListView.builder(
      itemCount: filteredWorks.length,
      itemBuilder: (context, index) {
        var workData = filteredWorks[index].data() as Map<String, dynamic>;
        String workID = filteredWorks[index].id;
        Work work = Work.fromMap(workData);
        return Card(
          key: ValueKey(work.workID),
          child: ListTile(
            title: Text(work.blNo),
            subtitle: Text('Consignee: ${work.consignee}'),
            onTap: () => _showWorkDialog(work),
          ),
        );
      },
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

  Future<void> _showWorkDialog(Work work) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Accept Work'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Do you want to accept this work?'),
              SizedBox(height: 20),
              Text('BL No: ${work.blNo}'),
              Text('Consignee: ${work.consignee}'),
              Text('Vessel: ${work.vessel}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Accept'),
            onPressed: () async {
              // Change status to "Assigned" if last status is "NoStatus"
              // Remove "Waiting" status if it exists
              try {
                List<String> updatedStatuses = [];
                for (String status in work.statuses) {
                  if (status != 'Waiting') {
                    updatedStatuses.add(status);
                  }
                }
                updatedStatuses.add('Assigned');
                await FirebaseFirestore.instance
                    .collection('works')
                    .doc(work.workID)
                    .update({'statuses': updatedStatuses});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Work accepted successfully.'),
                  ),
                );
              } catch (e) {
                print('Error accepting work: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error accepting work. Please try again.'),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}
} 