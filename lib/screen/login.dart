import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namyong_demo/Component/form_field.dart';
import 'package:namyong_demo/screen/DashBoard.dart';


class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _employeeIdController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('NYT-Tracking'),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NYT-Tracking',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue, // Set the color to blue
                fontFamily: 'Righteous', // Set the font to Righteous
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Image.asset(
              'assets/images/login.jpg', // Replace with your actual image path
              height: 200,
              width: 100,
            ),
            SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DefaultFormField(
                    hint: 'Employee ID',
                    controller: _employeeIdController,
                    validText: 'Please enter your Employee ID',
                  ),
                  SizedBox(height: 16.0),
                  DefaultFormField(
                    hint: 'Password',
                    controller: _passwordController,
                    isPassword: true,
                    validText: 'Please enter your password',
                  ),
                  SizedBox(height: 32.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Call the method to check login credentials
                        login();
                      }
                    },
                    child: Text('Login'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void login() async {
    try {
      // Assuming 'Employee' is the name of the collection in Firestore
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('Employee')
          .where('EmployeeID', isEqualTo: _employeeIdController.text)
          .where('Password', isEqualTo: _passwordController.text)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        // Login successful
        print('Login successful!');
        showSnackBar('Login successful!');
        // Replace the entire stack with the Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Dashboard()),
        );
      } else {
        // Invalid credentials
        print('Invalid credentials. Please try again.');
        showSnackBar('Invalid credentials. Please try again.');
        // You can display an error message here if needed
      }
    } catch (e) {
      print('Error during login: $e');
      showSnackBar('Error during login. Please try again.');
    }
  }
}
