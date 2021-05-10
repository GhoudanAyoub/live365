import 'package:LIVE365/home/home_screen.dart';
import 'package:flutter/material.dart';

import '../components/splash_content.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {"text": "Perfect LIVE stream for all", "image": ""},
  ];

  @override
  void initState() {
    new Future.delayed(Duration(seconds: 3), () {
      Navigator.pushNamed(context, HomeScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Center(
          child: SplashContent(
            image: splashData[0]["image"],
            text: splashData[0]['text'],
          ),
        ),
      ),
    );
  }
}
