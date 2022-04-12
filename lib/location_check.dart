import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class LocationCheck extends StatefulWidget {
  const LocationCheck({Key? key}) : super(key: key);

  @override
  _LocationCheckState createState() => _LocationCheckState();
}

class _LocationCheckState extends State<LocationCheck> {
  dynamic name = "";
  late bool serviceEnabled;
  late LocationPermission permission;

  saveCountry(String country) async {
    SharedPreferences countryName = await SharedPreferences.getInstance();
    countryName.setString("countryName", country);
  }

  getCountryName() async {
    bool serviceEnabled;
    LocationPermission permission;

    var pref = await SharedPreferences.getInstance();
    if (pref.getString("countryName") == null) {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          name = "none";
        });
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            name = "none";
          });
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          name = "none";
        });

        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placeMarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placeMarks[0].country.toString() == "Pakistan") {
        saveCountry("Pakistan");
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MainScreen(
              url: 'https://unze.com.pk/',
            ),
          ),
        );
      } else if (placeMarks[0].country.toString() == "United States") {
        saveCountry("United States");
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MainScreen(
              url: 'https://www.unze.us/',
            ),
          ),
        );
      } else if (placeMarks[0].country.toString() == "United Kingdom") {
        saveCountry("United Kingdom");
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MainScreen(
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
            builder: (context) => const MainScreen(
              url: 'https://unze.com.pk/',
            ),
          ),
        );
      } else if (pref.getString("countryName").toString() == "United States") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MainScreen(
              url: 'https://www.unze.us/',
            ),
          ),
        );
      } else if (pref.getString("countryName").toString() == "United Kingdom") {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MainScreen(
              url: 'https://www.unze.co.uk/',
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getCountryName();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(message.notification!.title.toString()),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message.notification!.body.toString()),
                  ],
                ),
              ),
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: name != "none"
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * .03,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Preparing App according to your location.",
                          style: TextStyle(
                            color: const Color(0xff5d443c),
                            fontSize: MediaQuery.of(context).size.width * .04,
                          ),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
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
                            color: const Color(0xff5d443c),
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
                            getCountryName();
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
                            getCountryName();
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
                            getCountryName();
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
      SizedBox(
        width: MediaQuery.of(context).size.width * .6,
        height: MediaQuery.of(context).size.height * .08,
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * .06,
              fontWeight: FontWeight.bold,
              shadows: const <Shadow>[
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
