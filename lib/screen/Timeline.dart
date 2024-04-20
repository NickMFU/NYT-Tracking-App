import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namyong_demo/screen/RecordDamage.dart';
import 'package:namyong_demo/screen/ScanBarcode.dart';
import 'package:namyong_demo/screen/WorkDetailScreen.dart';
import 'package:namyong_demo/screen/show_damage.dart';
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
  Color stepColor = Colors.blue; // Default step color
  Color pageColor = Color.fromARGB(255, 202, 228, 255); // Default page color
  String? _role; // Nullable type for user's role

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
        title: 'Product Release ',
        content: 'Product release process completed.',
      ),
    ];
    imagePaths = [
      'assets/images/Animation - 1710742336521 (1).gif',
      'assets/images/43025_2-removebg-preview.png',
      'assets/images/43025_1-removebg-preview.png',
      'assets/images/undraw_approve_qwp7-removebg-preview.png',
      'assets/images/1-removebg-preview.png',
    ];
    currentStep = 0;
    currentImagePath = imagePaths[0];
    confirmedSteps = List.filled(timelineEntries.length, false);
    _loadRoleData(); // Load user's role
    _timelineStream.listen((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        setState(() {
          currentStep = data['currentStep'] ?? 0;
          confirmedSteps = List<bool>.from(data['confirmedSteps'] ?? []);
          currentImagePath = imagePaths[currentStep];
          pageColor = Color(data['pageColor'] ?? 0xFFFFFFFF);
        });
      }
    });
  }

  Future<void> _loadRoleData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Employee')
            .doc(user.uid)
            .get();
        setState(() {
          _role = userData['Role']; // Update user's role
        });
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if _role is null before using it
    if (_role == null) {
      // Show a loading indicator or handle the case where role is not yet fetched
      return CircularProgressIndicator();
    }

    bool allStepsConfirmed = confirmedSteps.every((step) => step);
    bool isLastStep = currentStep == timelineEntries.length - 1;
    stepColor = getStatusColor(); // Update step color based on status

    return Scaffold(
      backgroundColor: pageColor, // Change background color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 80,
        title: Text(
          "Work ID ${widget.workID}",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 255, 255)),
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
            icon: Icon(Icons.pageview, color: Color.fromARGB(255, 255, 255, 255)),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowDamagePage(
                    workID: widget.workID,
                  ),
                ),
              );
            },
            icon: Icon(Icons.pages_outlined, color: Color.fromARGB(255, 255, 255, 255),),
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
                      color: allStepsConfirmed
                          ? Colors.green
                          : (index == currentStep
                          ? Colors.yellow
                          : (confirmedSteps[index] ? Colors.green : stepColor)), // Change color to red
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
                                    builder: (context) =>
                                        RecordDamagePage(workID: widget.workID),
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
                                    builder: (context) => ScanBarcodePage(
                                        workID: widget.workID),
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
                    if ((_role == 'Dispatcher' || _role == 'Checker') && currentStep <= 2)
                      ElevatedButton(
                        onPressed: () {
                          showCancelDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Cancel',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),),
                      ),
                    if ((_role == 'Gate out') && currentStep > 2)
                      ElevatedButton(
                        onPressed: () {
                          showCancelDialog();
                          setState(() {
                            pageColor = Colors.red; // Change page color to red
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text('Cancel',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),),
                      ),
                    if ((_role == 'Dispatcher' || _role == 'Checker') && currentStep <= 2)
                      ElevatedButton(
                        onPressed: () {
                          showCancelConfirmationDialog();
                          if (timelineEntries[currentStep].title ==
                              'During Gate Out Confirm') {
                            sendNotificationToGateOut();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Confirm',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),),
                      ),
                    if ((_role == 'Gate out') && currentStep > 2)
                      ElevatedButton(
                        onPressed: () {
                          showCancelConfirmationDialog();
                          if (timelineEntries[currentStep].title ==
                              'During Gate Out Confirm') {
                            sendNotificationToGateOut();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text('Confirm',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),),
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
                      child: Text('Check Summary',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color getStatusColor() {
    // Update step color based on status
    if (confirmedSteps.contains(false)) {
      return Colors.blue; // Default color
    } else {
      return Colors.red; // Change color to red
    }
  }

  void confirmStep() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String employeeID = user.uid; // Assuming UID is used as EmployeeID
      setState(() {
        confirmedSteps[currentStep] = true;
        if (currentStep == timelineEntries.length - 1) {
          changeWorkStatus("Complete");
        } else if (currentStep == 0) {
          changeWorkStatus("Assigned");
        } else if (currentStep == 2) {
          changeWorkStatus("Waiting");
          sendNotificationToGateOut();
          showNotification('Sent work to Gate out complete',
              'Waiting Gate out accept works');
        }
        currentStep = (currentStep + 1).clamp(0, timelineEntries.length - 1);
        currentImagePath = imagePaths[currentStep];
        pageColor = Color.fromARGB(255, 202, 228, 255);;
        saveState();
      });
    } else {
      print('No user logged in.');
    }
  }

  void showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm '),
          content: Text('You finish this step?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                confirmStep();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Cancel'),
          content: Text('Are you sure you want to cancel this work?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                cancelWork();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void cancelWork() {
    setState(() {
      confirmedSteps = List<bool>.filled(timelineEntries.length, false);
      currentStep = 0;
      currentImagePath = imagePaths[0];
      changeWorkStatus("Cancel");
      NotificationToGateOut();
      pageColor = const Color.fromARGB(255, 255, 174, 168); // Update status to Cancel
      saveState(); // Change page color to red
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
      'pageColor': pageColor.value, 
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
