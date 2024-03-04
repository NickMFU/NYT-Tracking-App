import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namyong_demo/Component/bottom_nav.dart';
import 'package:namyong_demo/component/form_field.dart';
import 'package:namyong_demo/model/Work.dart';
import 'package:namyong_demo/screen/Notification.dart';
import 'package:namyong_demo/screen/Timeline.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';

class CreateWorkPage extends StatefulWidget {
  @override
  _CreateWorkPageState createState() => _CreateWorkPageState();
}

class _CreateWorkPageState extends State<CreateWorkPage> {
  final _formKey = GlobalKey<FormState>();
  final String? currentUserID = FirebaseAuth.instance.currentUser?.uid;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _consigneeController = TextEditingController();
  TextEditingController _vesselController = TextEditingController();
  TextEditingController _voyController = TextEditingController();
  TextEditingController _blNoController = TextEditingController();
  TextEditingController _shippingController = TextEditingController();
  TextEditingController _employeeIdController = TextEditingController();

  List<String> employees = [];
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;
// Added _image to store the selected image

  TimeOfDay? _estimatedCompletionTime;

  @override
  void initState() {
    super.initState();
    // Fetch employees from Firestore when the widget initializes
    fetchEmployees();
  }

  void fetchEmployees() async {
    try {
      // Assuming 'Employee' is the name of the collection in Firestore
      QuerySnapshot employeeSnapshot =
          await FirebaseFirestore.instance.collection('Employee').get();

      setState(() {
        // Update the employees list with the data from Firestore
        employees = employeeSnapshot.docs
            .map((doc) => doc.get('Firstname'))
            .where((employee) => employee != null)
            .map((employee) => employee.toString())
            .toList();

        // Print the employees list for debugging
        print(employees);
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }

  

  Future<void> getImage() async {
  final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 100,
        title: const Text(
          "Create work page",
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
                Color.fromARGB(196, 14, 94, 253),
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
             // Title above the form fields
            const Text(
              "WharfID (BL/No)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            DefaultFormField(
              hint: 'WharfID (BL/No)',
              controller: _blNoController,
              validText: 'Please enter a BL number',
            ),
            const SizedBox(height: 15.0),
            const Text(
              "Date",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            DefaultFormField(
              hint: 'Date',
              controller: _dateController,
              validText: 'Please enter a date',
            ),
            const SizedBox(height: 15.0),
             const Text(
              "Consignee",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            DefaultFormField(
              hint: 'Consignee',
              controller: _consigneeController,
              validText: 'Please enter a consignee',
            ),
            const SizedBox(height: 15.0),
             const Text(
              "Vessel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            DefaultFormField(
              hint: 'Vessel',
              controller: _vesselController,
              validText: 'Please enter a vessel',
            ),
            const SizedBox(height: 15.0),
             const Text(
              "Voy",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            DefaultFormField(
              hint: 'Voy',
              controller: _voyController,
              validText: 'Please enter a voyage number',
            ),
            const SizedBox(height: 15.0),
             const Text(
              "Shipping",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            DefaultFormField(
              hint: 'Shipping',
              controller: _shippingController,
              validText: 'Please enter shipping information',
            ),
            const SizedBox(height: 15.0),
             const Text(
              "Choose Checker",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            DropdownButtonFormField<String>(
              value: employees.contains(_employeeIdController.text)
                  ? _employeeIdController.text
                  : null,
              onChanged: (value) {
                setState(() {
                  _employeeIdController.text = value ?? '';
                });
              },
              items: employees
                  .map((employee) => DropdownMenuItem<String>(
                        value: employee,
                        child: Text(employee),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Select CheckerS',
              ),
            ),
            const SizedBox(height: 16.0),
             const Text(
              "Due time",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            ListTile(
              title: Text(
                'Set due time: ${_estimatedCompletionTime != null ? _estimatedCompletionTime!.format(context) : "Not set"}',
              ),
              onTap: () async {
                                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _estimatedCompletionTime ?? TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _estimatedCompletionTime = pickedTime;
                  });
                }
              },
            ),
            const SizedBox(height: 16.0),
             const Text(
              "Whalf Image",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15.0),
            ListTile(
              title: _image == null
                  ? const Text('Select Image')
                  : Image.file(_image!),
              onTap: () async {
                await getImage();
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  saveWorkToFirebase();
                }
              },
              child: const Text('Create Work'),
            ),
          ],
        ),
      ),
       bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  void navigateToAcceptWorkPage(String workID) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => AcceptWorkPage(createdWorkID: workID),
    ),
  );
}

  Future<void> saveWorkToFirebase() async {
  try {
    final CollectionReference workCollection =
        FirebaseFirestore.instance.collection('works');
        
    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? firstName = currentUser?.displayName?.split(' ')[0]; // Extract first name
    final String? lastName = currentUser?.displayName?.split(' ')[1]; // Extract last name

    String workID = 'Work_${Random().nextInt(90000) + 10000}';

    final String? currentUserID = FirebaseAuth.instance.currentUser?.uid;

     String responsiblePerson = '$firstName $lastName';

    // Upload the image to Firebase Storage
    String imageUrl = await uploadImageToFirebaseStorage(workID);

    Work work = Work(
      workID: workID,
      date: _dateController.text,
      consignee: _consigneeController.text,
      vessel: _vesselController.text,
      voy: _voyController.text,
      blNo: _blNoController.text,
      shipping: _shippingController.text,
      estimatedCompletionTime: _estimatedCompletionTime != null
          ? Duration(
              hours: _estimatedCompletionTime!.hour,
              minutes: _estimatedCompletionTime!.minute,
            )
          : null,
      employeeId: _employeeIdController.text,
      responsiblePerson: currentUserID ?? '',
      imageUrl: imageUrl, // Set the imageUrl in the Work model
      statuses: ['NoStatus'], // Set the initial status as "NoStatus"
    );

    Map<String, dynamic> workData = work.toMap();

    await workCollection.add(workData);

    print('Work data saved to Firestore successfully! WorkID: $workID');

    // Navigate to the AcceptWorkPage after creating the work
    navigateToAcceptWorkPage(workID);
  } catch (e) {
    print('Error saving work data: $e');
  }
}


  Future<String> uploadImageToFirebaseStorage(String workID) async {
    try {
      if (_image == null) {
        // If no image is selected, return an empty string
        return '';
      }

      // Create a reference to the Firebase Storage location
      Reference storageReference =
          FirebaseStorage.instance.ref().child('work_images/$workID.jpg');

      // Upload the file to Firebase Storage
      await storageReference.putFile(_image!);

      // Get the download URL of the uploaded file
      String downloadURL = await storageReference.getDownloadURL();

      print('Image uploaded to Firebase Storage. Download URL: $downloadURL');

      return downloadURL;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return '';
    }
  }
}

