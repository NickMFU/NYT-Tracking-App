import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show ByteData, rootBundle;

class Statement {
  final String name;
  final String phone;
  final String email;
  final String month;
  final String year;
  final double totalEarning;
  final double movingCost;
  final double travelCost;
  final double serviceFee;
  final double gst;
  final double tips;
  final double refund;
  final int numberOfJobs;

  Statement({
    required this.name,
    required this.phone,
    required this.email,
    required this.month,
    required this.year,
    required this.totalEarning,
    required this.movingCost,
    required this.travelCost,
    required this.serviceFee,
    required this.gst,
    required this.tips,
    required this.refund,
    required this.numberOfJobs,
  });
}

class MyWidget extends StatelessWidget {
  final Statement statement;

  MyWidget({required this.statement});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Your widget structure here
    );
  }
}

class MyPage extends StatelessWidget {
  final Statement statement;

  MyPage({required this.statement});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _printScreen(context, statement);
          },
          child: Text('Print PDF'),
        ),
      ),
    );
  }

  void _printScreen(BuildContext context, Statement statement) async {
    Directory? directory;
    final ByteData fontData =
        await rootBundle.load('assets/fonts/Outfit/static/Outfit-Regular.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_text.png'))
          .buffer
          .asUint8List(),
    );

    try {
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.ListView(
              children: [
                pw.Container(
                  padding: pw.EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Image(
                        image,
                        width: 120,
                        fit: pw.BoxFit.contain,
                      ),
                      pw.SizedBox(height: 50),
                      pw.Text(
                        "${statement.name}",
                        style: pw.TextStyle(font: ttf),
                      ),
                      pw.Text(
                        "${statement.phone}",
                        style: pw.TextStyle(font: ttf),
                      ),
                      pw.Text(
                        "${statement.email}",
                        style: pw.TextStyle(font: ttf),
                      ),
                      // Add more text widgets as needed
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Document directory not available"),
          ),
        );
        return;
      }

      String path = directory.path;
      String myFile =
          '${path}/Tingsapp-statement-${statement.month}-${statement.year}.pdf';
      final file = File(myFile);
      await file.writeAsBytes(await doc.save());
      OpenFile.open(myFile);
    } catch (e) {
      debugPrint("$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$e"),
        ),
      );
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: MyPage(
      statement: Statement(
        name: 'John Doe',
        phone: '123-456-7890',
        email: 'john.doe@example.com',
        month: 'January',
        year: '2024',
        totalEarning: 1500.0,
        movingCost: 200.0,
        travelCost: 100.0,
        serviceFee: 300.0,
        gst: 50.0,
        tips: 100.0,
        refund: 0.0,
        numberOfJobs: 10,
      ),
    ),
  ));
}
