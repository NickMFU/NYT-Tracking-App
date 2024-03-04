import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namyong_demo/screen/Dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _idOrEmailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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
              const SizedBox(height: 16.0),
              // Image Widget here
              const SizedBox(height: 16.0),
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
                    ElevatedButton(
                      onPressed: _login,
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
            MaterialPageRoute(builder: (context) => Dashboard()),
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
