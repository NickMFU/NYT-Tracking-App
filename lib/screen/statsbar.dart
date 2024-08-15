import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:namyong_demo/screen/Stats.dart';
import 'package:namyong_demo/screen/time_report.dart';

class StatsbarPage extends StatefulWidget {
  @override
  _StatsbarPageState createState() => _StatsbarPageState();
}

class _StatsbarPageState extends State<StatsbarPage>
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
                const Icon(Icons.history, color: Color.fromARGB(255, 255, 255, 255)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
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
            MaterialPageRoute(builder: (context) => StatsPage()),
          );
        },
        child: Icon(Icons.pie_chart),
      ),
    );
  }

  Widget _buildMonthlyStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
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
          _buildMonthBarChart(),
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

  Widget _buildMonthBarChart() {
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
          final date = doc['date'];
          if (date is Timestamp) {
            return date.toDate().month == _currentMonthIndex + 1 &&
                date.toDate().year == _currentYear;
          } else if (date is String) {
            final dateTime = DateTime.parse(date);
            return dateTime.month == _currentMonthIndex + 1 &&
                dateTime.year == _currentYear;
          } else {
            return false;
          }
        }).toList();

        if (docsForMonthYear.isEmpty) {
          return _buildEmptyBarChart();
        }

        Map<String, int> stats = calculateMonthlyStats(docsForMonthYear);

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 400,
            child: BarChart(
              BarChartData(
                barGroups: getBarGroups(stats),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(color: Colors.black, fontSize: 12),
                          );
                        } else {
                          return Container();
                        }
                      },
                      interval: 1,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Assigned',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 1:
                            return const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 2:
                            return const Text('Complete',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 3:
                            return const Text('Waiting',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 4:
                            return const Text('NoStatus',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                maxY: 10,
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildEmptyBarChart() {
    return Container(
      height: 300,
      color: Colors.grey[300],
      child: Center(
        child: Text('No Data Available'),
      ),
    );
  }

  Widget _buildDailyStats() {
    return SingleChildScrollView(
      child: Column(
        children: [
          
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
          _buildDailyBarChart(),
        ],
      ),
    );
  }

  Widget _buildDailyBarChart() {
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

          final docsForDayMonthYear = snapshot.data!.where((doc) {
            final date = doc['date'];
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
              return false;
            }
          }).toList();

          if (docsForDayMonthYear.isEmpty) {
            return _buildEmptyBarChart();
          }

          Map<String, int> stats = calculateDailyStats(docsForDayMonthYear);

          return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 400,
            child: BarChart(
              BarChartData(
                barGroups: getBarGroups(stats),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 == 0) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(color: Colors.black, fontSize: 12),
                          );
                        } else {
                          return Container();
                        }
                      },
                      interval: 1,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Assigned',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 1:
                            return const Text('Cancel',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 2:
                            return const Text('Complete',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 3:
                            return const Text('Waiting',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          case 4:
                            return const Text('NoStatus',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12));
                          default:
                            return const Text('');
                        }
                      },
                    ),
                  ),
                ),
                maxY: 10,
                ),
              ),
            ),
          );
        },
      ),
    );
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
      String lastStatus = 'NoStatus';

      if (workData.containsKey('statuses') && workData['statuses'].isNotEmpty) {
        lastStatus = workData['statuses'].last;
      }

      stats[lastStatus] = (stats[lastStatus] ?? 0) + 1;
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
      String lastStatus = 'NoStatus';

      if (workData.containsKey('statuses') && workData['statuses'].isNotEmpty) {
        lastStatus = workData['statuses'].last;
      }

      stats[lastStatus] = (stats[lastStatus] ?? 0) + 1;
    });

    return stats;
  }

  List<BarChartGroupData> getBarGroups(Map<String, int> stats) {
    return [
      BarChartGroupData(x: 0, barRods: [
        BarChartRodData(
          toY: stats['Assigned']?.toDouble() ?? 0,
          color: Colors.yellow.shade800,
        )
      ]),
      BarChartGroupData(x: 1, barRods: [
        BarChartRodData(
          toY: stats['Cancel']?.toDouble() ?? 0,
          color: Colors.red,
        )
      ]),
      BarChartGroupData(x: 2, barRods: [
        BarChartRodData(
          toY: stats['Complete']?.toDouble() ?? 0,
          color: Colors.green,
        )
      ]),
      BarChartGroupData(x: 3, barRods: [
        BarChartRodData(
          toY: stats['Waiting']?.toDouble() ?? 0,
          color: Colors.blue,
        )
      ]),
      
    ];
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
  
  Widget _buildDescriptionBox() {
    return Container(
      color: Color.fromARGB(255, 117, 177, 255),
      width: double.infinity,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Text(
            "Welcome $_firstName!",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
         
        ],
      ),
    );
  }
}

