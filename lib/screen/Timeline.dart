import 'package:flutter/material.dart';
import 'package:namyong_demo/screen/RecordDamage.dart';
import 'package:namyong_demo/screen/ScanBarcode.dart';
import 'package:namyong_demo/screen/WorkDetailScreen.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimelinePage extends StatefulWidget {
  final String workID;

  TimelinePage({required this.workID});

  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  late SharedPreferences _prefs;
  late String uniqueTimelineKey;
  List<bool> confirmedSteps = List.filled(5, false);
  List<TimelineEntry> timelineEntries = [
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
  List<String> imagePaths = [
    'assets/images/undraw_Add_tasks_re_s5yj.png',
    'assets/images/43025 2.png',
    'assets/images/43025 1.png',
    'assets/images/undraw_approve_qwp7.png',
    'assets/images/1.jpg',
  ];
  int currentStep = 0;
  String currentImagePath = '';

  @override
  void initState() {
    super.initState();
    uniqueTimelineKey = 'timeline-${widget.workID}';
    currentImagePath = imagePaths[0];
    initSharedPreferences();
  }

  void initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      currentStep = _prefs.getInt('$uniqueTimelineKey-currentStep') ?? 0;
      confirmedSteps = List.generate(5, (index) {
        return _prefs.getBool('$uniqueTimelineKey-confirmedStep$index') ??
            false;
      });
      currentImagePath = imagePaths[currentStep];
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Color.fromARGB(196, 14, 94, 253),
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
        // Wrap with SingleChildScrollView
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
                                    builder: (context) => RecordDamagePage(),
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
                                  Text('Load',
                                      style: TextStyle(color: Colors.blue)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print('Cancel button pressed');
                      resetTimeline();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmationDialog(() {
                        setState(() {
                          confirmedSteps[currentStep] =
                              !confirmedSteps[currentStep];
                          currentStep = (currentStep + 1)
                              .clamp(0, timelineEntries.length - 1);
                          currentImagePath = imagePaths[currentStep];
                          saveState();
                        });
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Confirm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationDialog(Function confirmAction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Are you sure you want to confirm again?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                confirmAction(); // Perform confirm action
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void saveState() {
    _prefs.setInt('$uniqueTimelineKey-currentStep', currentStep);
    for (int i = 0; i < confirmedSteps.length; i++) {
      _prefs.setBool('$uniqueTimelineKey-confirmedStep$i', confirmedSteps[i]);
    }
  }

  void resetTimeline() {
    setState(() {
      confirmedSteps = List.filled(5, false);
      currentStep = 0;
      currentImagePath = imagePaths[0];
      saveState();
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
