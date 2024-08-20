import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:namyong_demo/screen/Dashboard.dart';
import 'package:namyong_demo/screen/Splash.dart';
import 'package:namyong_demo/screen/login.dart';
import 'package:namyong_demo/service/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

Future<void> mainCommon() async {
 WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  
  await Firebase.initializeApp();
  runApp(MyApp());
}

Future<void> main() async {
  if (kIsWeb) {
    runApp(MyApp());
    await mainCommon();
  } else {
    await mainCommon();
    await initializeNotifications(); // Initialize notifications
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _firebaseInitialization = Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCAiZIj8-WOrtEoZCVYV8_mUC8zRf1oiPQ',
      appId: '1:461283669533:web:ebce8428d5f37fb763f8f4',
      messagingSenderId: '461283669533',
      projectId: 'namyongapp'),
  );

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
    return FutureBuilder(
      future: _firebaseInitialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Firebase initialization error: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'NYT-Tracking',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            debugShowCheckedModeBanner: false,
            home: SplashScreen(),
            routes: {
              '/login': (context) => LoginPage(),
              '/dashboard': (context) => const Dashboard(),
            },
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
