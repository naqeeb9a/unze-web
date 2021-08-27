import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(Duration(minutes: 1), 0, pushNotification);
  runApp(MyApp());
}

Future<void> pushNotification() async {
  var nDate = DateTime.now().toString().substring(0, 10);
  var nTime = DateTime.now().toString().substring(11, 16);
  var newNotification = [];
  var notificationData = await http
      .get(Uri.parse("https://attendanceapp.genxmtech.com/push/api.php?id=1"));
  var notificationDataBody = json.decode(notificationData.body);

  for (var u in notificationDataBody) {
    if (u["date"] == nDate && u["time"] == nTime) {
      newNotification.add(u);
    }
  }

  FlutterLocalNotificationsPlugin localNotification =
      FlutterLocalNotificationsPlugin();
  var androidInitialize =
      AndroidInitializationSettings("@drawable/ic_stat_logo");
  var initializeSetting = InitializationSettings(android: androidInitialize);
  localNotification.initialize(initializeSetting);
  var androidDetails = AndroidNotificationDetails(
      "1", "unze", "local notification",
      importance: Importance.high);
  var generalNotificationDetails = NotificationDetails(android: androidDetails);
  int i = 0;
  for (var u in newNotification) {
    await localNotification.show(
        i, u["title"], u["description"], generalNotificationDetails);
    i++;
  }
}

class MyApp extends StatelessWidget {
  final MaterialColor primaryColor = const MaterialColor(
    0xff5d443c,
    const <int, Color>{
      50: const Color(0xff5d443c),
      100: const Color(0xff5d443c),
      200: const Color(0xff5d443c),
      300: const Color(0xff5d443c),
      400: const Color(0xff5d443c),
      500: const Color(0xff5d443c),
      600: const Color(0xff5d443c),
      700: const Color(0xff5d443c),
      800: const Color(0xff5d443c),
      900: const Color(0xff5d443c),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unze Pakistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
      home: MainScreen(),
    );
  }
}
