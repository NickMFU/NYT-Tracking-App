import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namyong_demo/screen/DashBoard.dart';

class LoginPagee extends StatefulWidget {
  @override
  _LoginPageeState createState() => _LoginPageeState();
}

class _LoginPageeState extends State<LoginPagee> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signInWithEmailAndPassword() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Authentication successful, navigate to the dashboard or home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } catch (e) {
      // Show an error message if authentication fails
      print('Failed to sign in with email/password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with email/password. Please try again.'),
        ),
      );
    }
  }

  Future<void> _signInWithEmployeeIDAndPassword() async {
    try {
      // Add your logic to authenticate with EmployeeID and Password
      // For example:
      // final result = await authenticateWithEmployeeID(_employeeIDController.text.trim(), _passwordController.text.trim());

      // If authentication is successful
      // if (result) {
      //   Navigator.pushReplacement(
      //     context,
      //     MaterialPageRoute(builder: (context) => const Dashboard()),
      //   );
      // } else {
      //   // Show an error message if authentication fails
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to sign in with EmployeeID/password. Please try again.'),
      //     ),
      //   );
      // }
    } catch (e) {
      print('Failed to sign in with EmployeeID/password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign in with EmployeeID/password. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signInWithEmailAndPassword,
              child: Text('Sign In with Email/Password'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _signInWithEmployeeIDAndPassword,
              child: Text('Sign In with EmployeeID/Password'),
            ),
          ],
        ),
      ),
    );
  }
}
