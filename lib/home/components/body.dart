import 'dart:async';
import 'dart:collection';

import 'package:LIVE365/Notification/notification.dart';
import 'package:LIVE365/SignIn/sign_in_screen.dart';
import 'package:LIVE365/Upload/CameraAccessScreen.dart';
import 'package:LIVE365/Upload/composents/create_post.dart';
import 'package:LIVE365/Upload/composents/join.dart';
import 'package:LIVE365/camera/add_video_page.dart';
import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/components/picture_card.dart';
import 'package:LIVE365/components/stream_builder_wrapper.dart';
import 'package:LIVE365/components/stream_comments_wrapper.dart';
import 'package:LIVE365/discover/discover_screen.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/home/components/tiktokscafold.dart';
import 'package:LIVE365/home/components/tiktoktabbar.dart';
import 'package:LIVE365/home/components/tiktokvideopage.dart';
import 'package:LIVE365/home/components/tiktokvideoplayer.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/live.dart';
import 'package:LIVE365/models/post_comments.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/profile/profile_screen.dart';
import 'package:LIVE365/services/video_service.dart';
import 'package:LIVE365/style/style.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safemap/safemap.dart';
import 'package:screen/screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  PageController _pageController = PageController();
  VideoListController _videoListController = VideoListController();
  TikTokScaffoldController tkController = TikTokScaffoldController();
  TikTokPageTag tabBarType = TikTokPageTag.home;
  Map<int, bool> favoriteMap = {};

  TextEditingController commentsTEC = TextEditingController();
  final auth = FirebaseService();
  List<Video> listVideos = [];
  List<DocumentSnapshot> filteredv = [];
  bool followButton = false;
  bool liveButton = true;
  bool recommended = false;
  VideoPlayerController _controller;
  AnimationController animationController;
  PageController pageController =
      PageController(initialPage: 0, viewportFraction: 0.8);
  bool loading = true;
  HashMap isFollowing = new HashMap<String, bool>();
  UserModel users;
  final DateTime timestamp = DateTime.now();
  UserModel user;
  String profileId;

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      _videoListController.currentPlayer.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoListController.currentPlayer.pause();
    Screen.keepOn(false);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    Screen.keepOn(true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    animationController = new AnimationController(
        duration: new Duration(seconds: 5), vsync: this);
    animationController.repeat();
    callList();
    super.initState();
  }

  callList() async {
    listVideos = await VideoService.getVideoList();
    _videoListController.init(
      _pageController,
      listVideos,
    );
    tkController.addListener(
      () {
        if (tkController.value == TikTokPagePositon.middle) {
          _videoListController.currentPlayer.start();
        } else {
          _videoListController.currentPlayer.pause();
        }
      },
    );
  }

  checkIfFollowing(profileId) async {
    DocumentSnapshot doc = await followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(profileId)
        .get();
    setState(() {
      isFollowing.putIfAbsent(profileId, () => doc.exists);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    switch (tabBarType) {
      case TikTokPageTag.home:
        break;
      case TikTokPageTag.search:
        currentPage = DiscoverScreen();
        break;
      case TikTokPageTag.msg:
        currentPage = firebaseAuth.currentUser == null
            ? SignInForMessage()
            : Activities();
        break;
      case TikTokPageTag.me:
        currentPage = firebaseAuth.currentUser == null
            ? SignInForProfile()
            : ProfileScreen(
                profileUID: firebaseAuth.currentUser.uid,
              );
        break;
    }

    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    bool hasBackground = hasBottomPadding;
    hasBackground = tabBarType != TikTokPageTag.home;
    if (hasBottomPadding) {
      hasBackground = true;
    }

    /* var userPage = ProfileScreen(
      profileUID: firebaseAuth.currentUser.uid,
    );*/
    var searchPage = Activities();
    Widget tikTokTabBar = TikTokTabBar(
      hasBackground: hasBackground,
      current: tabBarType,
      onTabSwitch: (type) async {
        setState(() {
          tabBarType = type;
          if (type == TikTokPageTag.home) {
            _videoListController.currentPlayer.start();
          } else {
            _videoListController.currentPlayer.pause();
          }
        });
      },
      onAddButton: () {
        firebaseAuth.currentUser == null
            ? SignInForCamera()
            : chooseUpload(context);
      },
    );

    var header =
        tabBarType == TikTokPageTag.home ? topScrollFeedRow() : Container();

    return Scaffold(
      body: Stack(
        children: [
          homeScreen(header, hasBottomPadding, currentPage, searchPage,
              tikTokTabBar, hasBackground),
          liveButton == true
              ? topScrollFeedRow()
              : Container(
                  height: 0,
                )
        ],
      ),
    );
  }

  SignInForCamera() {
    return showModalBottomSheet(
      backgroundColor: GBottomNav,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: Text(
                    'SELECT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Divider(
                color: Colors.white,
              ),
              ListTile(
                leading: Icon(
                  Icons.login,
                  color: Colors.white,
                  size: 25.0,
                ),
                title: Text('Sign In',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onTap: () async {
                  ///Feature coming soon
                  ///
                  Navigator.pop(context);
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget SignInForProfile() {
    return Scaffold(
        body: Container(
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person,
              color: Colors.grey,
              size: 50,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Sign In For An Account",
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
    ));
  }

  Widget SignInForMessage() {
    return Scaffold(
      body: Container(
        child: Align(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.mail,
                color: Colors.grey,
                size: 50,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Message Will appear here",
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
      ),
    );
  }

  chooseUpload(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: GBottomNav,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: Text(
                    'SELECT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Divider(
                color: Colors.white,
              ),
              ListTile(
                leading: Icon(
                  CupertinoIcons.video_camera,
                  color: Colors.white,
                  size: 25.0,
                ),
                title: Text('Go Live',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraAccessScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  CupertinoIcons.videocam_circle_fill,
                  color: Colors.white,
                  size: 25.0,
                ),
                title: Text('Make Video',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onTap: () async {
                  ///Feature coming soon
                  ///
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddVideoPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  CupertinoIcons.camera_on_rectangle,
                  color: Colors.white,
                  size: 25.0,
                ),
                title: Text('Make a Post',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => CreatePost()));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget homeScreen(header, hasBottomPadding, currentPage, searchPage,
      tikTokTabBar, hasBackground) {
    if (liveButton) {
      return Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 10.0, right: 10.0),
        child: scrollFeed(),
      );
    } else {
      return TikTokScaffold(
        controller: tkController,
        hasBottomPadding: hasBackground,
        tabBar: tikTokTabBar,
        header: header,
        //rightPage: scrollFeed(),
        enableGesture: tabBarType == TikTokPageTag.home,
        //onPullDownRefresh: callList,
        page: Stack(
          children: <Widget>[
            PageView.builder(
              key: Key('home'),
              controller: _pageController,
              pageSnapping: true,
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: _videoListController.videoCount,
              itemBuilder: (context, i) {
                var data = listVideos[i];
                bool isF = SafeMap(favoriteMap)[i].boolean ?? false;
                var player = _videoListController.playerOfIndex(i);

                if (isF == true && firebaseAuth.currentUser != null) {
                  likesRef.add({
                    'userId': currentUserId(),
                    'postId': data.id,
                    'dateCreated': Timestamp.now(),
                  });
                  addLikesToNotification(data);
                }
                print(isF);
                Widget buttons = videoData(i);

                // video
                Widget currentVideo = Center(
                  child: FijkView(
                    fit: FijkFit.fitHeight,
                    player: player,
                    color: Colors.black,
                    panelBuilder: (_, __, ___, ____, _____) => Container(),
                  ),
                );

                currentVideo = TikTokVideoPage(
                  hidePauseIcon: player.state != FijkState.paused,
                  aspectRatio: 9 / 16.0,
                  key: Key(data.mediaUrl + '$i'),
                  tag: data.mediaUrl,
                  bottomPadding: hasBottomPadding ? 16.0 : 16.0,
                  onSingleTap: () async {
                    if (player.state == FijkState.started) {
                      await player.pause();
                    } else {
                      await player.start();
                    }
                    setState(() {});
                  },
                  onAddFavorite: () {
                    setState(() {
                      favoriteMap[i] = true;
                    });
                  },
                  rightButtonColumn: buttons,
                  video: currentVideo,
                );
                return currentVideo;
              },
            ),
            Opacity(
              opacity: 1,
              child: currentPage ?? Container(),
            ),
          ],
        ),
      );
    }
  }

  Widget topScrollFeedRow() {
    return Container(
      width: SizeConfig.screenWidth - 10,
      child: Column(
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
                            fontSize: 16)
                        : TextStyle(
                            color: Colors.grey,
                            fontFamily: "SFProDisplay-Regular",
                            fontSize: 14))),
            Text(
              ".",
              style: TextStyle(
                fontFamily: "SFProDisplay-Bold",
                color: orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            /*
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
                            fontSize: 14))),
            Text(
              ".",
              style: TextStyle(
                fontFamily: "SFProDisplay-Bold",
                color: orange,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),*/
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
                            fontSize: 16)
                        : TextStyle(
                            color: Colors.grey,
                            fontFamily: "SFProDisplay-Regular",
                            fontSize: 14)))
          ])
        ],
      ),
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
    if (firebaseAuth.currentUser != null)
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
    else
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

  Widget videoData(index) {
    return listVideos.length != 0
        ? Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 50),
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
                            '@${listVideos[index].username}',
                            style: StandardTextStyle.big,
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10, bottom: 10),
                            child: Text.rich(
                              TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: listVideos[index].videoTitle,
                                    style: StandardTextStyle.normal),
                                TextSpan(
                                    text: '${listVideos[index].tags}\n',
                                    style: StandardTextStyle.normal),
                              ]),
                              style: StandardTextStyle.normal,
                            )),
                        Container(
                          padding: EdgeInsets.only(left: 10),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.music_note,
                                  size: 16, color: Colors.white),
                              Text(listVideos[index].songName ?? '',
                                  style: StandardTextStyle.normal)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(bottom: 100, right: 10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: getProportionateScreenWidth(50),
                      height: getProportionateScreenHeight(350),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProfileScreen(
                                      profileUID: listVideos[index].ownerId,
                                    ),
                                  ));
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
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
                          ),
                          buildLikeButton(listVideos[index]),
                          SizedBox(height: 3.0),
                          StreamBuilder(
                            stream: likesRef
                                .where('postId',
                                    isEqualTo: listVideos[index].id)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot snap = snapshot.data;
                                List<DocumentSnapshot> docs = snap.docs;
                                return buildLikesCount(
                                    context, docs?.length ?? 0);
                              } else {
                                return buildLikesCount(context, 0);
                              }
                            },
                          ),
                          SizedBox(height: 3.0),
                          IconButton(
                            icon: Icon(
                              Icons.sms,
                              size: 35,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              commentClicked(listVideos[index]);
                            },
                          ),
                          SizedBox(height: 3.0),
                          StreamBuilder(
                            stream: commentRef
                                .doc(listVideos[index].id)
                                .collection("comments")
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot snap = snapshot.data;
                                List<DocumentSnapshot> docs = snap.docs;
                                return buildCommentsCount(
                                    context, docs?.length ?? 0);
                              } else {
                                return buildCommentsCount(context, 0);
                              }
                            },
                          ),
                          SizedBox(height: 3.0),
                          IconButton(
                            icon: Icon(
                              CupertinoIcons.ellipsis,
                              size: 35,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              settingClicked(
                                  listVideos[index], listVideos[index].id);
                            },
                          ),
                          SizedBox(height: 3.0),
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
          )
        : Container();
  }

  settingClicked(video, id) {
    return showModalBottomSheet(
      backgroundColor: GBottomNav,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: .3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: Text(
                    'SELECT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              Divider(
                color: Colors.white,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(width: 10.0),
                  Column(
                    children: [
                      IconButton(
                          icon: Icon(
                            CupertinoIcons.flag,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            report('Content report', id);
                          }),
                      Text('Report',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ],
                  ),
                  SizedBox(width: 10.0),
                  Column(
                    children: [
                      buildBookButton(video),
                      Center(
                          child: Text('Save',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  report(String type, String id) {
    reportRef.doc(id).set({
      'accountId': id,
      'type': type,
      'reporterId': firebaseAuth.currentUser.uid
    });
    Fluttertoast.showToast(
        msg: "Thank You For Reporting We Will Take It From Here",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: GBottomNav,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Widget buildBookButton(video) {
    if (firebaseAuth.currentUser != null)
      return StreamBuilder(
        stream: bookRef
            .where('postId', isEqualTo: video.id)
            .where('userId', isEqualTo: currentUserId())
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> docs = snapshot?.data?.docs ?? [];
            return IconButton(
              onPressed: () {
                if (docs.isEmpty) {
                  bookRef.add({
                    'userId': currentUserId(),
                    'postId': video.id,
                    'dateCreated': Timestamp.now(),
                  });
                } else {
                  bookRef.doc(docs[0].id).delete();
                }
              },
              icon: docs.isEmpty
                  ? Icon(CupertinoIcons.bookmark, size: 25, color: Colors.white)
                  : Icon(
                      CupertinoIcons.bookmark_solid,
                      size: 25,
                      color: Colors.white,
                    ),
            );
          }
          return Container();
        },
      );
  }

  Widget buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Text(
        '${count}comm',
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count likes',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 10.0, color: Colors.white),
      ),
    );
  }

  Widget buildLikeButton(video) {
    if (firebaseAuth.currentUser != null)
      return StreamBuilder(
        stream: likesRef
            .where('postId', isEqualTo: video.id)
            .where('userId', isEqualTo: currentUserId())
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            List<QueryDocumentSnapshot> docs = snapshot?.data?.docs ?? [];
            return IconButton(
              onPressed: () {
                if (docs.isEmpty) {
                  likesRef.add({
                    'userId': currentUserId(),
                    'postId': video.id,
                    'dateCreated': Timestamp.now(),
                  });
                  addLikesToNotification(video);
                } else {
                  likesRef.doc(docs[0].id).delete();
                  removeLikeFromNotification(video);
                }
              },
              icon: docs.isEmpty
                  ? Icon(CupertinoIcons.heart, size: 35, color: Colors.white)
                  : Icon(
                      CupertinoIcons.heart_fill,
                      size: 35,
                      color: Colors.red,
                    ),
            );
          }
          return Container();
        },
      );
    else
      return IconButton(
        onPressed: () {},
        icon: Icon(CupertinoIcons.heart, size: 35, color: Colors.white),
      );
  }

  buildRecButton(profileId, index) {
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
    } else if (isFollowing[profileId] == true) {
      return buildButton(
        text: "Unfollow",
        function: () => handleUnfollow(profileId),
      );
      //if you are not following the user then "follow"
    } else if (isFollowing[profileId] == false) {
      filteredv.removeAt(index);

      return buildButton(
        text: "Follow",
        function: () => handleFollow(profileId),
      );
    }
  }

  handleUnfollow(profileId) async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data());
    setState(() {
      isFollowing.putIfAbsent(profileId, () => false);
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

  handleFollow(profileId) async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    users = UserModel.fromJson(doc.data());
    setState(() {
      isFollowing.putIfAbsent(profileId, () => true);
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

  commentClicked(video) {
    return showModalBottomSheet(
        backgroundColor: GBottomNav,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 1.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [SizedBox(height: 5.0), commentsBody(video)],
                )
              ],
            ),
          );
        });
  }

  commentsBody(video) {
    return Container(
      height: 390,
      child: Column(
        children: [
          buildComments(video),
          firebaseAuth.currentUser != null
              ? Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: GBottomNav,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey[500],
                          offset: Offset(0.0, 1.5),
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 190.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: TextField(
                              textCapitalization: TextCapitalization.sentences,
                              controller: commentsTEC,
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(10.0),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                hintText: "Write your comment...",
                                hintStyle: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.white,
                                ),
                              ),
                              maxLines: null,
                            ),
                            trailing: GestureDetector(
                              onTap: () {
                                addComments(video);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Icon(
                                  Icons.send,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  height: 0,
                ),
        ],
      ),
    );
  }

  addComments(video) async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    user = UserModel.fromJson(doc.data());
    commentRef.doc(video.id).collection("comments").add({
      "username": user.username,
      "comment": commentsTEC.text,
      "timestamp": timestamp,
      "userDp": user.photoUrl,
      "userId": user.id,
    });

    bool isNotMe = video.ownerId != currentUserId();
    if (isNotMe) {
      notificationRef.doc(video.ownerId).collection('notifications').add({
        "type": "comment",
        "commentData": commentsTEC.text,
        "username": user.username,
        "userId": user.id,
        "userDp": user.photoUrl,
        "postId": video.id,
        "mediaUrl": video.mediaUrl,
        "timestamp": timestamp,
      });
    }
    commentsTEC.clear();
  }

  buildComments(video) {
    return CommentsStreamWrapper(
      shrinkWrap: true,
      stream: commentRef
          .doc(video.id)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        CommentModel comments = CommentModel.fromJson(snapshot.data());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(comments.userDp),
              ),
              title: Text(
                comments.username,
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              subtitle: Text(
                timeago.format(comments.timestamp.toDate()),
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Text(
                comments.comment,
                style:
                    TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
              ),
            ),
            Divider(
              color: Colors.white,
              indent: 20,
              endIndent: 25,
            )
          ],
        );
      },
    );
  }

  addLikesToNotification(video) async {
    bool isNotMe;
    if (firebaseAuth.currentUser != null)
      isNotMe = currentUserId() != video.ownerId;

    if (isNotMe && firebaseAuth.currentUser != null) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(video.ownerId)
          .collection('notifications')
          .doc(video.postId)
          .set({
        "type": "like",
        "username": user.username,
        "userId": currentUserId(),
        "userDp": user.photoUrl,
        "postId": video.id,
        "mediaUrl": video.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromNotification(video) async {
    bool isNotMe;
    if (firebaseAuth.currentUser != null)
      isNotMe = currentUserId() != video.ownerId;

    if (isNotMe && firebaseAuth.currentUser != null) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(video.ownerId)
          .collection('notifications')
          .doc(video.id)
          .get()
          .then((doc) => {
                if (doc.exists) {doc.reference.delete()}
              });
    }
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
                              'Follow an account to see their latest video',
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
          child: Text("You Got Every Last Videos Found",
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

  Widget videoSlider(filteredv, int index) {
    if (index != null) {
      DocumentSnapshot doc = filteredv[index];
      Video video = Video.fromJson(doc.data());
      profileId = video.ownerId;
      checkIfFollowing(profileId);
      if (isFollowing[profileId] == true) {
        Timer(Duration(milliseconds: 1), () {
          setState(() {
            removeFromList(index);
          });
        });
      }
      Timer(Duration(milliseconds: 5), () {
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
                            backgroundImage: NetworkImage(video?.userPic),
                            radius: 30,
                          )),
                      Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                              video.username == null ? '' : video.username,
                              style: TextStyle(color: Colors.white))),
                      Text(video.videoTitle == null ? '' : video.videoTitle,
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.5))),
                      SizedBox(height: 10),
                      buildRecButton(video?.ownerId, index),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      });
    }
  }
}
