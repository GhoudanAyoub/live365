import 'package:LIVE365/components/IconBtnWithCounter.dart';
import 'package:LIVE365/components/profile_box_data.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/users.dart';
import 'package:LIVE365/profile/components/profile_pic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class Body extends StatelessWidget {
  final auth = FirebaseService();
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
          FutureBuilder(
            future: auth.getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return DisplayUserInformation(context, snapshot);
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget DisplayUserInformation(context, snapshot) {
    final authData = snapshot.data;
    return Column(
      children: <Widget>[
        ProfilePic(
          image: auth.getProfileImage(),
        ),
        SizedBox(height: 20),
        Text("${authData.displayName ?? 'Anonymous'}",
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
        StreamBuilder<List<users>>(
          stream: FirebaseService.GetUserData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return buildText('Something Went Wrong Try later');
                } else {
                  final usersList = snapshot.data;
                  users finalUser;
                  if (usersList.isEmpty) {
                    return buildText('No Data Found');
                  } else {
                    for (users user in usersList) {
                      if (user.id == FirebaseAuth.instance.currentUser.uid) {
                        finalUser = user;
                      }
                    }
                  }
                  return Column(
                    children: [
                      ProfileBoxData(
                        LIKES: finalUser.like.toString(),
                        FOLLOWING: finalUser.following.toString(),
                        FOLLOWERS: finalUser.followers.toString(),
                      )
                    ],
                  );
                }
            }
          },
        ),
        /*
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
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
}
