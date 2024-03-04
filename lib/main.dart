import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:namyong_demo/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namyong_demo/screen/Dashboard.dart';
import 'package:namyong_demo/screen/Splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
   SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setBool('isLoggedIn', true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? const Dashboard() : SplashScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/dashboard': (context) => const Dashboard(),
      },
    );
  }
}