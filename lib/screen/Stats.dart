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
  return Column(
    children: [
      Text(
        _currentMonth,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: StreamBuilder(
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
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No works available.'));
            }

            // Process the data to calculate stats
            Map<String, int> stats = calculateMonthlyStats(snapshot.data!.docs);

            return Padding(
              padding: const EdgeInsets.all(16.0),
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
  Widget _buildDailyStats() {
    // Implement daily stats here
    return Center(child: Text('Daily Stats'));
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
        title: '${entry.key}: ${entry.value}',
        radius: 100,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  // Get color based on status
  Color getColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.yellow;
      case 'Cancel':
        return Colors.red;
      case 'Complete':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
