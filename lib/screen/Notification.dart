import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namyong_demo/Component/bottom_nav.dart';
import 'package:namyong_demo/model/Work.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AcceptWorkPage extends StatefulWidget {
  @override
  _AcceptWorkPageState createState() => _AcceptWorkPageState();
}

class _AcceptWorkPageState extends State<AcceptWorkPage> {
  late Stream<QuerySnapshot> _worksStream;
  String _firstName = '';
  String _role = '';
  bool _isDataLoaded = false;
  Set<String> _notifiedWorkIDs = {};
  bool _hasWorkNotification = false; // To track works that have been notified

  @override
  void initState() {
    super.initState();
    _worksStream = _fetchWorks();
    _loadUserData();
    _loadNotifiedWorkIDs(); // Load notified works from storage
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
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Stream<QuerySnapshot> _fetchWorks() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null
        ? FirebaseFirestore.instance.collection('works').snapshots()
        : Stream.empty();
  }

  Future<void> _loadNotifiedWorkIDs() async {
    // Load the notified work IDs from local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifiedWorkIDs = prefs.getStringList('notifiedWorkIDs')?.toSet() ?? {};
    });
  }

  Future<void> _saveNotifiedWorkIDs() async {
    // Save the notified work IDs to local storage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notifiedWorkIDs', _notifiedWorkIDs.toList());
  }

  void _updateWorkNotification(List<QueryDocumentSnapshot> works) {
    for (var doc in works) {
      var workData = doc.data() as Map<String, dynamic>;
      Work work = Work.fromMap(workData);

      // Determine if the work matches notification criteria based on the user's role
      String lastStatus =
          work.statuses.isNotEmpty ? work.statuses.last : 'NoStatus';
      bool shouldNotify = (_role == 'Checker' && lastStatus == 'NoStatus') ||
          (_role == 'Gate out' && lastStatus == 'Waiting');

      // Check if the work has not been notified and matches the criteria
      if (shouldNotify && !_notifiedWorkIDs.contains(work.workID)) {
        // Show notification and add to notified list
        _notifiedWorkIDs.add(work.workID);
      }
      if (_hasWorkNotification != shouldNotify) {
        setState(() {
          _hasWorkNotification = shouldNotify;
        });
      }
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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                  String lastStatus = work.statuses.isNotEmpty
                      ? work.statuses.last
                      : 'NoStatus';
                  if (_role == 'Checker') {
                    return lastStatus == 'NoStatus';
                  } else if (_role == 'Gate out') {
                    return lastStatus == 'Waiting';
                  }
                  return false;
                }).toList();

                if (filteredWorks.isEmpty) {
                  return const Center(
                    child: Text('No works with status "Waiting" available'),
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
                          String lastStatus = work.statuses.isNotEmpty
                              ? work.statuses.last
                              : '';
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
          : const Center(
              child: CircularProgressIndicator(),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        }, // Pass the flag to the BottomNavBar
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
                      const SnackBar(
                        content: Text('Work accepted successfully.'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Work is already accepted.'),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error accepting work: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error accepting work. Please try again.'),
                    ),
                  );
                }
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AcceptWorkPage()), // Replace with your actual dashboard page widget
                  (Route<dynamic> route) => false,
                );
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
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AcceptWorkPage()), // Replace with your actual dashboard page widget
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }
}
