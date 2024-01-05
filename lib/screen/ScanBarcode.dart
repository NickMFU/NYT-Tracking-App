import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScanBarcodePage extends StatefulWidget {
  @override
  _ScanBarcodePageState createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> {
  List<String> _scannedBarcodes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Barcode'),
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

  void _deleteBarcode(int index) {
    setState(() {
      _scannedBarcodes.removeAt(index);
    });
  }
}
