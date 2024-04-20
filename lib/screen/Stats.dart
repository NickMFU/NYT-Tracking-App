import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> with SingleTickerProviderStateMixin {
  late String _firstName = '';
  late TabController _tabController;
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 2, vsync: this);
    _currentMonth = _getMonth(DateTime.now().month);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        });
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Column(
          children: [
            Text(
              "All Work",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white,),
            ),
          ],
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Monthly'),
            Tab(text: 'Daily'),
          ],
          labelColor: Colors.white, // Set text color of the selected tab
          unselectedLabelColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyStats(),
          _buildDailyStats(),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
  return ListView(
    children: [
      GridView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.all(15),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1, // Adjust as needed
          crossAxisSpacing: 20,
          mainAxisSpacing: 40,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = index + 1;
          final monthName = _getMonth(month);
          return _buildMonthPieChart(monthName);
        },
      ),
    ],
  );
}
 Widget _buildMonthPieChart(String monthName) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Stack(
      alignment: Alignment.center,
      children: [
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('works')
              .where('dispatcherID', isEqualTo: _firstName)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Filter documents for the current month
            final docsForMonth = snapshot.data!.docs.where((doc) {
              final date = doc['date']; // Assuming date is stored as a Timestamp
              if (date is Timestamp) {
                return date.toDate().month == _getMonthNumber(monthName);
              } else if (date is String) {
                // Convert string to DateTime and extract month
                final dateTime = DateTime.parse(date);
                return dateTime.month == _getMonthNumber(monthName);
              } else {
                return false; // Invalid date format
              }
            }).toList();

            // If no documents for the month, return a blank chart
            if (docsForMonth.isEmpty) {
              return _buildEmptyPieChart();
            }

            // Process the data to calculate stats
            Map<String, int> stats = calculateMonthlyStats(docsForMonth);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: PieChart(
                PieChartData(
                  sections: getSections(stats),
                  centerSpaceRadius: 40,
                ),
              ),
            );
          },
        ),
        Positioned(
          top: 70,
          child: Text(
            monthName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildEmptyPieChart() {
  return Container(
    color: Colors.grey[300],
    child: Center(
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              color: Colors.grey[300]!,
              value: 0.01, // A small value to display an almost invisible slice
              title: '',
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildDailyStats() {
  DateTime now = DateTime.now();
  String currentDay = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}'; // Format the date properly
  String formattedDate = '${_getMonth(now.month)} ${now.day}, ${now.year}';

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Work Status for $formattedDate',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      Expanded(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('works')
              .where('dispatcherID', isEqualTo: _firstName)
              .where('date', isEqualTo: currentDay)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Get documents for the current day
            final docsForDay = snapshot.data!.docs;

            // If no documents for the day, return a blank chart
            if (docsForDay.isEmpty) {
              return _buildEmptyPieChart();
            }

            // Process the data to calculate stats
            Map<String, int> stats = calculateDailyStats(docsForDay);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: PieChart(
                PieChartData(
                  sections: getSections(stats),
                  centerSpaceRadius: 40,
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

// Helper function to format single-digit numbers with leading zeros
String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

// Calculate daily stats based on the document data
Map<String, int> calculateDailyStats(List<QueryDocumentSnapshot> docs) {
  Map<String, int> stats = {
    'Assigned': 0,
    'Cancel': 0,
    'Complete': 0,
    'Waiting': 0,
  };

  docs.forEach((doc) {
    var workData = doc.data() as Map<String, dynamic>;
    String lastStatus = workData['statuses'].isNotEmpty ? workData['statuses'].last : 'NoStatus';
    stats[lastStatus] = stats[lastStatus]! + 1;
  });

  return stats;
}
  // Calculate monthly stats based on the document data
  Map<String, int> calculateMonthlyStats(List<QueryDocumentSnapshot> docs) {
    Map<String, int> stats = {
      'Assigned': 0,
      'Cancel': 0,
      'Complete': 0,
      'Waiting': 0,
    };

    docs.forEach((doc) {
      var workData = doc.data() as Map<String, dynamic>;
      String lastStatus = workData['statuses'].isNotEmpty ? workData['statuses'].last : 'NoStatus';
      stats[lastStatus] = stats[lastStatus]! + 1;
    });

    return stats;
  }

  // Convert stats data into PieChartSections
  List<PieChartSectionData> getSections(Map<String, int> stats) {
    return stats.entries.map((entry) {
      return PieChartSectionData(
        color: getColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.value} Work', // Modified to show the percentage
        radius: 50, // Adjusted radius
        titleStyle: const TextStyle(
          fontSize: 16, // Adjusted font size
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  // Get color based on status
  Color getColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.yellow.shade800;
      case 'Cancel':
        return Colors.red;
      case 'Complete':
        return Colors.green;
      case 'Waiting':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get the month number from the month name
  int _getMonthNumber(String monthName) {
    switch (monthName) {
      case 'January':
        return 1;
      case 'February':
        return 2;
      case 'March':
        return 3;
      case 'April':
        return 4;
      case 'May':
        return 5;
      case 'June':
        return 6;
      case 'July':
        return 7;
      case 'August':
        return 8;
      case 'September':
        return 9;
      case 'October':
        return 10;
      case 'November':
        return 11;
      case 'December':
        return 12;
      default:
        return 0;
    }
  }
}
