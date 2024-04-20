import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namyong_demo/screen/pdf_mainfest.dart';

class WorkDetailsScreen extends StatelessWidget {
  final String workID;

  WorkDetailsScreen({required this.workID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 247, 255),
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          'Work Details - $workID',
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
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
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(16.0),
            child: FutureBuilder(
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
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWorkCard(workData),
                          SizedBox(height: 20),
                          
                        ],
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
    );
  }

  Widget _buildWorkCard(Map<String, dynamic> workData) {
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetail('Work ID', workData['workID']),
            _buildDetail('Date', workData['date']),
            _buildDetail('BL/No', workData['blNo']),
            _buildDetail('Consignee', workData['consignee']),
            _buildDetail('Dispatcher',workData['dispatcherID']),
            _buildDetail('Checker', workData['employeeId']),
            _buildDetail('Vessel', workData['vessel']),
            _buildDetail('Voy', workData['voy']),
            _buildDetail('Shipping', workData['shipping']),
            SizedBox(height: 20), // Add some space
            _buildImage(workData['imageUrl']), // Display the image
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(imageUrl); // Display image from URL
    } else {
      return SizedBox(); // Return empty container if no image URL is provided
    }
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
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Divider(color: Colors.grey), // Add a divider
        const SizedBox(height: 12),
      ],
    );
  }
}
