import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:namyong_demo/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:namyong_demo/screen/Dashboard.dart';
import 'package:namyong_demo/screen/Splash.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
  final bool _isLoggedIn = false;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    _initializeFirebaseMessaging();
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for receiving notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // Get the device token
    String? token = await _firebaseMessaging.getToken();
    print('Firebase Messaging token: $token');

    // Handle incoming messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
    });
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