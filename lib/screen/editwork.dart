import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditWorkPage extends StatefulWidget {
  final String workID;

  const EditWorkPage({Key? key, required this.workID}) : super(key: key);

  @override
  _EditWorkPageState createState() => _EditWorkPageState();
}

class _EditWorkPageState extends State<EditWorkPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _dateController = TextEditingController();
  TextEditingController _consigneeController = TextEditingController();
  TextEditingController _vesselController = TextEditingController();
  TextEditingController _voyController = TextEditingController();
  TextEditingController _blNoController = TextEditingController();
  TextEditingController _shippingController = TextEditingController();
  TextEditingController _employeeIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWorkData();
  }

  void fetchWorkData() async {
    try {
      DocumentSnapshot workSnapshot = await FirebaseFirestore.instance
          .collection('works')
          .doc(widget.workID)
          .get();

      if (workSnapshot.exists) {
        Map<String, dynamic> workData = workSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _dateController.text = workData['date'] ?? '';
          _consigneeController.text = workData['consignee'] ?? '';
          _vesselController.text = workData['vessel'] ?? '';
          _voyController.text = workData['voy'] ?? '';
          _blNoController.text = workData['blNo'] ?? '';
          _shippingController.text = workData['shipping'] ?? '';
          _employeeIdController.text = workData['employeeId'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching work data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Work'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _consigneeController,
                decoration: InputDecoration(labelText: 'Consignee'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _vesselController,
                decoration: InputDecoration(labelText: 'Vessel'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _voyController,
                decoration: InputDecoration(labelText: 'Voy'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _blNoController,
                decoration: InputDecoration(labelText: 'BL/No'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _shippingController,
                decoration: InputDecoration(labelText: 'Shipping'),
                // Add validation if needed
              ),
              TextFormField(
                controller: _employeeIdController,
                decoration: InputDecoration(labelText: 'Employee ID'),
                // Add validation if needed
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateWorkData();
                  }
                },
                child: Text('Update Work'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateWorkData() async {
    try {
      await FirebaseFirestore.instance.collection('works').doc(widget.workID).update({
        'date': _dateController.text,
        'consignee': _consigneeController.text,
        'vessel': _vesselController.text,
        'voy': _voyController.text,
        'blNo': _blNoController.text,
        'shipping': _shippingController.text,
        'employeeId': _employeeIdController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Work data updated successfully'),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      print('Error updating work data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating work data'),
        duration: Duration(seconds: 2),
      ));
    }
  }
}