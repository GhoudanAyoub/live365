import 'dart:math' as math;

import 'package:LIVE365/components/picture_card.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/FakeRepository.dart';
import 'package:LIVE365/models/live.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import '../../utils.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  final auth = FirebaseService();
  final FlareControls flareControls = FlareControls();
  final databaseReference = FirebaseFirestore.instance;
  List<Live> list = [];
  bool ready = false;
  Live liveUser;
  bool followButton = false;
  bool liveButton = true;
  bool recommended = false;
  bool play = true;
  int videoIndex;
  VideoPlayerController _controller;
  AnimationController animationController;
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0);
  PageController foryouController = new PageController();

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
        duration: new Duration(seconds: 5), vsync: this);
    animationController.repeat();
    videoIndex = 0;
    _controller = VideoPlayerController.network(
        FakeRepository.videoList[0]["videos"]["video$videoIndex"]["url"])
      ..initialize().then((value) {
        _controller.play();
        _controller.setLooping(true);
        setState(() {});
      });
    list = [];
    dbChangeListen();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          homescreen(),
          Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
          )
        ],
      ),
    );
  }

  homescreen() {
    if (liveButton) {
      _controller.pause();
      return scrollFeed();
    }
    if (recommended) {
      _controller.pause();
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
                child: PageView.builder(
                    dragStartBehavior: DragStartBehavior.down,
                    controller: pageController,
                    itemCount: 5,
                    itemBuilder: (context, position) {
                      return videoSlider(position);
                    }),
              )
            ],
          ));
    } else {
      return PageView.builder(
          controller: foryouController,
          onPageChanged: (index) {
            setState(() {
              _controller.seekTo(Duration.zero);
              _controller.play();
            });
          },
          scrollDirection: Axis.vertical,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Stack(
              children: <Widget>[
                FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        videoIndex = index;
                        if (play) {
                          _controller.pause();
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
                              FakeRepository.videoList[0]["videos"]
                                  ["video$index"]["user"],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 10, bottom: 10),
                              child: Text.rich(
                                TextSpan(children: <TextSpan>[
                                  TextSpan(
                                      text: FakeRepository.videoList[0]
                                              ["videos"]["video$index"]
                                          ["video_title"]),
                                  TextSpan(
                                      text: '#foot\n',
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
                                Text(
                                    FakeRepository.videoList[0]["videos"]
                                        ["video$index"]["song_name"],
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
                                      backgroundImage: AssetImage(
                                          'assets/images/Profile Image.png'),
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
          });
    }
  }

  videoSlider(int index) {
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
                        backgroundImage:
                            AssetImage('assets/images/Profile Image.png'),
                        radius: 30,
                      )),
                  Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child:
                          Text('Spook', style: TextStyle(color: Colors.white))),
                  Text('@spook_clothing',
                      style: TextStyle(color: Colors.white.withOpacity(0.5))),
                  Container(
                      height: 50,
                      margin: EdgeInsets.only(left: 50, right: 50, top: 12),
                      decoration: BoxDecoration(
                        color: orange,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                        child: Text(
                          'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                      ))
                ],
              ),
            ),
          )
        ],
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
      final liveList = result;
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
    });
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );

  Widget scrollFeed() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*Real One
            ...List.generate(
              list.length,
                  (index) {
                return index.isNegative
                    ? Center(child: CircularProgressIndicator())
                    : list.isEmpty
                    ? buildText("NO LIVE FOUND")
                    : PictureCard(
                    image: list[index].image,
                    name: list[index].username,
                    Like: "0",
                    Comments: "0",
                    Views: "0",);
              },
            ),*/
            ...List.generate(
              5,
              (index) {
                return index.isNegative
                    ? Center(child: CircularProgressIndicator())
                    : PictureCard(
                        image: FakeRepository.videoList[0]["videos"]
                            ["video$index"]["user_pic"],
                        name: FakeRepository.videoList[0]["videos"]
                            ["video$index"]["video_title"],
                        Like: "0",
                        Comments: "0",
                        Views: "0",
                      );
              },
            ),
          ],
        ),
      ),
    );
    /*
      *
            ...List.generate(
              list.length,
              (index) {
                return index.isNegative
                    ? Center(child: CircularProgressIndicator())
                    : list.isEmpty
                        ? buildText("NO LIVE FOUND")
                        : PictureCard(
                            image: list[index].image,
                            name: list[index].username,
                            Like: "0",
                            Comments: "0",
                            Views: "0",
                            press: () => onJoin(
                                channelName: list[index].channelName,
                                channelId: list[index].channelId,
                                username: list[index].username,
                                hostImage: list[index].hostImage,
                                userImage: list[index].image));
              },
            ),
      * */
  }
}
