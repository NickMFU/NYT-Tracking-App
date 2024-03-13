import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namyong_demo/screen/Dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _idOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  void _checkLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idOrEmail = prefs.getString('idOrEmail');
    String? password = prefs.getString('password');

    if (idOrEmail != null && password != null) {
      // Auto-login if credentials exist
      _idOrEmailController.text = idOrEmail;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 239, 247, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50.0),
              const Text(
                'NYT-Tracking',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                  fontFamily: 'Righteous',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              Image.asset(
              'assets/images/login.jpg', // Replace with your actual image path
              height: 200,
              width: 100,
            ),
              const SizedBox(height: 30.0),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _idOrEmailController,
                      decoration: InputDecoration(labelText: 'EmployeeID or Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your EmployeeID or Email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32.0),
                   Container(
            width: MediaQuery.of(context).size.width *
                0.6, // Adjust the width as needed
            child: ElevatedButton(
              onPressed: _login,
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
                    "LOGIN",
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ]),
              ),
            ),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        String idOrEmail = _idOrEmailController.text.trim();
        String password = _passwordController.text.trim();

        // Check if the input is an email
        if (idOrEmail.contains('@')) {
          // Email login
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: idOrEmail,
            password: password,
          );

          // Login successful
          _showSnackBar('Login successful!');

          // Save user credentials using SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('idOrEmail', idOrEmail);
          prefs.setString('password', password);

          // Navigate to the Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } else {
          // EmployeeID login
          QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
              .collection('Employee')
              .where('EmployeeID', isEqualTo: idOrEmail)
              .where('Password', isEqualTo: password)
              .get();

          if (employeeSnapshot.docs.isEmpty) {
            throw 'Invalid credentials';
          }

          // Login successful
          _showSnackBar('Login successful!');

          // Save user credentials using SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('idOrEmail', idOrEmail);
          prefs.setString('password', password);

          // Navigate to the Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        }
      } catch (e) {
        print('Error during login: $e');
        _showSnackBar('Error during login. Please try again.');
      }
    }
  }
}
