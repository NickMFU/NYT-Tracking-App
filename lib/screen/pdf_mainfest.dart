import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PDFPage extends StatelessWidget {
  final Map<String, dynamic> workData;

  PDFPage({required this.workData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Preview'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            generateAndOpenPDF(workData, context);
          },
          child: Text('Generate PDF'),
        ),
      ),
    );
  }

  Future<void> generateAndOpenPDF(
      Map<String, dynamic> workData, BuildContext context) async {
    final pdf = pw.Document();

    // Load the logo image as a PDF image
    final Uint8List logoImage =
        (await rootBundle.load('assets/images/playstore-icon.png'))
            .buffer
            .asUint8List();

    final ByteData fontData =
        await rootBundle.load('assets/fonts/THSarabunNew Bold.ttf');
    final ttf = pw.Font.ttf(fontData.buffer.asByteData());

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header section
             pw.Row(
  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  children: [
    // Logo
    pw.Image(
      pw.MemoryImage(logoImage),
      width: 150,
      height: 100,
    ),
    // Spacer to create space between logo and Lorem Ipsum text
    
    // Lorem Ipsum text
    pw.Container(
      width: 400, // Adjust width as needed
      child: pw.Text(
        'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam.',
        style: pw.TextStyle(fontSize: 12), // Adjust font size as needed
      ),
    ),
  ],
),
              
              pw.SizedBox(height: 20),
              pw.Divider(),

              // Title and other header content
              pw.Center(
                child: pw.Container(
                  width: 300,
                  decoration: const pw.BoxDecoration(),
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment
                        .center, // Align the text to the center
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'ใบกำกับสินค้า (Cargo Delivery)',
                        style:  pw.TextStyle(
                          font: ttf,
                          fontSize: 30,
                          color: PdfColors.black,
                        ),
                      ),
                       
                    ],
                  ),
                ),
              ),

              pw.SizedBox(height: 10),
              pw.Divider(),

              pw.Container(
                width: 500,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
                padding: pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                     pw.Text(
                      'Consignee:......${workData['consignee']}...... Vessel:......${workData['vessel']} ......Voy:......${workData['voy']}...... Date:......${workData['date']}...',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'BL/No: ..........${workData['blNo']}..........  Shipping: ..........${workData['shipping']}..........',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),

              pw.Table.fromTextArray(
                border: null,
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.blue,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headerAlignment: pw.Alignment.centerLeft,
                headerHeight: 30,
                headers: ['Mark', 'Pkgs', 'Description', 'Remark'],
                data: [
                  ['1', '5', 'Description 1', 'Remark 1'],
                  ['2', '10', 'Description 2', 'Remark 2'],
                  ['3', '15', 'Description 3', 'Remark 3'],
                ],
              ),

              // Footer section
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text('Footer Line 1'),
              pw.Text('Footer Line 2'),
              pw.Text('Footer Line 3'),
              pw.Text('Footer Line 4'),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/work_details_${workData['workID']}.pdf');
    await file.writeAsBytes(await pdf.save());

    OpenFile.open(file.path);
  }
}
