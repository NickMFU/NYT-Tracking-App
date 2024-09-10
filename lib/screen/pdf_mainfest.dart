import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFPage extends StatefulWidget {
  final Map<String, dynamic> workData;
  final List<dynamic> barcodeData; // Add barcode data

  PDFPage({required this.workData, required this.barcodeData});

  @override
  _PDFPageState createState() => _PDFPageState();
}

class _PDFPageState extends State<PDFPage> {
  bool _isGeneratingPDF = true;

  @override
  void initState() {
    super.initState();
    generateAndOpenPDF(widget.workData, widget.barcodeData, context);
  }

  Future<void> generateAndOpenPDF(Map<String, dynamic> workData,
    List<dynamic> barcodeData, BuildContext context) async {
  final pdf = pw.Document();

  // Load the images and font
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
                pw.Image(
                  pw.MemoryImage(logoImage),
                  width: 150,
                  height: 100,
                ),
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
                  mainAxisAlignment: pw.MainAxisAlignment.center,
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
                    'สินค้าของบริษัท(Consignee):______${workData['consignee']}______ นำเข้าโดยเรือ(Vessel):______${workData['vessel']}_______',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    'Voy:______________${workData['voy']}______________เที่ยววันที่(Date of Arrival):______________${workData['date']}______________',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.Text(
                    'ใบตราส่งเลขที่(BL/No): __________${workData['blNo']}__________ตัวแทนเจ้าของบริษัท(Shipping): __________${workData['shipping']}__________',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 10,
                      color: PdfColors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Create the table rows based on barcode data
            pw.Table(
              border: null,
              children: [
                pw.TableRow(
                  children: [
    pw.Container(
      color: PdfColors.blue, // Set the background color to blue
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Text('Mark & Nos', style: pw.TextStyle(font: ttf, fontSize: 18, color: PdfColors.white)),
      ),
    ),
    pw.Container(
      color: PdfColors.blue, // Set the background color to blue
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Text('Pkgs', style: pw.TextStyle(font: ttf, fontSize: 18, color: PdfColors.white)),
      ),
    ),
    pw.Container(
      color: PdfColors.blue, // Set the background color to blue
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Text('Description', style: pw.TextStyle(font: ttf, fontSize: 18, color: PdfColors.white)),
      ),
    ),
    pw.Container(
      color: PdfColors.blue, // Set the background color to blue
      child: pw.Padding(
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Text('Remark', style: pw.TextStyle(font: ttf, fontSize: 18, color: PdfColors.white)),
      ),
    ),
  ],
                ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode1')) // Adjust condition as needed
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode1'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin1', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode2'))
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode2'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin2', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode3'))
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode3'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin3', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode4'))
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode4'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin6', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode5'))
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode5'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin6', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode6'))
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode6'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin6', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode7'))
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode7'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin7', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                for (var i = 0; i < barcodeData.length; i++)
                  if (barcodeData[i].containsKey('barcode8'))
                    pw.TableRow(
                      children: [
                        pw.Text(barcodeData[i]['barcode8'] ?? '', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('1.0', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('vin8', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                        pw.Text('-', style: pw.TextStyle(font: ttf, fontSize: 15, color: PdfColors.black)),
                      ],
                    ),
                // Continue for barcode3 to barcode8 if applicable
              ],
            ),

            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'สินค้าได้มีกรส่งมอบตามรายการเอกสารเรียนร้อย',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  'Tractor Registration: ${barcodeData.isNotEmpty ? barcodeData[0]['tractorRegistration'] ?? '' : ''}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 10,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Footer section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 100,
                          height: 80,
                          child: pw.Column(
                            children: [
                              pw.Image(
                                pw.MemoryImage(sig1Image),
                              ),
                              pw.Text(
                                '${workData['dispatcherID']}\n${workData['date']}',
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
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 100,
                          height: 80,
                          child: pw.Column(
                            children: [
                              pw.Image(
                                pw.MemoryImage(sig2Image),
                              ),
                              pw.Text('${workData['employeeId']}\n${workData['date']}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    pw.Row(
                      children: [
                        pw.Container(
                          width: 100,
                          height: 80,
                          child: pw.Column(
                            children: [
                              pw.Image(
                                pw.MemoryImage(sig3Image),
                              ),
                              pw.Text('${workData['GateoutID']}\n${workData['date']}'),
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
