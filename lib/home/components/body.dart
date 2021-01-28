import 'package:LIVE365/Upload/composents/join.dart';
import 'package:LIVE365/components/picture_card.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/home/components/header_home_page.dart';
import 'package:LIVE365/models/live.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../utils.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final auth = FirebaseService();
  final FlareControls flareControls = FlareControls();
  final databaseReference = FirebaseFirestore.instance;
  List<Live> list = [];
  bool ready = false;
  Live liveUser;

  @override
  void initState() {
    super.initState();
    list = [];
    liveUser = new Live(
        username: auth.getCurrentUserName(),
        me: true,
        hostImage: auth.getProfileImage());
    setState(() {
      list.add(liveUser);
    });
    dbChangeListen();
  }

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
              list.length,
              (index) {
                return index.isNegative
                    ? Center(child: CircularProgressIndicator())
                    : list[index].me == true
                        ? buildText("NO LIVE FOUND ")
                        : PictureCard(
                            image: list[index].image,
                            name: list[index].username,
                            Like: "4",
                            Comments: "0",
                            Views: "1236",
                            press: () => onJoin(
                                channelName: list[index].channelName,
                                channelId: list[index].channelId,
                                username: list[index].username,
                                hostImage: list[index].hostImage,
                                userImage: list[index].image));
              },
            ),
          ],
        ),
      ),
    );
  }

  void dbChangeListen() {
    databaseReference
        .collection('liveuser')
        .orderBy("time", descending: true)
        .snapshots()
        .transform(Utils.transformer(Live.fromJson))
        .listen((result) {
      setState(() {
        list = [];
        liveUser = new Live(
            username: auth.getCurrentUserName(),
            me: true,
            image: auth.getProfileImage());
        list.add(liveUser);
      });
      if (result.hasError) {
        print(result.error);
        return buildText('Something Went Wrong Try later');
      } else {
        final liveList = result.data;
        if (liveList.isEmpty) {
          return Center(
            child: buildText('No Live Found'),
          );
        } else {
          for (Live live in liveList) {
            setState(() {
              list.add(live);
            });
          }
        }
      }
    });
  }

  Widget buildText(String text) => Center(
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
      );
  Future<void> onJoin(
      {channelName, channelId, username, hostImage, userImage}) async {
    // update input validation
    if (channelName.isNotEmpty) {
      // push video page with given channel name
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JoinPage(
            channelName: channelName,
            channelId: channelId,
            username: username,
            hostImage: hostImage,
            userImage: userImage,
          ),
        ),
      );
    }
  }
}
