import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:namyong_demo/screen/Dashboard.dart';
import 'package:namyong_demo/screen/Splash.dart';
import 'package:namyong_demo/screen/login.dart';
import 'package:namyong_demo/service/firebase_api.dart';
import 'package:namyong_demo/service/getaccesstoken.dart';
import 'package:namyong_demo/service/notification_service.dart';


Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await fetchAccessToken();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AlarmNotificationService.init();
  LNotificationService().initialize();
}


Future<void> main() async {
  if (kIsWeb) {
    runApp(MyApp());
    await mainCommon();
  } else {
    await mainCommon();
    runApp(MyApp());
  }
}

Future<void> fetchAccessToken() async {
  final serviceKey = ServiceKey();
  try {
    final accessToken = await serviceKey.getKeyService();
    print('Access Token: $accessToken'); // Print the access token
  } catch (e) {
    print('Error fetching access token: $e');
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
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
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token");
      // Save the token to your server or Firestore as per your requirement
    });

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.body}');
      // Show local notification or update the UI accordingly
    });

    // Handle messages when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!');
      // Navigate to the relevant screen if required
    });
}}