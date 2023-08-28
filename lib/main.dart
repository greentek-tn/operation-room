import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/signIn.dart';
import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Handle the loading state if needed
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Handle any errors that occurred during SharedPreferences initialization
          return Text('Error: ${snapshot.error}');
        } else {
          // Read the authentication state from SharedPreferences
          bool isLoggedIn = snapshot.data?.getBool('isLoggedIn') ?? false;

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: isLoggedIn ? Home() : signIn(),
          );
        }
      },
    );
  }
}

// Background message handler for handling FCM notifications when the app is in the background or terminated
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('FCM message received in background: ${message.notification?.title}');
}
