import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();

  late bool netConnection;

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
    Timer.periodic(
      Duration(milliseconds: 10),
      (Timer t) => checkLink(),
    );
    webView();

    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  checkLink() async {
    WebViewController webViewController = await _controller.future;
    var currentUrl = await webViewController.currentUrl();

    currentUrl = currentUrl.toString().replaceAll("%20", "");
    if (currentUrl.toString().contains("tel:042111118693")) {
      launch("tel://03353961635");
      bool canNavigate = await webViewController.canGoBack();
      if (canNavigate) {
        webViewController.goBack();
      }
    } else if (currentUrl
        .toString()
        .contains("mailto:customersupport@unze.com.pk")) {
      launch("mailto:customersupport@unze.com.pk");
      bool canNavigate = await webViewController.canGoBack();
      if (canNavigate) {
        webViewController.goBack();
      }
    } else if (currentUrl.toString().contains("api.whatsapp.com/send")) {
      String urlWW = "whatsapp://send?phone=+923458963222&text=Hi";
      launch(urlWW);
      if (await canLaunch(urlWW)) {
        launch(urlWW);
        bool canNavigate = await webViewController.canGoBack();
        if (canNavigate) {
          webViewController.goBack();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    void _willPopCallback() async {
      WebViewController webViewController = await _controller.future;
      bool canNavigate = await webViewController.canGoBack();
      if (canNavigate) {
        webViewController.goBack();
      }
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: netConnection == true
            ? IndexedStack(
                index: position,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 1,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 1,
                              height: MediaQuery.of(context).size.height * .897,
                              child: WebView(
                                initialUrl: 'https://unze.com.pk/',
                                javascriptMode: JavascriptMode.unrestricted,
                                onWebViewCreated:
                                    (WebViewController webViewController) {
                                  _controller.complete(webViewController);
                                },
                                onPageStarted: (value) {
                                  setState(() {
                                    position = 1;
                                    Future.delayed(Duration(seconds: 1), () {
                                      setState(() {
                                        position = 0;
                                      });
                                    });
                                  });
                                },
                                onPageFinished: (value) {
                                  setState(() {
                                    position = 0;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: _willPopCallback,
                          child: Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 1,
                                height:
                                    MediaQuery.of(context).size.height * .06,
                                color: Color(0xff5d443c),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Go Back",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
            : Container(
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
                          onTap: webView,
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
                                  fontSize:
                                      MediaQuery.of(context).size.width * .06,
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
              ),
      ),
    );
  }
}
