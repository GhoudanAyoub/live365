import 'package:LIVE365/Settings/setting_screen.dart';
import 'package:LIVE365/components/IconBtnWithCounter.dart';
import 'package:LIVE365/components/profile_box_data.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/users.dart';
import 'package:LIVE365/profile/components/profile_pic.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
                  press: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingScreen(),
                        ));
                  },
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
          GridView.count(
            crossAxisCount: 2,
            primary: false,
            crossAxisSpacing: 2.0,
            mainAxisSpacing: 4.0,
            shrinkWrap: true,
            children: [
              ...List.generate(ImageList.length, (index) {
                return index.isNegative
                    ? Center(child: CircularProgressIndicator())
                    : Card(
                        color: Colors.white.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)),
                        elevation: 2.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          child: CachedNetworkImage(
                            imageUrl: ImageList[index]["image"],
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(milliseconds: 500),
                            fadeInCurve: Curves.easeIn,
                            placeholder: (context, progressText) =>
                                Center(child: CircularProgressIndicator()),
                          ),
                        ),
                        margin: index.isEven
                            ? EdgeInsets.fromLTRB(20.0, 0.0, 5.0, 5.0)
                            : EdgeInsets.fromLTRB(5.0, 0.0, 20.0, 5.0));
              })
            ],
          )
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
        SizedBox(height: 5),
        Text("${authData.displayName ?? 'Anonymous'}",
            style: TextStyle(
              fontSize: getProportionateScreenWidth(22),
              color: GTextColorWhite,
              fontFamily: "SFProDisplay-Bold",
              fontWeight: FontWeight.bold,
            )),
        SizedBox(height: 5),
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
                      Text(
                          "${finalUser.subName.isEmpty ? 'Lid' : finalUser.subName}",
                          style: TextStyle(
                            fontSize: getProportionateScreenWidth(20),
                            color: GTextColorWhite,
                            fontFamily: "SFProDisplay-Thin",
                            fontWeight: FontWeight.w100,
                          )),
                      Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: Text(
                                "${finalUser.quot.isEmpty ? 'Lorem ipsum, or lipsum as it is sometimes known, graphic or web designs.' : finalUser.quot}",
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
                      ProfileBoxData(
                        LIKES: finalUser.like.toString(),
                        FOLLOWING: finalUser.following.toString(),
                        FOLLOWERS: finalUser.followers.toString(),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      ],
    );
  }

  List ImageList = [
    {
      "image":
          "https://images.unsplash.com/photo-1602015517849-955895c12de8?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=334&q=80",
    },
    {
      "image":
          "https://images.unsplash.com/photo-1474736584619-88d24be1069e?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1050&q=80",
    },
    {
      "image":
          "https://images.unsplash.com/photo-1605671690484-8e0ce1db0e52?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=334&q=80",
    },
    {
      "image":
          "https://images.unsplash.com/photo-1554935208-2bc12b516985?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=750&q=80",
    },
  ];
  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
}
