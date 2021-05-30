import 'package:LIVE365/components/stream_comments_wrapper.dart';
import 'package:LIVE365/components/view_image.dart';
import 'package:LIVE365/home/components/tiktokscafold.dart';
import 'package:LIVE365/home/components/tiktokvideopage.dart';
import 'package:LIVE365/home/components/tiktokvideoplayer.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/post_comments.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/style/style.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:safemap/safemap.dart';
import 'package:screen/screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class PlayPage extends StatefulWidget {
  PlayPage({Key key, @required this.clips, this.user}) : super(key: key);

  final List<Video> clips;
  final UserModel user;

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  VideoPlayerController _controller;
  PageController _pageController = PageController();
  VideoListController _videoListController = VideoListController();
  TikTokScaffoldController tkController = TikTokScaffoldController();
  AnimationController animationController;
  Map<int, bool> favoriteMap = {};

  TextEditingController commentsTEC = TextEditingController();
  UserModel user;
  List<Video> get listVideos {
    return widget.clips;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) {
      _videoListController.currentPlayer.pause();
    }
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _videoListController.currentPlayer.pause();
    Screen.keepOn(false);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;

    double a = MediaQuery.of(context).size.aspectRatio;
    bool hasBottomPadding = a < 0.55;

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child:
              Text("${widget.user.username} Post ${listVideos.length} Videos"),
        ),
      ),
      body: widget.clips != null
          ? TikTokScaffold(
              controller: tkController,
              enableGesture: true,
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
                          panelBuilder: (_, __, ___, ____, _____) =>
                              Container(),
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
            )
          : Container(
              child: Center(
                child:
                    Text("${widget.user.username} Didn't Post Any Video yet"),
              ),
            ),
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
                      child: ListView(
                        children: <Widget>[
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

  Widget buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Center(
        child: Text(
          '$count likes',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 10.0, color: Colors.white),
        ),
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

  Widget buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Center(
        child: Text(
          '${count}comm',
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
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
          heightFactor: SizeConfig.screenHeight < 500
              ? 0.5
              : getProportionateScreenHeight(.3),
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
                  firebaseAuth.currentUser.uid == widget.user.id
                      ? Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                                deleteVideo(context, video.id);
                              },
                              icon: Icon(CupertinoIcons.delete,
                                  size: 25, color: Colors.white),
                            ),
                            Center(
                                child: Text('Delete',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white))),
                          ],
                        )
                      : Container(
                          height: 0,
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

  deleteVideo(BuildContext parentContext, videoid) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: GBottomNav,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deleteVideoList(videoid);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
  }

  void deleteVideoList(videoid) async {
    videoRef
        .doc(videoid)
        .delete()
        .then((value) => print("Video Delete Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }
}
