import 'package:LIVE365/SignIn/sign_in_screen.dart';
import 'package:LIVE365/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/splash_content.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {"text": "Welcome to Live365. ", "image": ""},
  ];

  @override
  void initState() {
    new Future.delayed(Duration(seconds: 3), () {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushNamed(context, SignInScreen.routeName);
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
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
