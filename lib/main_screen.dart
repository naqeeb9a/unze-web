import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'main.dart';

class MainScreen extends StatefulWidget {
  final String url;

  MainScreen({required this.url});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  late WebViewController _myController;

  bool netConnection = true;

  int position = 1;

  Future<dynamic> webView() async {
    print(_controller);
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
    // TODO: implement initState
    super.initState();

    webView();
    Timer.periodic(
      Duration(milliseconds: 120),
      (Timer t) => checkLink(),
    );

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  checkLink() async {
    try {
      WebViewController webViewController = await _controller.future;
      var currentUrl = await webViewController.currentUrl();

      currentUrl = currentUrl.toString().replaceAll("%20", "");
      if (currentUrl.toString().contains("tel:042111118693")) {
        launch("tel://03353961635");
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
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        WebViewController webViewController = await _controller.future;
        var currentUrl = await webViewController.currentUrl();
        if (currentUrl == "https://unze.com.pk/") {
          return true;
        } else {
          await webViewController.goBack();
          return false;
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: netConnection == true
              ? IndexedStack(
                  index: position,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      height: double.infinity,
                      child: WebView(
                        initialUrl: widget.url,
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated:
                            (WebViewController webViewController) {
                          _controller.complete(webViewController);
                          _myController = webViewController;
                        },
                        onWebResourceError: (WebResourceError webError) {
                          print(
                              "faileeeeeddd==========-=-==================-----");
                          print(webError.failingUrl);
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
                        },
                        onPageStarted: (initialUrl) {
                          try {
                            setState(() {
                              position = 1;
                              for (int i = 1; i <= 10; i++) {
                                Future.delayed(Duration(seconds: i), () {
                                  setState(() {
                                    if (i > 4) {
                                      position = 0;
                                    }
                                    _myController.evaluateJavascript(
                                        "document.getElementsByClassName('unze-app-top')[0].style.display='none';");
                                    _myController.evaluateJavascript(
                                        "document.getElementsByClassName('h_banner bgp pt10 pb10 fs_14 flex fl_center al_center pr oh show_icon_false')[0].style.display='none';");
                                    // expression = _myController.evaluateJavascript(
                                    //     "document.getElementsByClassName('type_toolbar_link type_toolbar_a8d307c8-602b-4638-b500-aed1268cebf9 kalles_toolbar_item')[0].style.display='none';");
                                  });
                                });
                              }
                            });
                          } catch (e) {}
                        },
                        onPageFinished: (initialUrl) {
                          try {
                            _myController.evaluateJavascript(
                                "document.getElementsByClassName('unze-app-top')[0].style.display='none';");
                            setState(() {
                              position = 0;
                            });
                          } catch (e) {}
                        },
                      ),
                    ),
                    Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff5d443c),
                        ),
                      ),
                    ),
                  ],
                )
              : pageError(
                  context,
                  webView,
                ),
        ),
      ),
    );
  }
}

Widget pageError(context, webView) {
  return Container(
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
              color: Color(0xff5d443c),
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
                color: Color(0xff5d443c),
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
                  MaterialPageRoute(builder: (context) => LocationCheck()),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width * .4,
                height: MediaQuery.of(context).size.height * .07,
                decoration: BoxDecoration(
                  color: Color(0xff5d443c),
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
