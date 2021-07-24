import 'package:flutter/material.dart';

import '../SizeConfig.dart';
import 'components/body.dart';

class SplashScreen extends StatelessWidget {
  static String routeName = "/splash";
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: new WillPopScope(
        onWillPop: () async => false,
        child: Body(),
      ),
    );
  }
}
