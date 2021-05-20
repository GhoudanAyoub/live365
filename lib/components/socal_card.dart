import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocalCard extends StatelessWidget {
  const SocalCard({Key key, this.icon, this.press, this.Name, this.color})
      : super(key: key);

  final String icon;
  final String Name;
  final Function press;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(10),
        height: 40,
        child: Row(
          children: [
            SvgPicture.asset(icon),
            SizedBox(
              width: 10,
            ),
            Text(
              Name,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lato-Bold.ttf',
                  color: color != null ? color : Colors.red[800]),
            )
          ],
        ),
      ),
    );
  }
}
