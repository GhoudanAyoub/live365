import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:LIVE365/Upload/composents/join.dart';
import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/components/picture_card.dart';
import 'package:LIVE365/components/stream_builder_wrapper.dart';
import 'package:LIVE365/components/stream_comments_wrapper.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/live.dart';
import 'package:LIVE365/models/post_comments.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/profile/profile_screen.dart';
import 'package:LIVE365/services/video_service.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:screen/screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> with SingleTickerProviderStateMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  TextEditingController commentsTEC = TextEditingController();
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
  HashMap isFollowing = new HashMap<String, bool>();
  UserModel users;
  final DateTime timestamp = DateTime.now();
  UserModel user;
  String profileId;
  String likeNum;

//********
  var _playingIndex = -1;
  var _disposed = false;
  var _isFullScreen = false;
  var _isEndOfClip = false;
  var _progress = 0.0;
  var _showingDialog = false;
  Timer _timerVisibleControl;
  double _controlAlpha = 1.0;

  var _updateProgressInterval = 0.0;
  Duration _duration;
  Duration _position;

  var _playing = false;
  bool get _isPlaying {
    return _playing;
  }

  set _isPlaying(bool value) {
    _playing = value;
    _timerVisibleControl?.cancel();
    if (value) {
      _timerVisibleControl = Timer(Duration(seconds: 2), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 0.0;
        });
      });
    } else {
      _timerVisibleControl = Timer(Duration(milliseconds: 200), () {
        if (_disposed) return;
        setState(() {
          _controlAlpha = 1.0;
        });
      });
    }
  }

  void _onTapVideo() {
    debugPrint("_onTapVideo $_controlAlpha");
    setState(() {
      _controlAlpha = _controlAlpha > 0 ? 0 : 1;
    });
    _timerVisibleControl?.cancel();
    _timerVisibleControl = Timer(Duration(seconds: 2), () {
      if (_isPlaying) {
        setState(() {
          _controlAlpha = 0.0;
        });
      }
    });
  }

  //******
  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  void initState() {
    Screen.keepOn(true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    animationController = new AnimationController(
        duration: new Duration(seconds: 5), vsync: this);
    animationController.repeat();
    if (_controller != null) _controller.play();
    if (_controllerRec != null) _controllerRec.pause();

    likeNum = '0';
    getVideosList();
    callList();
    _initializeAndPlay(0);
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
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

  void _initializeAndPlay(int index) async {
    print("_initializeAndPlay ---------> $index");
    if (index == -1) index = 0;
    print("_initializeAndPlay ---------> $index");
    final clip = listVideos[index];

    final controller = clip.mediaUrl.startsWith("https")
        ? VideoPlayerController.network(clip.mediaUrl)
        : VideoPlayerController.asset(clip.mediaUrl);

    final old = _controller;
    _controller = controller;
    if (old != null) {
      old.removeListener(_onControllerUpdated);
      old.pause();
      debugPrint("---- old contoller paused.");
    }

    debugPrint("---- controller changed.");
    setState(() {});

    controller
      ..initialize().then((_) {
        debugPrint("---- controller initialized");
        old?.dispose();
        _playingIndex = index;
        _duration = null;
        _position = null;
        controller.addListener(_onControllerUpdated);
        controller.play();
        setState(() {});
      });
  }

  void _onControllerUpdated() async {
    if (_disposed) return;
    // blocking too many updation
    // important !!
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_updateProgressInterval > now) {
      return;
    }
    _updateProgressInterval = now + 500.0;

    final controller = _controller;
    if (controller == null) return;
    if (!controller.value.initialized) return;
    if (_duration == null) {
      _duration = _controller.value.duration;
    }
    var duration = _duration;
    if (duration == null) return;

    var position = await controller.position;
    _position = position;
    final playing = controller.value.isPlaying;
    final isEndOfClip = position.inMilliseconds > 0 &&
        position.inSeconds + 1 >= duration.inSeconds;
    if (playing) {
      // handle progress indicator
      if (_disposed) return;
      setState(() {
        _progress = position.inMilliseconds.ceilToDouble() /
            duration.inMilliseconds.ceilToDouble();
      });
    }

    // handle clip end
    if (_isPlaying != playing || _isEndOfClip != isEndOfClip) {
      _isPlaying = playing;
      _isEndOfClip = isEndOfClip;
      debugPrint(
          "updated -----> isPlaying=$playing / isEndOfClip=$isEndOfClip");
      if (isEndOfClip && !playing) {
        debugPrint(
            "========================== End of Clip / Handle NEXT ========================== ");
        final isComplete = _playingIndex == listVideos.length - 1;
        if (isComplete) {
          print("played all!!");
          if (!_showingDialog) {
            _showingDialog = true;
            _showPlayedAllDialog().then((value) {
              _showingDialog = false;
            });
          }
        } else {
          _initializeAndPlay(_playingIndex + 1);
        }
      }
    }
  }

  Future<bool> _showPlayedAllDialog() async {
    return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(child: Text("Played all videos.")),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () => Navigator.pop(context, true),
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    _disposed = true;
    _timerVisibleControl.cancel();
    Screen.keepOn(false);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    _controller.pause(); // mute instantly
    _controller.dispose();
    _controller = null;
    animationController.dispose();
    super.dispose();
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
      return Padding(
        padding: const EdgeInsets.only(top: 80.0, left: 10.0, right: 10.0),
        child: scrollFeed(),
      );
    }
    if (recommended) {
      if (_controller != null) _controller.pause();
      if (_controllerRec != null) _controllerRec.pause();
      return recommendedFeed();
    } else {
      if (_controller != null) _controller.play();
      return followFeed();
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

  Widget followFeed() {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: BasicOverlayWidget());
  }

  Future<Null> _refresh() async {
    return await VideoService.getVideoList().then((_user) {
      setState(() => listVideos = _user);
    });
  }

  Widget BasicOverlayWidget() {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[_playView(context), videoData(_playingIndex)],
    );
  }

  Widget videoData(index) {
    return listVideos.length != 0
        ? index == -1
            ? Stack(
                children: [
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
                                listVideos[0].username,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 10),
                                child: Text.rich(
                                  TextSpan(children: <TextSpan>[
                                    TextSpan(text: listVideos[0].videoTitle),
                                    TextSpan(
                                        text: '${listVideos[0].tags ?? ''}\n',
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
                                  Text(listVideos[0].songName ?? '',
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
                          height: 350,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                          profileUID: listVideos[0].ownerId,
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
                                              listVideos[0].userPic),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              buildLikeButton(listVideos[0]),
                              SizedBox(height: 3.0),
                              StreamBuilder(
                                stream: likesRef
                                    .where('postId',
                                        isEqualTo: listVideos[0].id)
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
                                  commentClicked(listVideos[0]);
                                },
                              ),
                              SizedBox(height: 3.0),
                              StreamBuilder(
                                stream: commentRef
                                    .doc(listVideos[0].id)
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
                                      listVideos[0], listVideos[0].id);
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
            : Stack(
                children: [
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
                                  Text(listVideos[index].songName ?? '',
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

  Widget _playView(BuildContext context) {
    final controller = _controller;
    if (controller != null && controller.value.initialized) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: Stack(
                children: <Widget>[
                  GestureDetector(
                    child: VideoPlayer(controller),
                    onTap: _onTapVideo,
                  ),
                  _controlAlpha > 0
                      ? AnimatedOpacity(
                          opacity: _controlAlpha,
                          duration: Duration(milliseconds: 250),
                          child: _controlView(context),
                        )
                      : Container(),
                ],
              ),
            )),
      );
    } else {
      return AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: Center(child: circularProgress(context)),
      );
    }
  }

  Widget _controlView(BuildContext context) {
    return Column(
      children: <Widget>[
        _topUI(),
        Expanded(
          child: _centerUI(),
        ),
      ],
    );
  }

  Widget _centerUI() {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          onPressed: () async {
            final index = _playingIndex - 1;
            if (index > 0 && listVideos.length > 0) {
              _initializeAndPlay(index);
            }
          },
          child: Icon(
            Icons.fast_rewind,
            size: 36.0,
            color: Colors.white,
          ),
        ),
        FlatButton(
          onPressed: () async {
            if (_isPlaying) {
              _controller?.pause();
              _isPlaying = false;
            } else {
              final controller = _controller;
              if (controller != null) {
                final pos = _position?.inSeconds ?? 0;
                final dur = _duration?.inSeconds ?? 0;
                final isEnd = pos == dur;
                if (isEnd) {
                  _initializeAndPlay(_playingIndex);
                } else {
                  controller.play();
                }
              }
            }
            setState(() {});
          },
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 56.0,
            color: Colors.white,
          ),
        ),
        FlatButton(
          onPressed: () async {
            final index = _playingIndex + 1;
            if (index < listVideos.length - 1) {
              _initializeAndPlay(index);
            }
          },
          child: Icon(
            Icons.fast_forward,
            size: 36.0,
            color: Colors.white,
          ),
        ),
      ],
    ));
  }

  String convertTwo(int value) {
    return value < 10 ? "0$value" : "$value";
  }

  Widget _topUI() {
    final noMute = (_controller?.value?.volume ?? 0) > 0;
    final duration = _duration?.inSeconds ?? 0;
    final head = _position?.inSeconds ?? 0;
    final remained = max(0, duration - head);
    final min = convertTwo(remained ~/ 60.0);
    final sec = convertTwo(remained % 60);
    return Row(
      children: <Widget>[
        InkWell(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 100),
            child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                  BoxShadow(
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 4.0,
                      color: Color.fromARGB(50, 0, 0, 0)),
                ]),
                child: Icon(
                  noMute ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                )),
          ),
          onTap: () {
            if (noMute) {
              _controller?.setVolume(0);
            } else {
              _controller?.setVolume(1.0);
            }
            setState(() {});
          },
        ),
        Expanded(
          child: Container(),
        ),
        Text(
          "$min:$sec",
          style: TextStyle(
            color: Colors.white,
            shadows: <Shadow>[
              Shadow(
                offset: Offset(0.0, 1.0),
                blurRadius: 4.0,
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        SizedBox(width: 10)
      ],
    );
  }

  //*******************************
  /*
  Widget followFeed2() {
    return listVideos.isNotEmpty
        ? PageView.builder(
            controller: foryouController,
            scrollDirection: Axis.vertical,
            itemCount: listVideos.length,
            itemBuilder: (context, index) {
              return Stack(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: VideosPlayer(
                      playlistStyle: Style.Style2,
                      maxVideoPlayerHeight:
                          MediaQuery.of(context).size.height - 200,
                      networkVideos: [
                        NetworkVideo(
                            id: listVideos[index].videoId,
                            name: listVideos[index].videoTitle,
                            videoUrl: listVideos[index].mediaUrl,
                            thumbnailUrl: listVideos[index].userPic)
                      ],
                    ),
                  ),
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
  }*/

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

  Widget buildLikeButton(video) {
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
          Flexible(
            child: ListView(
              children: [
                Flexible(
                  child: buildComments(video),
                )
              ],
            ),
          ),
          Align(
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
    bool isNotMe = currentUserId() != video.ownerId;

    if (isNotMe) {
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
    bool isNotMe = currentUserId() != video.ownerId;

    if (isNotMe) {
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

  callList() async {
    listVideos = await VideoService.getVideoList();
    if (listVideos.isNotEmpty) {
      _controllerRec = VideoPlayerController.network(listVideos[0].mediaUrl);
      _controller = VideoPlayerController.network(listVideos[0].mediaUrl)
        ..addListener(() => setState(() {}))
        ..setLooping(true)
        ..initialize().then((_) => _controller.play());
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
}
