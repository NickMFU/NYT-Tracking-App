import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkDetailsPage extends StatelessWidget {
  final String workID;

  WorkDetailsPage({required this.workID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Work Details - $workID'),
      ),
      body: FutureBuilder(
        future: getWorkData(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              Map<String, dynamic>? workData = snapshot.data;
              if (workData != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetail('Work ID', workData['workID']),
                      _buildDetail('Date', workData['date']),
                      _buildDetail('Field 1', workData['field1']),
                      _buildDetail('Field 2', workData['field2']),
                      _buildDetail('Field 3', workData['field3']),
                      // Add more fields as needed
                    ],
                  ),
                );
              } else {
                return Center(child: Text('Work with ID $workID not found.'));
              }
            }
          }
        },
      ),
    );
  }

 Future<Map<String, dynamic>?> getWorkData() async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('works')
            .where('workID', isEqualTo: workID)
            .limit(1) // Limit to 1 document (assuming workID is unique)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data();
    } else {
      return null; // Document with the specified workID not found
    }
  } catch (error) {
    print('Error fetching work data: $error');
    throw error;
  }
}

  Widget _buildDetail(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '$value',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
