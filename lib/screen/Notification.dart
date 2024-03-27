import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namyong_demo/Component/bottom_nav.dart';
import 'package:namyong_demo/model/Work.dart';
import 'package:namyong_demo/screen/Timeline.dart';

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
        .where('statuses', arrayContains: 'NoStatus')
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
      appBar: AppBar(
        title: Text('Accept Work'),
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
          return ListView.builder(
            itemCount: works.length,
            itemBuilder: (context, index) {
              final work =
                  Work.fromMap(works[index].data() as Map<String, dynamic>);
              return Card(
                // Provide a unique key for each ListTile
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
              onPressed: () {
                _updateWorkStatus(work);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateWorkStatus(Work work) async {
    try {
      final currentUserID = FirebaseAuth.instance.currentUser?.uid;
      final workRef =
          FirebaseFirestore.instance.collection('works').doc(work.workID);
      await workRef.update({
        'statuses': FieldValue.arrayRemove(['NoStatus']),
        'statuses': FieldValue.arrayUnion(['Accepted']),
        'acceptedBy': currentUserID,
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TimelinePage(workID: work.workID),
        ),
      );
    } catch (e) {
      print('Error updating work status: $e');
    }
  }
}

