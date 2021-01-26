import 'package:LIVE365/components/picture_card.dart';
import 'package:LIVE365/home/components/header_home_page.dart';
import 'package:LIVE365/models/UserMessages.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            HeaderHomePage(),
            SizedBox(
              height: getProportionateScreenWidth(15),
              width: getProportionateScreenWidth(15),
            ),
            ...List.generate(
              userMessages.length,
              (index) {
                return index.isNegative
                    ? Center(child: CircularProgressIndicator())
                    : PictureCard(
                        image: userMessages[index]["img"],
                        name: userMessages[index]["name"],
                        Like: userMessages[index]["Like"],
                        Comments: userMessages[index]["Comment"],
                        Views: "1236",
                        press: () {},
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
