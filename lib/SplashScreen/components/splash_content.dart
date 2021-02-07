import 'package:flutter/material.dart';

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
          Image.asset(
            "assets/images/logo.png",
            height: 200,
            width: 200,
          ),
          Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'SFProDisplay-Medium'),
          ),
          Spacer(),
          Spacer(),
        ],
      ),
    );
  }
}
