import 'package:flutter/material.dart';

import 'components/body.dart';

class SignInScreen extends StatelessWidget {
  static String routeName = "/sign_in";
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
