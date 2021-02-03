import 'dart:async';
import 'dart:math' as math;

import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/components/picture_card.dart';
import 'package:LIVE365/components/stream_builder_wrapper.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/live.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/profile/profile_screen.dart';
import 'package:LIVE365/services/video_service.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  final auth = FirebaseService();
  final FlareControls flareControls = FlareControls();
  final databaseReference = FirebaseFirestore.instance;
  static List<Video> listVideos = List<Video>();
  List<DocumentSnapshot> v = [];
  List<DocumentSnapshot> filteredv = [];
  bool ready = false;
  Live liveUser;
  bool followButton = false;
  bool liveButton = true;
  bool recommended = false;
  bool play = true;
  int videoIndex;
  VideoPlayerController _controller;
  VideoPlayerController _controllerRec;
  AnimationController animationController;
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  PageController foryouController = new PageController();
  bool loading = true;
  bool isFollowing = false;
  UserModel users;
  final DateTime timestamp = DateTime.now();

  String profileId;

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        duration: new Duration(seconds: 5), vsync: this);
    animationController.repeat();
    if (_controller != null) _controller.pause();
    if (_controllerRec != null) _controllerRec.pause();
    if (profileId != null) checkIfFollowing(profileId);
    getVideosList();
    callList();
  }

  checkIfFollowing(profileId) async {
    DocumentSnapshot doc = await followersRef
        .doc(profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controllerRec.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [homeScreen(), topScrollFeedRow()],
      ),
    );
  }

  Widget homeScreen() {
    if (liveButton) {
      if (_controller != null) _controller.pause();
      if (_controllerRec != null) _controllerRec.pause();
      return scrollFeed();
    }
    if (recommended) {
      if (_controller != null) _controller.pause();
      if (_controllerRec != null) _controllerRec.pause();
      return recommendedFeed();
    } else {
      return followFeed();
    }
  }

  buildRecButton(profileId) {
    //if isMe then display "edit profile"
    bool isMe = profileId == firebaseAuth.currentUser.uid;
    if (isMe) {
      return buildButton(
        text: "Account",
        function: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(
                  profileUID: firebaseAuth.currentUser.uid,
                ),
              ));
        },
      );
      //if you are already following the user then "unfollow"
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        function: handleUnfollow,
      );
      //if you are not following the user then "follow"
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        function: handleFollow,
      );
    }
  }

  handleUnfollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data());
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .doc(profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove following
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove from notifications feeds
    notificationRef
        .doc(profileId)
        .collection('notifications')
        .doc(currentUserId())
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollow() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data());
    setState(() {
      isFollowing = true;
    });
    //updates the followers collection of the followed user
    followersRef
        .doc(profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});
    //updates the following collection of the currentUser
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(profileId)
        .set({});
    //update the notification feeds
    notificationRef
        .doc(profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "follow",
      "ownerId": profileId,
      "username": users.username,
      "userId": users.id,
      "userDp": users.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildButton({String text, Function function}) {
    return Center(
      child: GestureDetector(
        onTap: function,
        child: Container(
          height: 40.0,
          width: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                orange,
                orange,
              ],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget videoSlider(filteredv, int index) {
    DocumentSnapshot doc = filteredv[index];
    Video video = Video.fromJson(doc.data());
    profileId = video.ownerId;
    checkIfFollowing(video.ownerId);
    if (video.ownerId == currentUserId()) {
      Timer(Duration(milliseconds: 50), () {
        setState(() {
          //removeFromList(index);
        });
      });
    }
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, widget) {
        double value = 1;
        if (pageController.position.haveDimensions) {
          value = pageController.page - index;
          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
        }
        return Center(
          child: SizedBox(
            height: Curves.easeInOut.transform(value) * 372,
            width: Curves.easeInOut.transform(value) * 300,
            child: widget,
          ),
        );
      },
      child: Stack(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: VideoPlayer(_controller),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(5),
                child: Icon(
                  Icons.close,
                  size: 15,
                  color: Colors.white,
                ),
              )),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(bottom: 15),
              height: 370 / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(bottom: 15),
                      child: CircleAvatar(
                        backgroundColor: Colors.black,
                        backgroundImage: NetworkImage(video.userPic),
                        radius: 30,
                      )),
                  Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(video.username,
                          style: TextStyle(color: Colors.white))),
                  Text(video.videoTitle,
                      style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  SizedBox(height: 10),
                  buildRecButton(video.ownerId),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget topScrollFeedRow() {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          FlatButton(
              onPressed: () {
                setState(() {
                  followButton = false;
                  liveButton = true;
                  recommended = false;
                });
              },
              child: Text('LIVE',
                  style: liveButton
                      ? TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "SFProDisplay-Regular",
                          fontSize: 18)
                      : TextStyle(
                          color: Colors.grey,
                          fontFamily: "SFProDisplay-Regular",
                          fontSize: 16))),
          SizedBox(
            width: getProportionateScreenWidth(5),
          ),
          Text(
            ".",
            style: TextStyle(
              fontFamily: "SFProDisplay-Bold",
              color: orange,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: getProportionateScreenWidth(5),
          ),
          FlatButton(
              onPressed: () {
                setState(() {
                  followButton = false;
                  liveButton = false;
                  recommended = true;
                });
              },
              child: Text('RECOMMENDED',
                  style: recommended
                      ? TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "SFProDisplay-Regular",
                          fontSize: 16)
                      : TextStyle(
                          color: Colors.grey,
                          fontFamily: "SFProDisplay-Regular",
                          fontSize: 16))),
          SizedBox(
            width: getProportionateScreenWidth(5),
          ),
          Text(
            ".",
            style: TextStyle(
              fontFamily: "SFProDisplay-Bold",
              color: orange,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            width: getProportionateScreenWidth(5),
          ),
          FlatButton(
              onPressed: () {
                setState(() {
                  followButton = true;
                  liveButton = false;
                  recommended = false;
                });
              },
              child: Text('FOLLOW',
                  style: followButton
                      ? TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: "SFProDisplay-Regular",
                          fontSize: 18)
                      : TextStyle(
                          color: Colors.grey,
                          fontFamily: "SFProDisplay-Regular",
                          fontSize: 16)))
        ])
      ],
    );
  }

  removeFromList(index) {
    filteredv.removeAt(index);
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );

  Widget scrollFeed() {
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
                  "\n\n\n\n\n\n\n\nRush and Be The First To\nUpload The First Video 😊",
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, DocumentSnapshot snapshot) {
                Live live = Live.fromJson(snapshot.data());
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 15.0, left: 10.0, right: 10.0),
                  child: PictureCard(
                    live: live,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget followFeed() {
    return listVideos.isNotEmpty
        ? PageView.builder(
            controller: foryouController,
            onPageChanged: (index) {
              setState(() {
                _controller =
                    VideoPlayerController.network(listVideos[index].mediaUrl);
                _controller.seekTo(Duration.zero);
                _controller.play();
              });
            },
            scrollDirection: Axis.vertical,
            itemCount: listVideos.length,
            itemBuilder: (context, index) {
              return Stack(
                children: <Widget>[
                  FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        setState(() {
                          if (play) {
                            if (_controller != null) _controller.pause();
                            play = !play;
                          } else {
                            _controller.play();
                            play = !play;
                          }
                        });
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: VideoPlayer(_controller),
                      )),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 100,
                        height: 100,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 10, bottom: 10),
                              child: Text(
                                listVideos[index].username,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 10),
                                child: Text.rich(
                                  TextSpan(children: <TextSpan>[
                                    TextSpan(
                                        text: listVideos[index].videoTitle),
                                    TextSpan(
                                        text: '${listVideos[index].tags}\n',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ]),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.music_note,
                                      size: 16, color: Colors.white),
                                  Text(listVideos[index].songName,
                                      style: TextStyle(color: Colors.white))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(bottom: 15, right: 10),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: getProportionateScreenWidth(50),
                          height: getProportionateScreenHeight(300),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(bottom: 15),
                                width: 40,
                                height: getProportionateScreenHeight(50),
                                child: Stack(
                                  children: <Widget>[
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 19,
                                        backgroundColor: Colors.black,
                                        backgroundImage: NetworkImage(
                                            listVideos[index].userPic),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(Icons.favorite,
                                        size: 35, color: Colors.white),
                                    Text('427.9K',
                                        style: TextStyle(color: Colors.white))
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.rotationY(math.pi),
                                        child: Icon(Icons.sms,
                                            size: 35, color: Colors.white)),
                                    Text('2051',
                                        style: TextStyle(color: Colors.white))
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: animationController,
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundColor:
                                      Colors.grey[400].withOpacity(0.1),
                                  child: CircleAvatar(
                                    radius: 12,
                                    backgroundImage:
                                        AssetImage('assets/images/effects.png'),
                                  ),
                                ),
                                builder: (context, _widget) {
                                  return Transform.rotate(
                                      angle: animationController.value * 6.3,
                                      child: _widget);
                                },
                              )
                            ],
                          ),
                        ),
                      ))
                ],
              );
            })
        : Center(
            child: Container(
              child:
                  Text('Rush and Be The First \n To Upload The First Video 😊'),
            ),
          );
  }

  Widget recommendedFeed() {
    return Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(bottom: 14),
                    child: Text(
                      'Trending Creators',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "SFProDisplay-Regular",
                          fontSize: 20),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: Text(
                              'Follow an account to see their latest video here',
                              style: TextStyle(
                                  fontFamily: "SFProDisplay-Regular",
                                  color: Colors.white.withOpacity(0.8))),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            Container(
              height: 372,
              margin: EdgeInsets.only(top: 25),
              child: buildVideoSlider(),
            )
          ],
        ));
  }

  buildVideoSlider() {
    if (!loading) {
      if (filteredv.isEmpty) {
        return Center(
          child: Text("No Videos Found",
              style: TextStyle(fontWeight: FontWeight.bold)),
        );
      } else {
        return PageView.builder(
            dragStartBehavior: DragStartBehavior.down,
            controller: pageController,
            itemCount: filteredv.length,
            itemBuilder: (context, position) {
              return videoSlider(filteredv, position);
            });
      }
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }

  callList() async {
    listVideos = await VideoService.getVideoList();
    if (listVideos.isNotEmpty) {
      _controllerRec = VideoPlayerController.network(listVideos[0].mediaUrl);
      _controller = VideoPlayerController.network(listVideos[0].mediaUrl)
        ..initialize().then((value) {
          _controller.play();
          _controller.setLooping(true);
          setState(() {});
        });
    }
  }

  getVideosList() async {
    QuerySnapshot snap = await videoRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    v = doc;
    filteredv = doc;
    setState(() {
      loading = false;
    });
  }

  void changeVideo(index) {
    if (listVideos.isNotEmpty) {
      setState(() {
        _controller = VideoPlayerController.network(listVideos[index].mediaUrl);
      });
    }
  }

  void changeVideo2(Video v) {
    if (listVideos.isNotEmpty) {
      setState(() {
        _controller = VideoPlayerController.network(v.mediaUrl);
      });
    }
  }
}
