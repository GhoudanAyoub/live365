import 'package:flutter/material.dart';

import 'components/body.dart';

class SignInScreen extends StatefulWidget {
  static String routeName = "/sign_in";
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new WillPopScope(
        onWillPop: () async => true,
        child: Body(),
      ),
    );
  }
}
