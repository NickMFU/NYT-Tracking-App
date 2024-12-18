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

// Global key to manage Snackbar notifications globally
final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Function to initialize the app's common services
Future<void> mainCommon() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that widget binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  await fetchAccessToken(); // Fetch access token from external service
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler); // Set up background message handling for Firebase Cloud Messaging (FCM)
  AlarmNotificationService.init(); // Initialize the alarm notification service
  NotificationService().initialize(); // Initialize the notification service
}

// Entry point for the app
Future<void> main() async {
  if (kIsWeb) {
    runApp(MyApp()); // If the app is running on the web, start the app immediately
    await mainCommon(); // Initialize the common services after the app starts
  } else {
    await mainCommon(); // For mobile, initialize common services first
    runApp(MyApp()); // Then start the app
  }
}

// Function to fetch an access token from an external service
Future<void> fetchAccessToken() async {
  final serviceKey = ServiceKey(); // Create an instance of the service key class
  try {
    final accessToken = await serviceKey.getKeyService(); // Get access token from the service
    print('Access Token: $accessToken'); // Print the access token to the console
  } catch (e) {
    print('Error fetching access token: $e'); // Print an error message if fetching fails
  }
}

// Background message handler for Firebase Cloud Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}'); // Log the message ID for background notifications
}

// The main app widget
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState(); // Create the state for the app
}

class _MyAppState extends State<MyApp> {
  // Initialize Firebase for the app using specific project credentials
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
      future: _firebaseInitialization, // Wait for Firebase initialization
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Firebase initialization error: ${snapshot.error}'), // Show an error message if Firebase fails to initialize
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          // If Firebase has initialized successfully, build the MaterialApp
          return MaterialApp(
            title: 'NYT-Tracking', // Set the app title
            theme: ThemeData(
              primarySwatch: Colors.blue, // Set the primary theme color
              visualDensity: VisualDensity.adaptivePlatformDensity, // Adjust density for different platforms
            ),
            debugShowCheckedModeBanner: false, // Disable the debug banner
            home: SplashScreen(), // Set the splash screen as the home page
            scaffoldMessengerKey: _scaffoldMessengerKey, // Attach the global scaffold messenger key
            routes: {
              '/login': (context) => LoginPage(), // Define the route for the login page
              '/dashboard': (context) => const Dashboard(), // Define the route for the dashboard
            },
          );
        }
        return const Center(child: CircularProgressIndicator()); // Show a loading indicator while Firebase is initializing
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Fetch the FCM (Firebase Cloud Messaging) token for the device
    FirebaseMessaging.instance.getToken().then((token) {
      print("FCM Token: $token"); // Print the FCM token to the console
      // Optionally, save the token to the server or Firestore
    });

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received in foreground: ${message.notification?.body}'); // Print the message body
    });

    // Handle the case where a notification is clicked and the app is opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification clicked!'); // Log when a notification is clicked
      // Optionally, navigate to a specific screen based on the notification
    });
  }
}
