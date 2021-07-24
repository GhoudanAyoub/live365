import 'package:LIVE365/SignIn/sign_in_screen.dart';
import 'package:LIVE365/Upload/composents/join.dart';
import 'package:LIVE365/components/picture_card.dart';
import 'package:LIVE365/components/stream_builder_wrapper.dart';
import 'package:LIVE365/models/live.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LiveScreen extends StatefulWidget {
  @override
  _LiveScreenState createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        automaticallyImplyLeading: false,
      ),
      body: scrollFeed(),
    );
  }

  Widget scrollFeed() {
    if (firebaseAuth.currentUser != null) {
      return CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              if (index > 0) return null;
              return StreamBuilderWrapper(
                shrinkWrap: true,
                stream: liveRef.snapshots(),
                text:
                    "\n\n\n\n\n\n\n\nRush and Be The First To\nUpload The First Live 😊",
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, DocumentSnapshot snapshot) {
                  Live live = Live.fromJson(snapshot.data());
                  if (live.endAt != null) return Container();
                  return GestureDetector(
                      onTap: () {
                        onJoin(
                            channelName: live.channelName,
                            channelId: live.channelId,
                            username: live.username,
                            hostImage: live.image,
                            userImage: live.image);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 15.0, left: 10.0, right: 10.0),
                        child: PictureCard(
                          live: live,
                        ),
                      ));
                },
              );
            }),
          ),
        ],
      );
    } else
      return Container(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.tv_circle,
                color: Colors.grey,
                size: 50,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Sign In To Access Live",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                height: 45,
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  color: Colors.redAccent,
                  onPressed: () {
                    Navigator.pushNamed(context, SignInScreen.routeName);
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Lato-Regular.ttf',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

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
