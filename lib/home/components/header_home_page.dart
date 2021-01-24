import 'package:flutter/material.dart';

import '../../constants.dart';

class HeaderHomePage extends StatelessWidget {
  const HeaderHomePage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "LIVE",
          style: TextStyle(
              color: white, fontSize: 17, fontWeight: FontWeight.w500),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          ".",
          style: TextStyle(
            color: orange,
            fontSize: 17,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "RECOMMENDED",
          style: TextStyle(
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
            color: orange,
            fontSize: 17,
          ),
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          "FOLLOW",
          style: TextStyle(
            color: white.withOpacity(0.7),
            fontSize: 16,
          ),
        )
      ],
    );
  }
}
