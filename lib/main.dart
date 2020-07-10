import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MikoButton',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.black,
      ),
      home: MyHomePage(title: 'MikoButton'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  String title;
  WebViewController controller;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  DateTime lastPopTime = DateTime.now();
  WebViewController _controller;
  Future<bool> _exitApp(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      if (lastPopTime == null ||
          DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
        lastPopTime = DateTime.now();
        _showToast();
      } else {
        lastPopTime = DateTime.now();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    }
  }

  String webtitle = '';
  String weburl = '';
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldkey,
        body: Builder(
          builder: (BuildContext context) {
            return WebView(
              initialUrl: 'https://sakuramiko.org',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (url) {
                _controller.evaluateJavascript("document.title").then((result) {
                  webtitle = result;
                });
                _controller
                    .evaluateJavascript("window.location.href")
                    .then((result) {
                  weburl = result;
                });
              },
              onWebViewCreated: (WebViewController con) {
                _controller = con;
                _controller.canGoBack();
              },
            );
          },
        ),
      ),
    );
  }

  FlutterToast flutterToast;

  @override
  void initState() {
    super.initState();
    flutterToast = FlutterToast(context);
  }

  _showToast() {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 25.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.black54,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '再按一次退出',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );

    flutterToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 2),
    );
  }
}
