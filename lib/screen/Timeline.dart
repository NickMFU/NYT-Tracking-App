import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namyong_demo/screen/RecordDamage.dart';
import 'package:namyong_demo/screen/ScanBarcode.dart';
import 'package:namyong_demo/screen/WorkDetailScreen.dart';
import 'package:namyong_demo/screen/summay_work.dart';
import 'package:namyong_demo/service/constants.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  final String workID;

  TimelinePage({required this.workID});

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late CollectionReference _timelineRef;
  late Stream<DocumentSnapshot> _timelineStream;
  late List<bool> confirmedSteps;
  late int currentStep;
  late List<TimelineEntry> timelineEntries;
  late List<String> imagePaths;
  late String currentImagePath;

  @override
  void initState() {
    super.initState();
    _timelineRef = FirebaseFirestore.instance.collection('timelines');
    _timelineStream = _timelineRef.doc(widget.workID).snapshots();
    timelineEntries = [
      TimelineEntry(
        title: 'Assigned',
        content: 'Task assigned to a user.',
      ),
      TimelineEntry(
        title: 'During Checker Survey',
        content: 'Survey in progress by a checker',
      ),
      TimelineEntry(
        title: 'Load to Tractor',
        content: 'Loading the task onto a tractor.',
      ),
      TimelineEntry(
        title: 'During Gate Out Confirm',
        content: 'Confirmation during gate out.',
      ),
      TimelineEntry(
        title: 'Product Release Complete',
        content: 'Product release process completed.',
      ),
    ];
    imagePaths = [
      'assets/images/undraw_Add_tasks_re_s5yj.png',
      'assets/images/43025 2.png',
      'assets/images/43025 1.png',
      'assets/images/Animation - 1710742336521 (1).gif',
      'assets/images/1.jpg',
    ];
    currentStep = 0;
    currentImagePath = imagePaths[0];
    confirmedSteps = List.filled(timelineEntries.length, false);
    _timelineStream.listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          currentStep = data['currentStep'] ?? 0;
          confirmedSteps = List<bool>.from(data['confirmedSteps'] ?? []);
          currentImagePath = imagePaths[currentStep];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool allStepsConfirmed = confirmedSteps.every((step) => step);
    bool isLastStep = currentStep == timelineEntries.length - 1;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 247, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Work ID ${widget.workID}",
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkDetailsScreen(
                    workID: widget.workID,
                  ),
                ),
              );
            },
            icon: Icon(Icons.pageview),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                currentImagePath,
                height: 160,
                width: double.infinity,
              ),
              SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: timelineEntries.length,
                itemBuilder: (context, index) {
                  return TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isFirst: index == 0,
                    isLast: index == timelineEntries.length - 1,
                    indicatorStyle: IndicatorStyle(
                      width: 20,
                      color: confirmedSteps[index] ? Colors.green : Colors.blue,
                      indicatorXY: 0.2,
                      padding: EdgeInsets.all(8),
                    ),
                    endChild: ListTile(
                      title: Text(timelineEntries[index].title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(timelineEntries[index].content),
                          SizedBox(height: 8.0),
                          if (confirmedSteps[index])
                            Text('Finished at: ${DateTime.now()}'),
                          if (index == 1 && !confirmedSteps[index])
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecordDamagePage(workID: widget.workID),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.add, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Record',
                                      style: TextStyle(color: Colors.blue)),
                                ],
                              ),
                            ),
                          if (index == 2 && !confirmedSteps[index])
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ScanBarcodePage(workID: widget.workID),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.add, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Load to tractor',
                                      style: TextStyle(color: Colors.blue)),
                                ],
                              ),
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (!allStepsConfirmed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: resetTimeline,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        confirmStep();
                        if (timelineEntries[currentStep].title ==
                            'During Gate Out Confirm') {
                          sendNotificationToGateOut();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Confirm'),
                    ),
                  ],
                ),
              if (allStepsConfirmed && isLastStep)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Summarywork(
                              workID: widget.workID,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('Check Summary'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmStep() async {
    // Get the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String employeeID = user.uid; // Assuming UID is used as EmployeeID
      setState(() {
        confirmedSteps[currentStep] = true;
        if (currentStep == timelineEntries.length - 1) {
          changeWorkStatus("Complete");
          addGateOutField(employeeID);
        } else if (currentStep == 0) {
          changeWorkStatus("Assigned");
        }
        currentStep = (currentStep + 1).clamp(0, timelineEntries.length - 1);
        currentImagePath = imagePaths[currentStep];
        saveState();
      });
    } else {
      print('No user logged in.');
      // Handle the case where no user is logged in
    }
  }

  

  void addGateOutField(String employeeID) async {
    try {
      DocumentSnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .doc(employeeID)
          .get();

      if (employeeSnapshot.exists) {
        String gateOutEmployeeID = employeeSnapshot['EmployeeID'];
        DocumentReference workRef =
            FirebaseFirestore.instance.collection('works').doc(widget.workID);
        await workRef.update({'Gate out': gateOutEmployeeID});
        print('Added "Gate out" field with value: $gateOutEmployeeID');
      } else {
        print('Employee document does not exist for ID: $employeeID');
        // Handle the case where employee document does not exist
      }
    } catch (e) {
      print('Error adding "Gate out" field: $e');
    }
  }

  void resetTimeline() {
    setState(() {
      changeWorkStatus("Cancel");
      saveState();
    });
  }

  void changeWorkStatus(String newStatus) async {
    try {
      // Get the reference to the work document
      DocumentReference workRef =
          FirebaseFirestore.instance.collection('works').doc(widget.workID);
      // Get the current statuses array
      DocumentSnapshot workSnapshot = await workRef.get();
      Map<String, dynamic> data = workSnapshot.data() as Map<String, dynamic>;
      List<dynamic> currentStatuses = data['statuses'] ?? [];
      // Add the new status to the array
      List<dynamic> updatedStatuses = [...currentStatuses, newStatus];
      // Update the statuses field with the updated array
      await workRef.update({'statuses': updatedStatuses});
      print('Work status updated to $newStatus');
    } catch (e) {
      print('Error updating work status: $e');
    }
  }

  void saveState() async {
    await _timelineRef.doc(widget.workID).set({
      'confirmedSteps': confirmedSteps,
      'currentStep': currentStep,
    });
  }
}

class TimelineEntry {
  final String title;
  final String content;

  TimelineEntry({
    required this.title,
    required this.content,
  });
}
