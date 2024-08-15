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
  late String _firstName = '';
  late String _role = '';
  bool _hasWorkNotification = false;
  bool _isDataLoaded = false;

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
          _role = userData['Role'];
          _isDataLoaded = true;
        });
        _worksStream = _fetchWorks();
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Stream<QuerySnapshot> _fetchWorks() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance.collection('works').snapshots();
    } else {
      return Stream.empty();
    }
  }

  void _updateWorkNotification(List<QueryDocumentSnapshot> works) {
    bool hasNotification = works.any((doc) {
      var workData = doc.data() as Map<String, dynamic>;
      Work work = Work.fromMap(workData);
      String lastStatus =
          work.statuses.isNotEmpty ? work.statuses.last : 'NoStatus';
      if (_role == 'Checker') {
        return lastStatus == 'NoStatus';
      } else if (_role == 'Gate out') {
        return lastStatus == 'Waiting';
      }
      return false;
    });

    if (_hasWorkNotification != hasNotification) {
      setState(() {
        _hasWorkNotification = hasNotification;
      });
    }
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
      body: _isDataLoaded
          ? StreamBuilder<QuerySnapshot>(
              stream: _worksStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final works = snapshot.data?.docs ?? [];
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateWorkNotification(works);
                });

                if (works.isEmpty) {
                  return const Center(
                    child: Text('No works available'),
                  );
                }

                final filteredWorks = works.where((doc) {
                  var workData = doc.data() as Map<String, dynamic>;
                  Work work = Work.fromMap(workData);
                  String lastStatus =
                      work.statuses.isNotEmpty ? work.statuses.last : 'NoStatus';
                  if (_role == 'Checker') {
                    return lastStatus == 'NoStatus';
                  } else if (_role == 'Gate out') {
                    return lastStatus == 'Waiting';
                  }
                  return false;
                }).toList();

                if (filteredWorks.isEmpty) {
                  return const Center(
                    child: Text(
                        'No works with status "Waiting" available'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredWorks.length,
                  itemBuilder: (context, index) {
                    var workData =
                        filteredWorks[index].data() as Map<String, dynamic>;
                    String workID = filteredWorks[index].id;
                    Work work = Work.fromMap(workData);
                    return Card(
                      key: ValueKey(work.workID),
                      child: ListTile(
                        title: Text(work.blNo),
                        subtitle: Text('WorkID: ${work.workID}'),
                        onTap: () {
                          String lastStatus =
                              work.statuses.isNotEmpty ? work.statuses.last : '';
                          if (lastStatus == 'NoStatus') {
                            _DialogNostatus(work);
                          } else if (lastStatus == 'Waiting') {
                            _showWorkDialog(work);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        hasNotification: _hasWorkNotification, // Pass the flag to the BottomNavBar
      ),
    );
  }

  Future<void> _showWorkDialog(Work work) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Have new work from Checker'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Gate out Do you want to accept this work?'),
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
                try {
                  List<String> updatedStatuses = [...work.statuses];
                  if (updatedStatuses.contains('Waiting')) {
                    updatedStatuses.remove('Waiting');
                    updatedStatuses.add('Assigned');
                    await FirebaseFirestore.instance
                        .collection('works')
                        .doc(work.workID)
                        .update({
                      'statuses': updatedStatuses,
                      'GateoutID': _firstName,
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Work accepted successfully.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Work is already accepted.'),
                      ),
                    );
                  }
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

  Future<void> _DialogNostatus(Work work) async {
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


