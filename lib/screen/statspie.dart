import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namyong_demo/screen/statsbar.dart';
import 'package:namyong_demo/screen/time_report.dart';

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  late String _firstName = '';
  late TabController _tabController;
  late int _currentYear = DateTime.now().year;
  late int _currentMonthIndex =
      DateTime.now().month - 1; // January is 0, December is 11
  late int _currentDay = DateTime.now().day;
  late int _currentMonth = DateTime.now().month;
  late int _currentDayIndex =
      DateTime.now().day - 1; // Adjust for zero-based indexing

  final List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _tabController = TabController(length: 2, vsync: this);
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
              "Work Statics",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TimeReportPage(),
                ),
              );
            },
            icon:
                Icon(Icons.history, color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Monthly'),
            Tab(text: 'Daily'),
          ],
          labelColor: Colors.white,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StatsbarPage()),
          );
        },
        child: const Icon(Icons.bar_chart),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDescriptionBox(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<int>(
                    value: _currentMonthIndex,
                    onChanged: (int? newIndex) {
                      setState(() {
                        _currentMonthIndex = newIndex!;
                      });
                    },
                    items: _months.asMap().entries.map((entry) {
                      return DropdownMenuItem<int>(
                        value: entry.key,
                        child: Text(entry.value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 20),
                  DropdownButton<int>(
                    value: _currentYear,
                    onChanged: (int? newYear) {
                      setState(() {
                        _currentYear = newYear!;
                      });
                    },
                    items: _buildYearDropdownItems(),
                  ),
                ],
              ),
            ),
          ),
          _buildMonthPieChart(),
        ],
      ),
    );
  }

  List<DropdownMenuItem<int>> _buildYearDropdownItems() {
    int currentYear = DateTime.now().year;
    List<int> years = List.generate(5, (index) => currentYear - index);
    return years.map((year) {
      return DropdownMenuItem<int>(
        value: year,
        child: Text(year.toString()),
      );
    }).toList();
  }

  Widget _buildMonthPieChart() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: FutureBuilder(
        future: _fetchCombinedDocs(),
        builder: (context,
            AsyncSnapshot<List<QueryDocumentSnapshot<Object?>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docsForMonthYear = snapshot.data!.where((doc) {
            final date =
                doc['date']; // Assuming date is stored as a Timestamp or String
            if (date is Timestamp) {
              return date.toDate().month == _currentMonthIndex + 1 &&
                  date.toDate().year == _currentYear;
            } else if (date is String) {
              final dateTime = DateTime.parse(date);
              return dateTime.month == _currentMonthIndex + 1 &&
                  dateTime.year == _currentYear;
            } else {
              return false; // Invalid date format
            }
          }).toList();

          if (docsForMonthYear.isEmpty) {
            return _buildEmptyPieChart();
          }

          Map<String, int> stats = calculateMonthlyStats(docsForMonthYear);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 300,
              child: PieChart(
                PieChartData(
                  sections: getSections(stats, docsForMonthYear),
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyPieChart() {
    return Container(
      height: 300,
      color: Colors.grey[300],
      child: Center(
        child: PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                color: Colors.grey[300]!,
                value: 0.01,
                title: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDescriptionBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _currentDayIndex,
                  onChanged: (int? newIndex) {
                    setState(() {
                      _currentDayIndex = newIndex!;
                      _currentDay = newIndex + 1;
                    });
                  },
                  items: List.generate(31, (index) => index + 1).map((day) {
                    return DropdownMenuItem<int>(
                      value: day - 1,
                      child: Text(day.toString()),
                    );
                  }).toList(),
                ),
                SizedBox(width: 20),
                DropdownButton<int>(
                  value: _currentMonth - 1,
                  onChanged: (int? newIndex) {
                    setState(() {
                      _currentMonth = newIndex! + 1;
                    });
                  },
                  items: _months.asMap().entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                ),
                SizedBox(width: 20),
                DropdownButton<int>(
                  value: _currentYear,
                  onChanged: (int? newYear) {
                    setState(() {
                      _currentYear = newYear!;
                    });
                  },
                  items: _buildYearDropdownItems(),
                ),
              ],
            ),
          ),
          _buildDailyPieChart(),
        ],
      ),
    );
  }

  Widget _buildDailyPieChart() {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: FutureBuilder(
        future: _fetchCombinedDocs(),
        builder: (context,
            AsyncSnapshot<List<QueryDocumentSnapshot<Object?>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

        final docsForDay = snapshot.data!.where((doc) {
          final date = doc['date']; // Assuming date is stored as a Timestamp or String
          if (date is Timestamp) {
            return date.toDate().day == _currentDay &&
                   date.toDate().month == _currentMonth &&
                   date.toDate().year == _currentYear;
          } else if (date is String) {
            final dateTime = DateTime.parse(date);
            return dateTime.day == _currentDay &&
                   dateTime.month == _currentMonth &&
                   dateTime.year == _currentYear;
          } else {
            return false; // Invalid date format
          }
        }).toList();

        if (docsForDay.isEmpty) {
          return _buildEmptyPieChart();
        }

        Map<String, int> stats = calculateDailyStats(docsForDay);

        return SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: getSections(stats, docsForDay),
              centerSpaceRadius: 40,
            ),
          ),
        );
      },
    ),
  );
}

  

  Widget _buildDescriptionBox() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.red, 'Cancel'),
              _buildLegendItem(Colors.green, 'Complete'),
              _buildLegendItem(Colors.blue, 'Waiting'),
              _buildLegendItem(Colors.yellow.shade800, 'Assigned'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 4),
        Text(text),
      ],
    );
  }

  String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  String _getMonth(int monthNumber) {
    return _months[monthNumber - 1];
  }

  Map<String, int> calculateDailyStats(List<QueryDocumentSnapshot> docs) {
    Map<String, int> stats = {
      'Assigned': 0,
      'Cancel': 0,
      'Complete': 0,
      'Waiting': 0,
      'NoStatus': 0,
    };

    docs.forEach((doc) {
      var workData = doc.data() as Map<String, dynamic>;
      String lastStatus = workData['statuses'].isNotEmpty
          ? workData['statuses'].last
          : 'NoStatus';
      stats[lastStatus] = stats[lastStatus]! + 1;
    });

    return stats;
  }

  Map<String, int> calculateMonthlyStats(List<QueryDocumentSnapshot> docs) {
    Map<String, int> stats = {
      'Assigned': 0,
      'Cancel': 0,
      'Complete': 0,
      'Waiting': 0,
      'NoStatus': 0,
    };

    docs.forEach((doc) {
      var workData = doc.data() as Map<String, dynamic>;
      String lastStatus = workData['statuses'].isNotEmpty
          ? workData['statuses'].last
          : 'NoStatus';
      stats[lastStatus] = stats[lastStatus]! + 1;
    });

    return stats;
  }

  List<PieChartSectionData> getSections(
      Map<String, int> stats, List<QueryDocumentSnapshot> docs) {
    return stats.entries.map((entry) {
      return PieChartSectionData(
        color: getColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
        badgeWidget: GestureDetector(
          onTap: () => _showWorkDetails(entry.key, docs),
          child: Container(
            width: 100,
            height: 100,
            color: Colors.transparent,
          ),
        ),
      );
    }).toList();
  }

  Color getColor(String status) {
    switch (status) {
      case 'Assigned':
        return Colors.yellow.shade800;
      case 'Cancel':
        return Colors.red;
      case 'Complete':
        return Colors.green;
      case 'Waiting':
        return Colors.blue;
      case 'NoStatus':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

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

  Future<List<QueryDocumentSnapshot<Object?>>> _fetchCombinedDocs() async {
    final dispatcherQuery =
        FirebaseFirestore.instance.collection('works').get();

    final results = await dispatcherQuery;

    final filteredDocs = results.docs.where((doc) {
      var workData = doc.data() as Map<String, dynamic>;
      return workData['dispatcherID'] == _firstName ||
          workData['employeeId'] == _firstName ||
          workData['GateoutID'] == _firstName;
    }).toList();

    return filteredDocs.cast<QueryDocumentSnapshot<Object?>>();
  }

  void _showWorkDetails(String status, List<QueryDocumentSnapshot> docs) {
    List<QueryDocumentSnapshot> filteredDocs = docs.where((doc) {
      var workData = doc.data() as Map<String, dynamic>;
      String lastStatus = workData['statuses'].isNotEmpty
          ? workData['statuses'].last
          : 'NoStatus';
      return lastStatus == status;
    }).toList();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            var workData = filteredDocs[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text('Work ID: ${workData['workID']}'),
              subtitle: Text('Details: ${workData['blNo']}'),
            );
          },
        );
      },
    );
  }
}
