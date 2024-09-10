import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namyong_demo/model/Work.dart';
import 'package:namyong_demo/screen/EditWork.dart';
import 'package:namyong_demo/screen/Timeline.dart';

class WaitingWorkPage extends StatefulWidget {
  @override
  _WaitingWorkPageState createState() => _WaitingWorkPageState();
}

class _WaitingWorkPageState extends State<WaitingWorkPage> {
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
          "Waiting Work",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
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
      body: WaitingWorkList(status: 'Waiting', firstName: _firstName),
    );
  }
}

class WaitingWorkList extends StatelessWidget {
  final String status;
  final String firstName;

  WaitingWorkList({required this.status, required this.firstName});

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

        final works = snapshot.data!.docs;
        final WaitingWorks = works.where((doc) {
          var workData = doc.data() as Map<String, dynamic>;
          Work work = Work.fromMap(workData);
          String lastStatus =
              work.statuses.isNotEmpty ? work.statuses.last : 'NoStatus';
          return (lastStatus == 'Waiting' || lastStatus == 'NoStatus') &&
              (workData['dispatcherID'] == firstName ||
                  workData['employeeId'] == firstName ||
                  workData['GateoutID'] == firstName);
        }).toList()
          ..sort((a, b) {
            // Sort by the date of the last work created
            Work workA = Work.fromMap(a.data() as Map<String, dynamic>);
            Work workB = Work.fromMap(b.data() as Map<String, dynamic>);
            DateTime dateA = DateTime.parse(workA.date);
            DateTime dateB = DateTime.parse(workB.date);
            return dateB.compareTo(dateA); // Sort in descending order
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Waiting Works: ${WaitingWorks.length}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: WaitingWorks.length,
                itemBuilder: (context, index) {
                  var workData =
                      WaitingWorks[index].data() as Map<String, dynamic>;
                  String workID = WaitingWorks[index].id;

                  Work work = Work.fromMap(workData);
                  String lastStatus = work.statuses.isNotEmpty
                      ? work.statuses.last
                      : 'NoStatus';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TimelinePage(workID: work.workID),
                        ),
                      );
                    },
                    child: Card(
                      margin:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 4.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Work ID: ${work.workID}'),
                                    SizedBox(height: 8.0),
                                    Text('Date: ${work.date}'),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: statusColors[lastStatus] ??
                                            Colors.grey,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      lastStatus,
                                      style: TextStyle(
                                        color: statusColors[lastStatus] ??
                                            Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Whalf ID:${work.blNo}'),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EditWorkPage(workID: workID),
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
                                              title:
                                                  const Text('Confirm Delete'),
                                              content: const Text(
                                                  'Are you sure you want to delete this work?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(); // Close the dialog
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
