import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PDFTimereport extends StatefulWidget {
 


  @override
  _PDFTimereportState createState() => _PDFTimereportState();
}

class _PDFTimereportState extends State<PDFTimereport> {
  bool _isGeneratingPDF = true;

  @override
  void initState() {
    super.initState();
   
  }

  Future<void> generateAndOpenPDF(Map<String, dynamic> workData,
      List<dynamic> barcodeData, BuildContext context) async {
    final pdf = pw.Document();

    // Load the logo image as a PDF image
    final Uint8List logoImage =
        (await rootBundle.load('assets/images/playstore-icon.png'))
            .buffer
            .asUint8List();

    final Uint8List sig1Image =
        (await rootBundle.load('assets/images/sig1.png')).buffer.asUint8List();

    final Uint8List sig2Image =
        (await rootBundle.load('assets/images/sig2.png')).buffer.asUint8List();

    final Uint8List sig3Image =
        (await rootBundle.load('assets/images/sig3.png')).buffer.asUint8List();

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
                  // Container with text
                  pw.Container(
                    width: 500, // Adjust width as needed
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'บริษัท นางยง เมอมินัล จำกัด มหาชน\nNAMYONG TERMINAL PUBLIC COMPANY LIMITED',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 15,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          '1168/52(อาคารลุมพินีทาวเวอร์ ชั้น 19)ถนนพระราม4 แขวงทุ่งมหาเมฆ เขตสาทร กรุงเทพ 10120 โทรศัพท์ 0-2679-7357 (6 คู่สาย โทรสาร 0-2285-6652)',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          '1168/52 (LUMPINI TOWER 19th FL)RAMA IV ROAD, TUNGMAHAMEK,SATHORN,BANGKOK 10120 TEL:+66(0)2679-7357(6 LINES)FAX:66(0)2285-6642',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          '51 หมู่ 3 ท่าเรือแหลมฉบัง ต.ทุ่งสุขลา อ.ศรีราชา จ.ชลบุรี 20230 โทรศัพท์ 0-3840-1062-4 โทรสาร 0-3840-10120 E-mail: a5@namyongterminal.com',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.Text(
                          '51 MOO 3, LAEM CHABANG PORT,TOONGSUKHLA,SRIRACHA CHONBURI 20230 TEL: 66(0)-3840-1062-4 FAX: 66(0)-3840-10120 E-mail: a5@namyongterminal.com',
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Divider(),
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
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 30,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                      '',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      '',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      '',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),

            
            pw.Spacer(),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Footer section
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      // First line of the footer
                      pw.Row(
                        children: [
                          // Left image
                          pw.Container(
                            width: 100, // Adjust width as needed
                            height: 80, // Adjust height as needed
                            child: pw.Column(
                              children: [
                                pw.Image(
                                  pw.MemoryImage(
                                      sig1Image), // Use your image here
                                ),
                                pw.Text(
                                  '',
                                  style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 15,
                                    color: PdfColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Second line of the footer
                      pw.Row(
                        children: [
                          // Left image
                          pw.Container(
                            width: 100, // Adjust width as needed
                            height: 80, // Adjust height as needed
                            child: pw.Column(
                              children: [
                                pw.Image(
                                  pw.MemoryImage(
                                      sig2Image), // Use your image here
                                ),
                                pw.Text(''),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          // Left image
                          pw.Container(
                            width: 100, // Adjust width as needed
                            height: 80, // Adjust height as needed
                            child: pw.Column(
                              children: [
                                pw.Image(
                                  pw.MemoryImage(
                                      sig3Image), // Use your image here
                                ),
                                pw.Text(''),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/work_details_${workData['workID']}.pdf');
    await file.writeAsBytes(await pdf.save());

    setState(() {
      _isGeneratingPDF = false;
    });

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Preview'),
      ),
      body: Center(
        child: _isGeneratingPDF
            ? CircularProgressIndicator() // Show loading indicator while generating PDF
            : Text(
                'PDF Generated'), // You can replace this with any widget or leave it empty
      ),
    );
  }
}
