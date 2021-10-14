import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unze_web_clone_app/main_screen.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
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
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(notify, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "2",
    "simplePeriodicTask",
    frequency: Duration(minutes: 15),
  );
  notify();
  runApp(
    MaterialApp(
      title: 'Unze Pakistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryColor,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: LocationCheck(),
    ),
  );
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
  var newNotification = [];
  var nImages = [];
  var notificationData = await http.get(Uri.parse(
      "https://shopify.unze.com.pk/api/api.php?getPUSHNotifications"));
  var notificationDataBody = json.decode(notificationData.body);

  for (var u in notificationDataBody) {
    var format = DateFormat("HH:mm");
    var one = format.parse(nTime);
    var two = format.parse(u["time"]);
    var pTime = one.difference(two);
    if (pTime.toString().substring(2, 4).contains(":") ||
        pTime.toString().substring(0, 1) != "0") {
    } else {
      if (u["date"] == nDate &&
          pTime.toString().substring(0, 1) == "0" &&
          !pTime.isNegative &&
          int.parse(pTime.toString().substring(2, 4)) < 15) {
        newNotification.add(u);
        if (u["image"] != "") {
          nImages.add(u["image"]);
        }
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
            notificationLayout: NotificationLayout.BigPicture),
      );
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

class LocationCheck extends StatefulWidget {
  const LocationCheck({Key? key}) : super(key: key);

  @override
  _LocationCheckState createState() => _LocationCheckState();
}

class _LocationCheckState extends State<LocationCheck> {
  saveCountry(String country) async {
    SharedPreferences countryName = await SharedPreferences.getInstance();
    countryName.setString("countryName", country);
  }

  dynamic name = "";

  getCountryName() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placeMarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    var pref = await SharedPreferences.getInstance();
    if (pref.getString("countryName") == null) {
      if (placeMarks[0].country.toString() == "Pakistan") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://unze.com.pk/',
            ),
          ),
        );
      } else if (placeMarks[0].country.toString() == "United States") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://www.unze.us/',
            ),
          ),
        );
      } else if (placeMarks[0].country.toString() == "United Kingdom") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://www.unze.co.uk/',
            ),
          ),
        );
      } else {
        setState(() {
          name = "none";
        });
      }
    } else {
      if (pref.getString("countryName").toString() == "Pakistan") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://unze.com.pk/',
            ),
          ),
        );
      } else if (pref.getString("countryName").toString() == "United States") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://www.unze.us/',
            ),
          ),
        );
      } else if (pref.getString("countryName").toString() == "United Kingdom") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://www.unze.co.uk/',
            ),
          ),
        );
      }
    }
    return placeMarks[0].country.toString();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCountryName();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: name != "none"
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .08,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Select Country",
                          style: TextStyle(
                            color: Color(0xff5d443c),
                            fontSize: MediaQuery.of(context).size.width * .08,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            saveCountry("Pakistan");
                          },
                          child: flagButton(
                            context,
                            "Pakistan",
                            "assets/pkr.jpg",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            saveCountry("United Kingdom");
                          },
                          child: flagButton(
                            context,
                            "United Kingdom",
                            "assets/uk.jpg",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            saveCountry("United States");
                          },
                          child: flagButton(
                            context,
                            "United States",
                            "assets/us.jpg",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Widget flagButton(BuildContext context, String title, image) {
  return Stack(
    children: [
      Container(
        width: MediaQuery.of(context).size.width * .6,
        height: MediaQuery.of(context).size.height * .08,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.black.withOpacity(.4),
          ),
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * .6,
        height: MediaQuery.of(context).size.height * .08,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * .06,
              fontWeight: FontWeight.bold,
              shadows: <Shadow>[
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 6.0,
                  color: Colors.black,
                ),
              ],
            ),
            maxLines: 1,
          ),
        ),
      ),
    ],
  );
}
