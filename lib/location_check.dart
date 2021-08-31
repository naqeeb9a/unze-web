import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unze_web_clone_app/main_screen.dart';

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
    final coordinates = new Coordinates(position.latitude, position.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    var pref = await SharedPreferences.getInstance();
    if (pref.getString("countryName") == null) {
      if (first.countryName.toString() == "Pakistan") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://unze.com.pk/',
            ),
          ),
        );
      } else if (first.countryName.toString() == "United States") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://www.unze.us/',
            ),
          ),
        );
      } else if (first.countryName.toString() == "United Kingdom") {
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://unze.com.pk/',
            ),
          ),
        );
      } else if (pref.getString("countryName").toString() == "United States") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://www.unze.us/',
            ),
          ),
        );
      } else if (pref.getString("countryName").toString() == "United Kingdom") {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainScreen(
              url: 'https://www.unze.co.uk/',
            ),
          ),
        );
      }
    }
    return first.countryName;
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
