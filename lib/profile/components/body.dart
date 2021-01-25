import 'package:flutter/material.dart';
import 'package:live365/components/IconBtnWithCounter.dart';
import 'package:live365/components/profile_box_data.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import 'profile_pic.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          SizedBox(height: getProportionateScreenWidth(10)),
          Container(
              child: Center(
            child: Row(
              children: [
                SizedBox(width: getProportionateScreenWidth(10)),
                IconBtnWithCounter(
                  svgSrc: "assets/icons/icons8-settings.svg",
                  numOfitem: 0,
                  press: () {},
                ),
                SizedBox(
                  width: getProportionateScreenWidth(260),
                  height: getProportionateScreenWidth(15),
                ),
                IconBtnWithCounter(
                  svgSrc: "assets/icons/icons8-search.svg",
                  numOfitem: 0,
                  press: () {},
                ),
                SizedBox(width: getProportionateScreenWidth(10)),
              ],
            ),
          )),
          ProfilePic(),
          SizedBox(height: 20),
          Text("Mr X",
              style: TextStyle(
                fontSize: getProportionateScreenWidth(22),
                color: GTextColorWhite,
                fontFamily: "SFProDisplay-Bold",
                fontWeight: FontWeight.bold,
              )),
          SizedBox(height: 5),
          Text("Lid",
              style: TextStyle(
                fontSize: getProportionateScreenWidth(20),
                color: GTextColorWhite,
                fontFamily: "SFProDisplay-Thin",
                fontWeight: FontWeight.w100,
              )),
          SizedBox(height: 10),
          Center(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                child: Text(
                    "Lorem ipsum, or lipsum as it is sometimes known, graphic or web designs.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: getProportionateScreenWidth(15),
                      color: GTextColorWhite,
                      fontFamily: "SFProDisplay-Light",
                      fontWeight: FontWeight.normal,
                    )),
              ),
            ),
          ),
          SizedBox(height: 10),
          ProfileBoxData(
            LIKES: "200",
            FOLLOWING: "3556",
            FOLLOWERS: "3365",
          ), /*
          Container(
            child: GridView.count(
              crossAxisCount: 2,
              children: List.generate(20, (index) {
                return Center(
                  child: Text(index.toString()),
                );
              }),
            ),
          )*/
        ],
      ),
    );
  }
}
