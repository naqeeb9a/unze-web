import 'dart:convert';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unze_web_clone_app/location_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidAlarmManager.initialize();
  await AndroidAlarmManager.periodic(Duration(minutes: 1), 0, notify);
  runApp(MyApp());
}

notify() async {
  AwesomeNotifications().initialize('resource://drawable/ic_stat_logo', [
    NotificationChannel(
      channelKey: "key1",
      channelName: "proton coders point",
      channelDescription: "notification example",
      enableLights: true,
      enableVibration: true,
      importance: NotificationImportance.High,
    )
  ]);
  var nDate = DateTime.now().toString().substring(0, 10);
  var nTime = DateTime.now().toString().substring(11, 16);
  print(nDate);
  print(nTime);
  var newNotification = [];
  var nImages = [];
  var notificationData = await http
      .get(Uri.parse("https://attendanceapp.genxmtech.com/push/api.php?id=1"));
  var notificationDataBody = json.decode(notificationData.body);
  for (var u in notificationDataBody) {
    if (u["date"] == nDate && u["time"] == nTime) {
      newNotification.add(u);
      if (u["image"] != "") {
        nImages.add(u["image"]);
      }
    }
  }
  int y = 0;
  int i = 0;
  for (var u in newNotification) {
    if (u["image"] != "") {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: i,
              channelKey: "key1",
              title: u["title"],
              body: u["description"],
              bigPicture: nImages[y],
              notificationLayout: NotificationLayout.BigPicture));
      i++;
      y++;
    } else {
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
        id: i,
        channelKey: "key1",
        title: u["title"],
        body: u["description"],
      ));
      i++;
    }
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
      home: LocationCheck(),
    );
  }
}
