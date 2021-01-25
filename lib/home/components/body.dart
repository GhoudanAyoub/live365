import 'package:flutter/material.dart';
import 'package:live365/components/picture_card.dart';
import 'package:live365/home/components/header_home_page.dart';

import '../../SizeConfig.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: getProportionateScreenHeight(20)),
            HeaderHomePage(),
            SizedBox(height: getProportionateScreenWidth(10)),
            PictureCard(
              image: "assets/images/image.jpg",
              press: () {},
            ),
            /*
            DiscountBanner(),
            Categories(),
            SizedBox(height: getProportionateScreenWidth(30)),
            PopularProducts(),
            SizedBox(height: getProportionateScreenWidth(30)),*/
          ],
        ),
      ),
    );
  }
}
