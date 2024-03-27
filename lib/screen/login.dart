import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:namyong_demo/Component/form_field.dart';
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
  bool _isPasswordVisible = false;

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
      backgroundColor: const Color.fromARGB(255, 239, 247, 255),
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
                  color: Color.fromARGB(255, 4, 6, 126),
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 6, 126),
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFedf0f8),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Color.fromARGB(255, 4, 6, 126),
                                width: 2),
                          ),
                          child: TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter E-mail';
                              }
                              return null;
                            },
                            controller: _idOrEmailController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Color(0xFFb2b7bf),
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password', // Text above the container
                          style: TextStyle(
                            color: Color.fromARGB(255, 4, 6, 126), // Text color
                            fontSize: 18.0, // Text size
                            fontWeight: FontWeight.bold, // Text weight
                          ),
                        ),
                        const SizedBox(
                            height: 10), // Spacer between text and container
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 2.0, horizontal: 30.0),
                          decoration: BoxDecoration(
                            color: Color(0xFFedf0f8),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Color.fromARGB(255, 4, 6, 126),
                              width: 2,
                            ), // Blue border
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: TextStyle(
                                  color: Color(0xFFb2b7bf), fontSize: 18.0),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Color.fromARGB(255, 4, 6, 126),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            obscureText:
                                !_isPasswordVisible, // Toggle password visibility
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.6, // Adjust the width as needed
                      child: ElevatedButton(
                        onPressed: _login,
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
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
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
