import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'location_check.dart';

import 'dart:io' show Platform;

Future<void> _firebaseMessagingForegroundHandler(RemoteMessage message) async {
  if (message.notification != null) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.notification.hashCode,
        channelKey: "key1",
        title: message.notification!.title,
        body: message.notification!.body,
        bigPicture: message.notification!.android?.imageUrl,
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
    AwesomeNotifications().createNotificationFromJsonData(message.data);
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: message.notification.hashCode,
      channelKey: "key1",
      title: message.notification!.title,
      body: message.notification!.body,
      bigPicture: Platform.isAndroid
          ? message.notification!.android?.imageUrl
          : Platform.isIOS
              ? message.notification!.apple?.imageUrl
              : message.notification!.web?.image,
      notificationLayout: NotificationLayout.BigPicture,
    ),
  );

  AwesomeNotifications().createNotificationFromJsonData(message.data);
}

void main() async {
  const MaterialColor primaryColor = MaterialColor(
    0xff5d443c,
    <int, Color>{
      50: Color(0xff5d443c),
      100: Color(0xff5d443c),
      200: Color(0xff5d443c),
      300: Color(0xff5d443c),
      400: Color(0xff5d443c),
      500: Color(0xff5d443c),
      600: Color(0xff5d443c),
      700: Color(0xff5d443c),
      800: Color(0xff5d443c),
      900: Color(0xff5d443c),
    },
  );

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
    if (!isAllowed) {
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  AwesomeNotifications().initialize('resource://drawable/ic_stat_logo', [
    NotificationChannel(
      channelKey: "key1",
      channelName: "Unze",
      channelDescription: "Unze London Notification",
      playSound: true,
      channelShowBadge: true,
      enableVibration: true,
      importance: NotificationImportance.High,
    )
  ]);

  void _handleMessage(RemoteMessage message) {
    print("open app");

    runApp(
      MaterialApp(
        title: 'Unze',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: primaryColor,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        home: const LocationCheck(),
      ),
    );
  }

  FirebaseMessaging.onMessage.listen(_firebaseMessagingForegroundHandler);
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    MaterialApp(
      title: 'Unze',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryColor,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LocationCheck(),
    ),
  );
}
