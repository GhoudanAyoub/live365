import 'package:flutter/material.dart';

import '../SizeConfig.dart';
import 'components/body.dart';

class SignUpScreen extends StatelessWidget {
  static String routeName = "/sign_up";
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      body: new WillPopScope(
        onWillPop: () async => true,
        child: Body(),
      ),
    );
  }
}
