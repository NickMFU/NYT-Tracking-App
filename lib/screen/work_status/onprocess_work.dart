import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namyong_demo/model/Work.dart';
import 'package:namyong_demo/screen/EditWork.dart';
import 'package:namyong_demo/screen/Timeline.dart';

class OnProgressWorkPage extends StatefulWidget {
  @override
  _OnProgressWorkPageState createState() => _OnProgressWorkPageState();
}

class _OnProgressWorkPageState extends State<OnProgressWorkPage> {
  late String _firstName = '';
  late String _lastName = '';

  @override
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 202, 228, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "On Progress Work",
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
      body: OnProgressWorkList(status: 'Assigned', firstName: _firstName),
    );
  }
}

class OnProgressWorkList extends StatelessWidget {
  final String status;
  final String firstName;

  OnProgressWorkList({required this.status, required this.firstName});

  final Map<String, Color> statusColors = {
    'NoStatus': Colors.grey,
    'Assigned': Colors.yellow.shade800,
    'Cancel': Colors.red,
    'Complete': Colors.green,
  };

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('works').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No on progress works available.');
        }
        final works = snapshot.data!.docs;
        final onProgressWorks = works.where((doc) {
          var workData = doc.data() as Map<String, dynamic>;
          Work work = Work.fromMap(workData);
          String lastStatus = work.statuses.isNotEmpty ? work.statuses.last : 'NoStatus';
          return lastStatus == 'Assigned' && (work.dispatcherID == firstName || work.employeeId == firstName);
        }).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'On Progress Works: ${onProgressWorks.length}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: onProgressWorks.length,
                itemBuilder: (context, index) {
                  var workData = onProgressWorks[index].data() as Map<String, dynamic>;
                  String workID = onProgressWorks[index].id;

                  Work work = Work.fromMap(workData);
                  String lastStatus = work.statuses.isNotEmpty ? work.statuses.last : 'NoStatus';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TimelinePage(workID: work.workID),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 4.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Upper section with work ID, date, and status
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Work ID and Date
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Work ID: ${work.workID}'),
                                    SizedBox(height: 8.0),
                                    Text('Date: ${work.date}'),
                                  ],
                                ),
                                // Status and Colored dot representing status
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColors[lastStatus] ??
                                            Colors.grey, // Get the color based on the last status
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      lastStatus, // Use the lastStatus as the status text
                                      style: TextStyle(
                                        color: statusColors[lastStatus] ??
                                            Colors.grey, // Use the color based on the last status
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          // Lower section with due time, edit, and delete buttons
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Due time
                                Text('Whalf ID:${work.blNo}'),
                                // Edit and Delete buttons
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditWorkPage(workID: workID),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: Text('Confirm Delete'),
                                              content: Text('Are you sure you want to delete this work?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); // Close the dialog
                                                  },
                                                  child: Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    deleteWork(workID);
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Text('Delete'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteWork(String workID) async {
    try {
      await FirebaseFirestore.instance.collection('works').doc(workID).delete();
      print('Document successfully deleted: $workID');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}
