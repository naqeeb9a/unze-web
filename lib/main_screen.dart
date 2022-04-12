import 'dart:async';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'location_check.dart';

class MainScreen extends StatefulWidget {
  final String url;

  const MainScreen({Key? key, required this.url}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController _myController;

  bool netConnection = true;

  int position = 1;

  Future<dynamic> webView() async {
    netConnection = false;
    try {
      final net = await InternetAddress.lookup('example.com');
      if (net.isNotEmpty && net[0].rawAddress.isNotEmpty) {
        setState(() {
          netConnection = true;
        });
      }
    } on SocketException catch (_) {
      setState(() {
        netConnection = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.instance.getToken().then((value) {
      print("token $value");
    });

    webView();
    if (Platform.isAndroid) {
      Timer.periodic(
        const Duration(milliseconds: 150),
        (Timer t) => checkLink(),
      );
    } else if (Platform.isIOS) {}

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  checkLink() async {
    try {
      WebViewController webViewController = await _controller.future;
      var currentUrl = await webViewController.currentUrl();

      currentUrl = currentUrl.toString().replaceAll("%20", "");
      if (currentUrl == "tel:042111118693") {
        launch("tel:042111118693");
        bool canNavigate = await webViewController.canGoBack();
        if (canNavigate) {
          webViewController.goBack();
        }
        setState(() {
          position = 0;
        });
      } else if (currentUrl
          .toString()
          .contains("mailto:customersupport@unze.com.pk")) {
        launch("mailto:customersupport@unze.com.pk");
        bool canNavigate = await webViewController.canGoBack();
        if (canNavigate) {
          webViewController.goBack();
        }
        setState(() {
          position = 0;
        });
      } else if (currentUrl ==
          "https://api.whatsapp.com/send/?phone=923458963222&text&app_absent=0") {
        String urlWW = "whatsapp://send?phone=+923458963222&text=Hi";
        if (await canLaunch(urlWW)) {
          launch(urlWW);
          bool canNavigate = await webViewController.canGoBack();
          if (canNavigate) {
            webViewController.goBack();
          }
          setState(() {
            position = 0;
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: netConnection == true
            ? IndexedStack(
                index: position,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 1,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        WebView(
                          initialUrl: widget.url,
                          javascriptMode: JavascriptMode.unrestricted,
                          onWebViewCreated:
                              (WebViewController webViewController) {
                            if (!_controller.isCompleted) {
                              _controller.complete(webViewController);
                            } else {}
                            _myController = webViewController;
                          },
                          onWebResourceError: (WebResourceError webError) {
                            if (Platform.isAndroid) {
                              if (webError.failingUrl == "tel:042111118693" ||
                                  webError.failingUrl ==
                                      "tel:042%20111%2011%208693" ||
                                  webError.failingUrl ==
                                      "mailto:customersupport@unze.com.pk") {
                                setState(() {
                                  position = 1;
                                });
                              } else {
                                setState(() {
                                  netConnection = false;
                                });
                              }
                            } else if (Platform.isIOS) {}
                          },
                          onPageStarted: (initialUrl) {
                            if (Platform.isIOS) {
                              setState(() {
                                position = 1;
                                Future.delayed(
                                    const Duration(milliseconds: 2000), () {
                                  setState(() {
                                    position = 0;
                                  });
                                  _myController.runJavascript(
                                      "\$('.native-app-banner').css('display', 'none');");
                                });
                              });

                              initialUrl =
                                  initialUrl.toString().replaceAll("%20", "");
                              if (initialUrl == "tel:042111118693") {
                                launch("tel://042111118693");
                              } else if (initialUrl.toString().contains(
                                  "mailto:customersupport@unze.com.pk")) {
                                launch("mailto:customersupport@unze.com.pk");
                              }
                            } else if (Platform.isAndroid) {
                              try {
                                setState(() {
                                  position = 1;
                                  for (int i = 1; i <= 10; i++) {
                                    Future.delayed(Duration(seconds: i), () {
                                      setState(() {
                                        if (i > 4) {
                                          position = 0;
                                        }
                                        _myController.runJavascript(
                                            "document.getElementsByClassName('native-app-banner')[0].style.display='none';");
                                      });
                                    });
                                  }
                                });
                              } catch (e) {
                                debugPrint(e.toString());
                              }
                            }
                          },
                          onPageFinished: (initialUrl) {
                            try {
                              setState(() {
                                position = 0;
                              });
                              _myController.runJavascript(
                                  "\$('.native-app-banner').css('display', 'none');");
                            } catch (e) {
                              debugPrint(e.toString());
                            }
                          },
                        ),
                        Positioned(
                          left: 0,
                          child: GestureDetector(
                            onPanUpdate: (details) async {
                              if (details.delta.dx > 0) {
                                WebViewController webViewController =
                                    await _controller.future;
                                var currentUrl =
                                    await webViewController.currentUrl();
                                if (currentUrl == "https://unze.com.pk/") {
                                } else {
                                  await webViewController.goBack();
                                }
                              }
                            },
                            child: Container(
                              color: Colors.transparent,
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width * 0.028,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xff5d443c),
                    ),
                  ),
                ],
              )
            : pageError(
                context,
                webView,
              ),
      ),
    );
  }
}

Widget pageError(context, webView) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 1,
    height: MediaQuery.of(context).size.height * 1,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              color: const Color(0xff5d443c),
              size: MediaQuery.of(context).size.width * .2,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Internet Connection!!",
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * .07,
                color: const Color(0xff5d443c),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LocationCheck()),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * .4,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: const Color(0xff5d443c),
                  borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width * .02,
                  ),
                ),
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * .02,
                ),
                child: Center(
                  child: Text(
                    "Reload!",
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * .06,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
