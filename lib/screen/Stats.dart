import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class StaticPage extends StatefulWidget {
  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  List<Work> works = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('works').get();
      works = snapshot.docs.map((doc) => Work.fromSnapshot(doc)).toList();
      setState(() {}); // Update the state to rebuild the UI
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Works by Month'),
      ),
      body: Center(
        child: works.isNotEmpty
            ? PieChart(
                PieChartData(
                  sections: _generateSections(),
                ),
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  List<PieChartSectionData> _generateSections() {
    Map<int, int> worksByMonth = {};
    works.forEach((work) {
      try {
        DateTime date = DateTime.parse(work.date);
        int month = date.month;
        worksByMonth[month] = (worksByMonth[month] ?? 0) + 1;
      } catch (e) {
        print('Error parsing date: $e');
      }
    });

    return worksByMonth.entries.map((entry) {
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key}',
        color: _getRandomColor(),
        radius: 100,
      );
    }).toList();
  }

  Color _getRandomColor() {
    return Color((0xFF000000 & DateTime.now().millisecondsSinceEpoch) |
        0xFF000000);
  }
}

class Work {
  final String date;

  Work({required this.date});

  factory Work.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Work(
      date: data['date'] ?? '',
    );
  }
}
