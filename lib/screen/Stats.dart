import 'package:flutter/material.dart';

class UserStatistics {
  final String month;
  final int numberOfTasksCompleted;
  final int hoursWorked;

  UserStatistics({
    required this.month,
    required this.numberOfTasksCompleted,
    required this.hoursWorked,
  });
}

class StaticPage extends StatefulWidget {
  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  late List<UserStatistics> _userStats;

  @override
  void initState() {
    super.initState();
    // Fetch user statistics from Firestore or any other data source
    _userStats = _fetchUserStatistics();
  }

  List<UserStatistics> _fetchUserStatistics() {
    // Implement code to fetch user statistics from Firestore or any other data source
    // This is just a mock example, replace it with your actual implementation
    return [
      UserStatistics(month: 'January', numberOfTasksCompleted: 10, hoursWorked: 50),
      UserStatistics(month: 'February', numberOfTasksCompleted: 15, hoursWorked: 60),
      UserStatistics(month: 'March', numberOfTasksCompleted: 20, hoursWorked: 70),
      // Add more data for other months as needed
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Statistics'),
      ),
      body: ListView.builder(
        itemCount: _userStats.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Month: ${_userStats[index].month}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tasks Completed: ${_userStats[index].numberOfTasksCompleted}'),
                Text('Hours Worked: ${_userStats[index].hoursWorked}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
