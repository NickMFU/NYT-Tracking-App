import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namyong_demo/screen/RecordDamage.dart';
import 'package:namyong_demo/screen/ScanBarcode.dart';
import 'package:namyong_demo/screen/WorkDetailScreen.dart';
import 'package:namyong_demo/screen/scanbarcoderesult.dart';
import 'package:namyong_demo/screen/show_damage.dart';
import 'package:namyong_demo/screen/summay_work.dart';
import 'package:namyong_demo/service/firebase_api.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TimelinePage extends StatefulWidget {
  final String workID;

  TimelinePage({required this.workID});

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late CollectionReference _workRef;
  late DocumentReference _timelineDocRef;
  late Stream<DocumentSnapshot> _timelineStream;
  late List<bool> confirmedSteps;
  late int currentStep;
  late List<TimelineEntry> timelineEntries;
  late List<String> imagePaths;
  late String currentImagePath;
  Color stepColor = Colors.blue; // Default step color
  Color pageColor = Color.fromARGB(255, 202, 228, 255); // Default page color
  String? _role; // Nullable type for user's role
  String currentStatus = "";
  String name = ""; // Variable to track the current work status
  final LNotificationService notificationService =
      LNotificationService();

  List<Color> _appBarGradientColors = [
    Color.fromARGB(224, 14, 94, 253),
    Color.fromARGB(255, 4, 6, 126),
  ];

  // Sample function that updates the gradient colors based on status
  void _updateAppBarColor(String status) {
    setState(() {
      // Update the gradient colors based on the status
      switch (status) {
        case 'Cancel':
          _appBarGradientColors = [
            Color.fromARGB(255, 209, 65, 65),
            Color.fromARGB(255, 250, 0, 0),
          ];
          break;
        case 'In Progress':
          _appBarGradientColors = [
            Color.fromARGB(224, 14, 94, 253),
            Color.fromARGB(255, 4, 6, 126),
          ];
          break;
        case 'Completed':
          _appBarGradientColors = [
            Colors.green.shade300,
            Colors.green.shade700,
          ];
          break;
        default:
          _appBarGradientColors = [
            Color.fromARGB(224, 14, 94, 253),
            Color.fromARGB(255, 4, 6, 126),
          ];
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getLastStatus();
    name = "";
    _workRef = FirebaseFirestore.instance.collection('works');
    _timelineDocRef =
        _workRef.doc(widget.workID).collection('timeline').doc(widget.workID);
    _timelineStream = _timelineDocRef.snapshots();
    timelineEntries = [
      TimelineEntry(
        title: 'Assigned',
        content: 'Task assigned to a user.',
        startTime: DateTime.now(), // Initialize start time for the first step
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
      'assets/images/undraw_Add_tasks_re_s5yj-removebg-preview.png',
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
          // Fetch the current work status
          loadTimelineEntries(data); // Load timeline entries
        });
      }
    });
  }

  void loadTimelineEntries(Map<String, dynamic> data) {
    if (data.containsKey('timelineEntries')) {
      List<dynamic> entries = data['timelineEntries'];
      for (int i = 0; i < entries.length; i++) {
        var entry = entries[i];
        timelineEntries[i].startTime = entry['startTime'] != null
            ? DateTime.parse(entry['startTime'])
            : null;
        timelineEntries[i].finishTime = entry['finishTime'] != null
            ? DateTime.parse(entry['finishTime'])
            : null;
      }
    }
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

  

 Future<void> getLastStatus() async {
    try {
      DocumentSnapshot workSnapshot = await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workID)
          .get();
      Map<String, dynamic> data = workSnapshot.data() as Map<String, dynamic>;
      List<dynamic> statuses = data['statuses'] ?? [];
      if (statuses.isNotEmpty) {
        setState(() {
          currentStatus = statuses.last; // Update the current status
          _updateAppBarColor(currentStatus); // Update the AppBar color based on status
        });
      } else {
        setState(() {
          currentStatus = "No status available"; // Default message if no statuses
          _updateAppBarColor(currentStatus); // Update the AppBar color
        });
      }
    } catch (e) {
      print('Error fetching last status: $e');
      setState(() {
        currentStatus = "Error fetching status"; // Error message if fetching fails
        _updateAppBarColor(currentStatus); // Update the AppBar color
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Check if _role is null before using it
    if (_role == null) {
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
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              colors: _appBarGradientColors, // Use the state variable here
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
            icon:
                Icon(Icons.pageview, color: Color.fromARGB(255, 255, 255, 255)),
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
                height: 120,
                width: double.infinity,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Current Status: $currentStatus',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
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
                              : (confirmedSteps[index]
                                  ? Colors.green
                                  : stepColor)), // Change color to red
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
                          if (timelineEntries[index].startTime != null &&
                              timelineEntries[index].finishTime != null)
                            Text(
                                'Duration: ${timelineEntries[index].finishTime!.difference(timelineEntries[index].startTime!).inHours} hours ${timelineEntries[index].finishTime!.difference(timelineEntries[index].startTime!).inMinutes % 60} minutes'),
                          if (confirmedSteps[index])
                            Text(
                                'Finished at: ${timelineEntries[index].finishTime}'),
                          if ((_role == 'Checker') && currentStep <= 2)
                            if (index == 1 && !confirmedSteps[index])
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RecordDamagePage(
                                          workID: widget.workID),
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
                          if (index == 1)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowDamagePage(
                                      workID: widget.workID,
                                    ),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.view_array, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('show Damage',
                                      style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                          if ((_role == 'Checker') && currentStep <= 2)
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
                              ),
                              if (index == 2)
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScanBarcodeResultPage(workID: widget.workID),
                                  ),
                                );
                              },
                              child: const Row(
                                children: [
                                  Icon(Icons.view_array, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Barcode Result',
                                      style: TextStyle(color: Colors.green)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
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
                      child: Text(
                        'Check Summary',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.transparent, 
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (currentStatus == 'Cancel' && _role == 'Dispatcher' && currentStep == 0) 
                ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog();
                    _updateAppBarColor('In Progress');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: Text(
                    'Send Back to checker',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              if (name != "CS" && _role == 'Checker' && currentStep == 0)
                ElevatedButton(
                  onPressed: () {
                    showCancelDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Cancel work',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              if (name != "CS" && _role == 'Checker' && currentStep == 0)
                ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog();
                    _updateAppBarColor('In Progress');
                
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Start work',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              if (_role == 'Checker' && currentStep > 0 && currentStep < 3)
                ElevatedButton(
                  onPressed: () {
                    showCancelDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Cancel work',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              if (_role == 'Checker' && currentStep > 0 && currentStep < 3)
                ElevatedButton(
                  onPressed: () {
                  showConfirmationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              if ((_role == 'Gate out') && currentStep == 3)
                ElevatedButton(
                  onPressed: () {
                    showCancelDialogtochecker();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Cancel work',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              if ((_role == 'Gate out') && currentStep > 2)
                ElevatedButton(
                  onPressed: () {
                    showConfirmationDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color getStatusColor() {
    if (currentStep == 0) {
      return Colors.blue;
    } else if (currentStep == 1) {
      return Colors.blue;
    } else if (currentStep == 2) {
      return Colors.blue;
    } else if (currentStep == 3) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  void confirmStep() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String employeeID = user.uid; // Assuming UID is used as EmployeeID
      setState(() {
        timelineEntries[currentStep].finishTime = DateTime.now();
        if (currentStep < timelineEntries.length - 1) {
          timelineEntries[currentStep + 1].startTime = DateTime.now();
        }
        confirmedSteps[currentStep] = true;
        if (currentStep == timelineEntries.length - 1) {
          changeWorkStatus("Complete");
        } else if (currentStep == 0) {
          changeWorkStatus("Assigned");
        } else if (currentStep == 2) {
          changeWorkStatus("Waiting");
          notificationService.notificationToGateOut();
        } else if (currentStep == 3) {
          changeWorkStatus("Assigned");
        }
        currentStep = (currentStep + 1).clamp(0, timelineEntries.length - 1);
        currentImagePath = imagePaths[currentStep];
        pageColor = Color.fromARGB(255, 202, 228, 255);
        name = "OK";
        saveState();
      });
    } else {
      print('No user logged in.');
    }
  }

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text(getConfirmationText(currentStep)),
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

  String getConfirmationText(int step) {
    switch (step) {
      case 0:
        return 'Do you want to Accept this work ?';
      case 1:
        return 'Do you want to confirm the order has no Damage?';
      case 2:
        return 'Do you want to confirm Load to the Tractor is complete?';
      case 3:
        return 'Do you want to confirm this work completed?';
      case 4:
        return 'Do you want to confirm the Product Release?';
      default:
        return 'Do you want to confirm this step?';
    }
  }

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Cancel'),
          content: const Text(
              'Are you sure you want to cancel this work and send back to dispatcher?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

  void showCancelDialogtochecker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: const Text(
              'Are you sure you want to cancel this work and send back to checker?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                cancelWorktochecker();
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
      _updateAppBarColor('Cancel');
      confirmedSteps = List<bool>.filled(timelineEntries.length, false);
      currentStep = 0;
      currentImagePath = imagePaths[0];
      changeWorkStatus("Cancel");
      currentStatus = "Cancel" ;
      name = "CS";
      notificationService.sendNotificationBackToDispatcher(widget.workID);
      saveState();
    });
  }

  void cancelWorktochecker() {
    setState(() {
      _updateAppBarColor('Cancel');
      confirmedSteps = List<bool>.filled(timelineEntries.length, false);
      currentStep = 0;
      currentImagePath = imagePaths[0];
      changeWorkStatus("Cancel");
      currentStatus = "Cancel" ;
      name = "CS";
      notificationService.sendNotificationBackToChecker(widget.workID);
      saveState();
    });
  }

  void saveState() async {
    Map<String, dynamic> data = {
      'currentStep': currentStep,
      'confirmedSteps': confirmedSteps,
      'pageColor': pageColor.value,
      'name': name,
      'timelineEntries': timelineEntries.map((entry) {
        return {
          'title': entry.title,
          'startTime': entry.startTime?.toIso8601String(),
          'finishTime': entry.finishTime?.toIso8601String(),
        };
      }).toList(),
    };
    await _timelineDocRef.set(data);
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
}

class TimelineEntry {
  final String title;
  final String content;
  DateTime? startTime;
  DateTime? finishTime;

  TimelineEntry({
    required this.title,
    required this.content,
    this.startTime,
    this.finishTime,
  });
}
