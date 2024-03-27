import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namyong_demo/screen/pdf_mainfest.dart';

class Summarywork extends StatelessWidget {
  final String workID;

  Summarywork({required this.workID});

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
                Color.fromARGB(196, 14, 94, 253),
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
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PDFPage(workData: workData),
                                ),
                              );
                            },
                            child: Text('Generate PDF'),
                          ),
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
            _buildDetail('Checker', workData['employeeId']),
            _buildDetail('Vessel', workData['vessel']),
            _buildDetail('Voy', workData['voy']),
            _buildDetail('Shipping', workData['shipping']),
            _buildBarcodes(workData['Scanbarcode']),
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
    // Fetch data from the "works" collection
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('works')
            .where('workID', isEqualTo: workID)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the document data from the "works" collection
      Map<String, dynamic> workData = querySnapshot.docs.first.data();

      // Fetch data from the "Scanbarcode" collection within the document
      QuerySnapshot<Map<String, dynamic>> scanBarcodeSnapshot =
          await FirebaseFirestore.instance
              .collection('works')
              .doc(workID) // Reference the specific document using workID
              .collection('Scanbarcode')
              .get();
        

      // Add the data from the "Scanbarcode" collection to the workData map
      workData['Scanbarcode'] = scanBarcodeSnapshot.docs.map((doc) => doc.data()).toList();

      return workData;
    } else {
      return null;
    }
  } catch (error) {
    print('Error fetching work data: $error');
    throw error;
  }
}

 Widget _buildDetail(String label, dynamic value) {
  if (value is List<String>) {
    // If the value is a list of strings (barcodes), display each barcode
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: value.map((barcode) {
            return Text(
              barcode,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                color: Colors.black,
              ),
            );
          }).toList(),
        ),
        Divider(color: Colors.grey), // Add a divider
        const SizedBox(height: 12),
      ],
    );
  } else {
    // If the value is not a list, display it as a single value
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
          value.toString(),
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
Widget _buildBarcodes(List<dynamic> barcodes) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Load to Tractor',
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: barcodes.map((barcodeData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car: ${barcodeData['barcode1']}', // Assuming the barcode data contains a 'barcode' field
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tractor Registration: ${barcodeData['tractorRegistration']}', // Assuming the barcode data contains a 'tractorRegistration' field
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              Divider(color: Colors.grey), // Add a divider
              const SizedBox(height: 6),
            ],
          );
        }).toList(),
      ),
      Divider(color: Colors.grey), // Add a divider
      const SizedBox(height: 12),
    ],
  );
}
}
