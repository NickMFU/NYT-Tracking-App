import 'package:flutter/material.dart';
import 'package:namyong_demo/component/form_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecordDamagePage extends StatefulWidget {
  @override
  _RecordDamagePageState createState() => _RecordDamagePageState();
}

class _RecordDamagePageState extends State<RecordDamagePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _vinController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Damage'),
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
              validText: 'Please enter a description', // Set the maximum number of lines for the TextField
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Save data to Firebase
                  saveDamageToFirebase();
                }
              },
              child: Text('Record Damage'),
            ),
          ],
        ),
      ),
    );
  }

  void saveDamageToFirebase() async {
    try {
      // Get a reference to the Firestore database
      final CollectionReference damageCollection = FirebaseFirestore.instance.collection('Damage');

      // Generate a unique DamageID based on timestamp
      String damageID = 'Damage_${DateTime.now().millisecondsSinceEpoch}';

      // Create a map of data to save, including the DamageID
      Map<String, dynamic> damageData = {
        'damageID': damageID,
        'vin': _vinController.text,
        'description': _descriptionController.text,
      };

      // Add the data to Firestore
      await damageCollection.add(damageData);

      // Optionally, you can show a success message or navigate to another screen
      // based on your application's requirements.
      print('Damage data saved to Firestore successfully! DamageID: $damageID');
    } catch (e) {
      // Handle errors, e.g., show an error message
      print('Error saving damage data: $e');
    }
  }
}
