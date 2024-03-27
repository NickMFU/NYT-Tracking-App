import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namyong_demo/component/form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            DefaultFormField(
              hint: 'VIN No',
              controller: _vinController,
              validText: 'Please enter a VIN No',
            ),
            const SizedBox(height: 15.0),
            DefaultFormField(
              hint: 'Description',
              controller: _descriptionController,
              validText:
                  'Please enter a description', // Set the maximum number of lines for the TextField
            ),
            SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              height: 300, 
              child: ElevatedButton(
                onPressed: () {
                  getImage();
                },
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, size: 50), // Adjust icon size as needed
                    SizedBox(
                        height: 10), // Add some space between icon and text
                    Text('Select Image'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
           ElevatedButton(
                        onPressed: saveDamageToFirebase,
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
                                  "Record Damge",
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
        _image = File(pickedFile.path);
      });
    }
  }

  void saveDamageToFirebase() async {
    try {
      final CollectionReference damageCollection = FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workID)
          .collection('Damage');
      String damageID = 'Damage_${DateTime.now().millisecondsSinceEpoch}';

      // Prepare the data to be saved to Firestore
      Map<String, dynamic> damageData = {
        'damageID': damageID,
        'vin': _vinController.text,
        'description': _descriptionController.text,
      };

      // Upload the image to Firebase Storage if available
      if (_image != null) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('damage_images/$damageID');
        await storageReference.putFile(_image!);
        String imageUrl = await storageReference.getDownloadURL();
        damageData['imageUrl'] = imageUrl;
      }

      // Save the damage data to Firestore
      await damageCollection.doc(damageID).set(damageData);

      print('Damage data saved to Firestore successfully! DamageID: $damageID');
    } catch (e) {
      // Handle errors, e.g., show an error message
      print('Error saving damage data: $e');
    }
  }
}
