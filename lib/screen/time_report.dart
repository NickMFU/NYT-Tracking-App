import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class TimeReportPage extends StatefulWidget {
  @override
  _TimeReportPageState createState() => _TimeReportPageState();
}

class _TimeReportPageState extends State<TimeReportPage> {
  late CollectionReference _worksRef;
  late String _firstName = '';

  @override
  void initState() {
    super.initState();
    _worksRef = FirebaseFirestore.instance.collection('works');
    _loadUserData();
  }

  Future<List<Map<String, dynamic>>> fetchWorkTimelines() async {
    QuerySnapshot worksSnapshot = await _worksRef.get();
    List<Map<String, dynamic>> workTimelines = [];

    for (var workDoc in worksSnapshot.docs) {
      String workID = workDoc.id;
      DocumentSnapshot timelineSnapshot = await _worksRef.doc(workID).collection('timeline').doc(workID).get();

      if (timelineSnapshot.exists) {
        Map<String, dynamic> data = timelineSnapshot.data() as Map<String, dynamic>;
        data['workID'] = workID;
        workTimelines.add(data);
      }
    }

    return workTimelines;
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('Employee')
            .doc(user.uid)
            .get();
        setState(() {
          _firstName = userData['Firstname'];
        });
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  Future<void> generateAndOpenPDF(Map<String, dynamic> workData, List<dynamic> timelineEntries) async {
    final pdf = pw.Document();

    // Load the logo image as a PDF image
    final Uint8List logoImage = (await rootBundle.load('assets/images/playstore-icon.png')).buffer.asUint8List();
    final Uint8List sig1Image = (await rootBundle.load('assets/images/sig1.png')).buffer.asUint8List();
    final Uint8List sig2Image = (await rootBundle.load('assets/images/sig2.png')).buffer.asUint8List();
    final Uint8List sig3Image = (await rootBundle.load('assets/images/sig3.png')).buffer.asUint8List();
    final ByteData fontData = await rootBundle.load('assets/fonts/THSarabunNew Bold.ttf');
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
                    mainAxisAlignment: pw.MainAxisAlignment.center, // Align the text to the center
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'ใบรายงานเวลา (Time Report)',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 25,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Divider(),
              pw.Center(
                child: pw.Container(
                  width: 300,
                  decoration: const pw.BoxDecoration(),
                  padding: pw.EdgeInsets.all(10),
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center, // Align the text to the center
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        '$_firstName',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 25,
                          color: PdfColors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pw.Container(
                width: 500,
                decoration: const pw.BoxDecoration(
                  color: PdfColors.white,
                ),
                padding: pw.EdgeInsets.all(10),
                child: pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Title',
                            style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Start Time',
                            style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Finish Time',
                            style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Duration',
                            style: pw.TextStyle(font: ttf, fontSize: 12, fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    ...timelineEntries.map((entry) {
                      DateTime? startTime = entry['startTime'] != null ? DateTime.parse(entry['startTime']) : null;
                      DateTime? finishTime = entry['finishTime'] != null ? DateTime.parse(entry['finishTime']) : null;
                      String title = entry['title'] ?? 'Unknown';
                      String duration = startTime != null && finishTime != null
                          ? '${finishTime.difference(startTime).inHours} hours ${finishTime.difference(startTime).inMinutes % 60} minutes'
                          : 'N/A';

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              title,
                              style: pw.TextStyle(font: ttf, fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              startTime?.toString() ?? 'N/A',
                              style: pw.TextStyle(font: ttf, fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              finishTime?.toString() ?? 'N/A',
                              style: pw.TextStyle(font: ttf, fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              duration,
                              style: pw.TextStyle(font: ttf, fontSize: 10),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              pw.Spacer(),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/Time_Report${workData['workID']}.pdf');
    await file.writeAsBytes(await pdf.save());

    setState(() {
      // _isGeneratingPDF = false;
    });

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Time Report ",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchWorkTimelines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data'));
          }

          List<Map<String, dynamic>> workTimelines = snapshot.data ?? [];

          if (workTimelines.isEmpty) {
            return Center(child: Text('No work timelines available'));
          }

          return ListView.builder(
            itemCount: workTimelines.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> workData = workTimelines[index];
              String workID = workData['workID'];
              List<dynamic> timelineEntries = workData['timelineEntries'];

              return ExpansionTile(
                title: Text('Work ID: $workID'),
                children: [
                  Column(
                    children: timelineEntries.map<Widget>((entry) {
                      DateTime? startTime = entry['startTime'] != null ? DateTime.parse(entry['startTime']) : null;
                      DateTime? finishTime = entry['finishTime'] != null ? DateTime.parse(entry['finishTime']) : null;
                      String title = entry['title'] ?? 'Unknown';
                      String content = entry['content'] ?? 'No content available';

                      return ListTile(
                        title: Text(title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(content),
                            if (startTime != null) Text('Start Time: $startTime'),
                            if (finishTime != null) Text('Finish Time: $finishTime'),
                            if (startTime != null && finishTime != null)
                              Text('Duration: ${finishTime.difference(startTime).inHours} hours ${finishTime.difference(startTime).inMinutes % 60} minutes'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  TextButton(
                    onPressed: () => generateAndOpenPDF(workData, timelineEntries),
                    child: Text('Generate PDF'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
