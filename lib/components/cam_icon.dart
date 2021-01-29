import 'package:flutter/material.dart';

import '../constants.dart';

class CamIcon extends StatelessWidget {
  const CamIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 15, 10, 10),
      width: 50,
      height: 35,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            child: Container(
              width: 40,
              height: 35,
              decoration: BoxDecoration(
                  color: orange, borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 40,
              height: 35,
              decoration: BoxDecoration(
                  color: orange, borderRadius: BorderRadius.circular(8)),
            ),
          ),
          Positioned(
            right: 5,
            child: Container(
              width: 40,
              height: 35,
              decoration: BoxDecoration(
                  color: white, borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.camera_alt),
            ),
          )
        ],
      ),
    );
  }
}
