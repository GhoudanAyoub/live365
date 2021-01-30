import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class SplashContent extends StatelessWidget {
  const SplashContent({
    Key key,
    this.text,
    this.image,
  }) : super(key: key);
  final String text, image;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Spacer(),
          Text(
            "Live365",
            style: TextStyle(
              fontSize: getProportionateScreenWidth(36),
              color: GTextColorWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          Image.asset(
            "assets/images/logo.png",
            height: getProportionateScreenHeight(265),
            width: getProportionateScreenWidth(235),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
