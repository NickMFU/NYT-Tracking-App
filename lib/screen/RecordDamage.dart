import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

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
  List<XFile> _images = [];
  List<File> _imageFiles = []; // For mobile
  List<Uint8List> _webImages = []; // For web

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 202, 228, 255),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Record Damage",
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
            const SizedBox(height: 15.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              style: GoogleFonts.notoSansThai(), // Use a font that supports Thai
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: getImage,
              child: const Text('Select Image'),
            ),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: kIsWeb ? _webImages.length : _images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: kIsWeb
                        ? Image.memory(_webImages[index])
                        : Image.file(File(_images[index].path)),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: saveDamageToFirebase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 4, 6, 126), // Background color
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
    if (kIsWeb) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        var bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImages.add(bytes);
        });
      }
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _images.add(pickedFile);
          _imageFiles.add(File(pickedFile.path));
        });
      }
    }
  }

  Future<void> saveDamageToFirebase() async {
    if (_formKey.currentState!.validate()) {
      try {
        final CollectionReference damageCollection = FirebaseFirestore.instance
            .collection('works')
            .doc(widget.workID)
            .collection('Damage');

        String damageID = Uuid().v4(); // Generate a unique ID for each damage record

        Map<String, dynamic> damageData = {
          'damageID': damageID,
          'workID': widget.workID,
          'vin': _vinController.text,
          'description': _descriptionController.text,
        };

        List<String> imageUrls = [];

        if (kIsWeb) {
          for (Uint8List webImage in _webImages) {
            String uniqueImageID = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance.ref().child('damage_images/$uniqueImageID');
            UploadTask uploadTask = storageReference.putData(webImage);
            TaskSnapshot taskSnapshot = await uploadTask;
            String imageUrl = await taskSnapshot.ref.getDownloadURL();
            imageUrls.add(imageUrl);
          }
        } else {
          for (File imageFile in _imageFiles) {
            String uniqueImageID = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance.ref().child('damage_images/$uniqueImageID');
            UploadTask uploadTask = storageReference.putFile(imageFile);
            TaskSnapshot taskSnapshot = await uploadTask;
            String imageUrl = await taskSnapshot.ref.getDownloadURL();
            imageUrls.add(imageUrl);
          }
        }

        damageData['imageUrls'] = imageUrls;

        await damageCollection.doc(damageID).set(damageData);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Damage recorded successfully!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error recording damage: $e')));
      }
    }
  }
}
