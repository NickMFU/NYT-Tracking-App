import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class WorkDetailsScreen extends StatelessWidget {
  final String workID;

  WorkDetailsScreen({required this.workID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        toolbarHeight: 100,
        title: Text('Work Details - $workID'),
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
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context)
                    .size
                    .width, // Set the width to match the screen width
                child: FutureBuilder(
                  future: getWorkData(),
                  builder:
                      (context, AsyncSnapshot<Map<String, dynamic>?> snapshot) {
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
                                _buildDetail('BL/No', workData['blNo']),
                                _buildDetail(
                                    'Consignee', workData['consignee']),
                                _buildDetail('Checker', workData['employeeId']),
                                _buildDetail('Vessel', workData['vessel']),
                                _buildDetail('Voy', workData['voy']),
                                _buildDetail('Shipping', workData['shipping']),
                                SizedBox(
                                    height: 100), // Adjust the height as needed
                              ],
                            ),
                          );
                        } else {
                          return Center(
                              child: Text('Work with ID $workID not found.'));
                        }
                      }
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> getWorkData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('works')
              .where('workID', isEqualTo: workID)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        return null;
      }
    } catch (error) {
      print('Error fetching work data: $error');
      throw error;
    }
  }

  Widget _buildDetail(String label, String value) {
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
        SizedBox(height: 20),
        Text(
          '$value',
          style: TextStyle(fontSize: 14, color: Colors.black),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
