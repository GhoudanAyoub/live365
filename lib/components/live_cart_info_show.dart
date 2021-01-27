import 'package:flutter/material.dart';

import '../SizeConfig.dart';

class LiveCardInfoShow extends StatelessWidget {
  final String image;
  final String name;
  final String Views;
  final Function press;

  const LiveCardInfoShow(
      {Key key, this.image, this.name, this.Views, this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: getProportionateScreenWidth(20),
      alignment: Alignment.bottomRight,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(50.0)),
      child: Row(
        children: [
          SizedBox(width: getProportionateScreenWidth(2)),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: NetworkImage(image), fit: BoxFit.cover)),
          ),
          SizedBox(width: getProportionateScreenWidth(5)),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: getProportionateScreenHeight(10)),
              buildText(name),
              SizedBox(height: getProportionateScreenHeight(5)),
              Row(
                children: [
                  Image.asset(
                    "assets/images/eye.png",
                    height: getProportionateScreenHeight(20),
                    width: getProportionateScreenWidth(20),
                  ),
                  buildText(Views),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
}
