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
                                  builder: (context) => PDFPage(
                                      workData: workData,
                                      barcodeData: workData['Scanbarcode']),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                  255, 4, 6, 126), // Background color
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Generate PDF",
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: Text('Work with ID $workID not found.'),
                      );
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
            _buildDetail('Dispatcher', workData['dispatcherID']),
            _buildDetail('Checker', workData['employeeId']),
            _buildDetail('Vessel', workData['vessel']),
            _buildDetail('Voy', workData['voy']),
            _buildDetail('Shipping', workData['shipping']),
            _buildBarcodes(workData['Scanbarcode']),
            SizedBox(height: 20),
            _buildImage(workData['imageUrl']),
          ],
        ),
      ),
    );
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
          children: barcodes.map<Widget>((barcodeData) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBarcodeDetail('VinNo', barcodeData['barcode1']),
                _buildBarcodeDetail(
                    'Tractor Registration', barcodeData['tractorRegistration']),
              ],
            );
          }).toList(),
        ),
        Divider(color: Colors.grey),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildImage(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(imageUrl);
    } else {
      return SizedBox();
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
        Map<String, dynamic> workData = querySnapshot.docs.first.data();

        QuerySnapshot<Map<String, dynamic>> scanBarcodeSnapshot =
            await FirebaseFirestore.instance
                .collection('works')
                .doc(workID)
                .collection('Scanbarcode')
                .get();

        workData['Scanbarcode'] =
            scanBarcodeSnapshot.docs.map((doc) => doc.data()).toList();

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
          Divider(color: Colors.grey),
          const SizedBox(height: 12),
        ],
      );
    } else {
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
          Divider(color: Colors.grey),
          const SizedBox(height: 12),
        ],
      );
    }
  }

  Widget _buildBarcodeDetail(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: GoogleFonts.dmSans(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Divider(color: Colors.grey),
        const SizedBox(height: 6),
      ],
    );
  }

  void navigateToPDFPage(BuildContext context, Map<String, dynamic> workData,
      List<dynamic> barcodeData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PDFPage(workData: workData, barcodeData: barcodeData),
      ),
    );
  }
}
