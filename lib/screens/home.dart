import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled/screens/signIn.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:floating_bubbles/floating_bubbles.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  int temperature = 0;
  int humidity = 0;

  AnimationController? _animationController;
  Animation<Color?>? _colorAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _colorAnimation = _animationController!.drive(
      ColorTween(begin: Colors.red.shade200, end: Colors.blue.shade600),
    );

    _animationController!.repeat(reverse: true);

    _databaseReference.child('status').onValue.listen((event) {
      setState(() {
        if (event.snapshot.value != null) {
          Map<dynamic, dynamic>? dataMap =
              event.snapshot.value as Map<dynamic, dynamic>?;
          if (dataMap != null) {
            temperature = dataMap['temperature'] as int? ?? 0;
            humidity = dataMap['humidity'] as int? ?? 0;

            if (temperature > 23 || temperature < 18) {
              _firebaseMessaging.getToken().then((token) {
                _sendNotification(
                  token!,
                  'Temperature Alert',
                  'Temperature = ($temperature)',
                );
              });
            }

            if (humidity < 50 || humidity > 65) {
              _firebaseMessaging.getToken().then((token) {
                _sendNotification(
                  token!,
                  'Humidity Alert',
                  'Humidity = ($humidity)',
                );
              });
            }
          }
        }
      });
    });

    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((token) {
      print('FCM Token: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('FCM Message Received');
      // Show notification
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('FCM Message Opened');
      // Handle the opened message here if needed
    });

    // Initialize the FlutterLocalNotificationsPlugin instance
    _initializeNotifications();
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(''); // Replace with your app icon
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      '935278193696', // Replace with your channel ID
      'Weather Alerts', // Replace with your channel name
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      message.notification!.title, // Title of the notification
      message.notification!.body, // Body of the notification
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Color.fromARGB(255, 206, 78, 78),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirmation"),
                    content: Text("Are you sure you want to log out?"),
                    actions: <Widget>[
                      ElevatedButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                        ),
                      ),
                      ElevatedButton(
                        child: Text("Log Out"),
                        onPressed: () async {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('isLoggedIn', false);

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => signIn(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_colorAnimation!.value!, Colors.white],
                stops: [0.0, 0.7],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: temperature / 100,
                          backgroundColor: Color.fromARGB(255, 172, 172, 172),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          strokeWidth: 15,
                        ),
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.thermostat,
                            size: 40,
                            color: Colors.red,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Temperature',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$temperature°C',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 200,
                        height: 200,
                        child: CircularProgressIndicator(
                          value: humidity / 100,
                          backgroundColor: Color.fromARGB(255, 172, 172, 172),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                          strokeWidth: 15,
                        ),
                      ),
                      Column(
                        children: [
                          Icon(
                            Icons.water_drop,
                            size: 40,
                            color: Colors.blue,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Humidity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$humidity%',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: FloatingBubbles(
              noOfBubbles: 25,
              colorsOfBubbles: [
                Colors.cyan.withAlpha(30),
                Colors.red,
              ],
              sizeFactor: 0.4,
              duration: 1020, // 1020 seconds.
              opacity: 15,
              paintingStyle: PaintingStyle.fill,
              strokeWidth: 4,
              shape: BubbleShape.roundedRectangle,
              speed: BubbleSpeed.slow,
            ),
          ),
        ],
      ),
    );
  }

  void _sendNotification(String token, String title, String body) {
    final serverKey =
        'AAAA2cLsrCA:APA91bFCOz8mqUJ_lxWVjffnRJ8kegP9xtMC6kFD1AafKV7vla-pKUNJrcKdjvSgwbkFDS7TIKSQiACZxIzMN62mQCWLXvhuG0kMI58cqkVPYnRYpH7Xjxi1bxCmkwItd-d_czzOU5np';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final requestBody = {
      'to': token,
      'notification': {
        'title': title,
        'body': body,
      },
      'priority': 'high',
      'data': {
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'screen': 'home',
      },
      'topic':
          'notifications', // Send the notification to a specific topic (optional)
    };

    http
        .post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: jsonEncode(requestBody),
    )
        .then((response) {
      print('Notification sent');
    }).catchError((error) {
      print('Error sending notification: $error');
    });
  }
}
