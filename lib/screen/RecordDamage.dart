import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecordDamagePage extends StatefulWidget {
  final String workID;

  RecordDamagePage({required this.workID});

  @override
  _RecordDamagePageState createState() => _RecordDamagePageState();
}

class _RecordDamagePageState extends State<RecordDamagePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _vinController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<File> _images = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 202, 228, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Record damage",
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
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _vinController,
              decoration: InputDecoration(labelText: 'VIN No'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a VIN No';
                }
                return null;
              },
            ),
            SizedBox(height: 15.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Select Image'),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.file(_images[index]),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: saveDamageToFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color.fromARGB(255, 4, 6, 126), // Background color
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.05,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    "Record Damage",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

 void saveDamageToFirebase() async {
  if (_formKey.currentState!.validate()) {
    try {
      final CollectionReference damageCollection = FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workID)
          .collection('Damage');

      Map<String, dynamic> damageData = {
        'workID': widget.workID, // Use work ID as the document ID
        'vin': _vinController.text,
        'description': _descriptionController.text,
      };

      List<String> imageUrls = [];

      for (File imageFile in _images) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('damage_images/${widget.workID}');
        await storageReference.putFile(imageFile);
        String imageUrl = await storageReference.getDownloadURL();
        imageUrls.add(imageUrl);
      }

      damageData['imageUrls'] = imageUrls;

      await damageCollection.doc(widget.workID).set(damageData);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Damage recorded successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recording damage: $e')));
    }
  }
}
}
