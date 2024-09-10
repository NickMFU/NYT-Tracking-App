import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

class ScanBarcodePage extends StatefulWidget {
  final String workID;

  ScanBarcodePage({required this.workID});

  @override
  _ScanBarcodePageState createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  List<String> _scannedBarcodes = [];
  late CollectionReference _scanBarcodeCollection;
  TextEditingController _tractorRegistrationController = TextEditingController();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _scanBarcodeCollection = FirebaseFirestore.instance
        .collection('works')
        .doc(widget.workID)
        .collection('Scanbarcode');

    // Add listener to the text field to update button state
    _tractorRegistrationController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    // Update the button state based on input
    setState(() {
      _isButtonEnabled = _tractorRegistrationController.text.isNotEmpty &&
          _scannedBarcodes.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 202, 228, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Load car to tractor",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.white),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          TextField(
            controller: _tractorRegistrationController,
            decoration: const InputDecoration(
              labelText: 'Tractor Registration',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _updateButtonState(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _scanBarcode,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 4, 6, 126), // Background color
            ),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt, // Choose the appropriate icon
                    color: Colors.white, // Icon color
                  ),
                  SizedBox(width: 8), // Add some space between icon and text
                  Text(
                    "Scan Barcode",
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
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _scannedBarcodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_scannedBarcodes[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteBarcode(index);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isButtonEnabled ? _saveScannedBarcodes : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isButtonEnabled
                    ? Color.fromARGB(255, 4, 6, 126)
                    : Colors.grey, // Disable button when not enabled
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "Load to Tractor",
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode() async {
    try {
      String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // color of the toolbar
        'Cancel', // text for the cancel button
        true, // show flash icon
        ScanMode.BARCODE, // specify the scan mode
      );

      if (!mounted) return;

      setState(() {
        _scannedBarcodes.add(barcodeResult);
        _updateButtonState(); // Update button state after scanning
      });
    } catch (e) {
      // Handle error
      print('Error: $e');
    }
  }

  void _saveScannedBarcodes() async {
    try {
      Map<String, dynamic> barcodesData = {};

      _scannedBarcodes.asMap().forEach((index, barcode) {
        barcodesData['barcode${index + 1}'] = barcode;
      });

      barcodesData['tractorRegistration'] = _tractorRegistrationController.text;
      barcodesData['timestamp'] = FieldValue.serverTimestamp();

      await _scanBarcodeCollection.doc(widget.workID).set(barcodesData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scanned barcodes saved successfully'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _scannedBarcodes.clear();
        _updateButtonState(); // Update button state after saving
      });
    } catch (e) {
      print('Error saving barcodes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save scanned barcodes'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _deleteBarcode(int index) {
    setState(() {
      _scannedBarcodes.removeAt(index);
      _updateButtonState(); // Update button state after deleting
    });
  }

  @override
  void dispose() {
    _tractorRegistrationController.dispose();
    super.dispose();
  }
}
