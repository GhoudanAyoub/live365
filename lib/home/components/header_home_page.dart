import 'package:flutter/material.dart';

import '../../constants.dart';

class HeaderHomePage extends StatelessWidget {
  const HeaderHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "LIVE",
          style: TextStyle(
              fontFamily: "SFProDisplay-Regular",
              color: white,
              fontSize: 17,
              fontWeight: FontWeight.w500),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          ".",
          style: TextStyle(
            fontFamily: "SFProDisplay-Bold",
            color: orange,
            fontSize: 28,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "RECOMMENDED",
          style: TextStyle(
            fontFamily: "SFProDisplay-Regular",
            color: white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          ".",
          style: TextStyle(
            fontFamily: "SFProDisplay-Bold",
            color: orange,
            fontSize: 28,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "FOLLOW",
          style: TextStyle(
            fontFamily: "SFProDisplay-Regular",
            color: white.withOpacity(0.7),
            fontSize: 16,
          ),
        )
      ],
    ));
  }
}
