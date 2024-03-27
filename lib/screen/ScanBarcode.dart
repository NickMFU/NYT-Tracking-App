import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();
    _scanBarcodeCollection = FirebaseFirestore.instance
        .collection('works')
        .doc(widget.workID) // Use workID as the document ID
        .collection('Scanbarcode');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveScannedBarcodes,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _scanBarcode();
              },
              child: Text('Scan Barcode'),
            ),
            SizedBox(height: 20),
            Text(
              'Scanned Barcodes:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
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
            const SizedBox(height: 20),
            TextField(
              controller: _tractorRegistrationController,
              decoration: const InputDecoration(
                labelText: 'Tractor Registration',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
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

      // Clear scanned barcodes after saving
      setState(() {
        _scannedBarcodes.clear();
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
    });
  }

  @override
  void dispose() {
    _tractorRegistrationController.dispose();
    super.dispose();
  }
}