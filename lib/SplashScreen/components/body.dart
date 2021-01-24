import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:live365/SignIn/sign_in_screen.dart';
import 'package:live365/firebaseService/FirebaseService.dart';
import 'package:live365/home/home_screen.dart';

import '../../constants.dart';
import '../components/splash_content.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {"text": "Welcome to Live 365. ", "image": ""},
  ];

  @override
  void initState() {
    new Future.delayed(Duration(seconds: 3), () {
      if (FirebaseAuth.instance.currentUser == null) {
        FirebaseService.SetFirebaseUser(FirebaseAuth.instance.currentUser);
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

  AnimatedContainer buildDot({int index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
