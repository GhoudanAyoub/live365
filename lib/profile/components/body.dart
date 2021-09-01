import 'package:LIVE365/Inbox/components/conversation.dart';
import 'package:LIVE365/Settings/setting_screen.dart';
import 'package:LIVE365/components/post_tiles.dart';
import 'package:LIVE365/components/post_view.dart';
import 'package:LIVE365/components/stream_builder_wrapper.dart';
import 'package:LIVE365/components/stream_grid_wrapper.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/post.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/profile/components/play_page.dart';
import 'package:LIVE365/profile/components/profile_pic.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import 'edit_profile.dart';
import 'follow_unfollow_page.dart';

class Body extends StatefulWidget {
  final profileId;

  const Body({Key key, this.profileId}) : super(key: key);
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final auth = FirebaseService();
  UserModel user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isToggle = true;
  bool isFollowing = false;
  UserModel users, users2;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();

  List<Video> listvideo;
  currentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    GetVideoList(widget.profileId);
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        toolbarHeight: 30,
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: true,
            toolbarHeight: 1.0,
            collapsedHeight: 1.0,
            expandedHeight: 330.0,
            flexibleSpace: FlexibleSpaceBar(
              background: displayUserInfo(),
            ),
          ),
          SliverList(delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
            if (index > 0) return null;
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      'All Posts',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    Spacer(),
                    StreamBuilder(
                      stream: usersRef.doc(widget.profileId).snapshots(),
                      builder:
                          (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasData) {
                          users2 = UserModel.fromJson(snapshot.data.data());
                          return IconButton(
                              icon: Icon(
                                Icons.video_collection_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayPage(
                                        clips: listvideo,
                                        user: users2,
                                      ),
                                    ));
                              });
                        }
                        return Container();
                      },
                    ),
                    buildIcons(),
                  ],
                ),
              ),
              buildPostView(),
            ]);
          })),
        ],
      ),
    );
  }

  Widget displayUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder(
          stream: usersRef.doc(widget.profileId).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              user = UserModel.fromJson(snapshot.data.data());
              return Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      firebaseAuth.currentUser != null
                          ? widget.profileId == firebaseAuth.currentUser.uid
                              ? IconButton(
                                  icon: Icon(
                                    CupertinoIcons.text_justify,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SettingScreen(
                                            users: user,
                                          ),
                                        ));
                                  })
                              : IconButton(
                                  icon: Icon(
                                    Icons.list,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    reportSystem();
                                  })
                          : Container(
                              height: 0,
                            )
                    ],
                  ),
                  ProfilePic(
                    image: firebaseAuth.currentUser != null &&
                            firebaseAuth.currentUser.uid == user.id
                        ? auth.getProfileImage()
                        : user.photoUrl,
                  ),
                  SizedBox(height: 5),
                  Column(
                    children: [
                      Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Text("${user.username ?? 'Anonymous'}",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: getProportionateScreenWidth(22),
                                  color: GTextColorWhite,
                                  fontFamily: "SFProDisplay-Bold",
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Column(
                    children: [
                      Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            width: 300.0,
                            child: Text(
                                "${user.bio.isEmpty ? 'Everyday LIVE365' : user.bio}",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: getProportionateScreenWidth(12),
                                  color: GTextColorWhite,
                                  fontFamily: "SFProDisplay-Light",
                                  fontWeight: FontWeight.normal,
                                )),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: 60.0,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: FlatButton(
                          padding: EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Color(0xFFF5F6F9),
                          onPressed: () {},
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FollowUnfollowPage(
                                          profileId: widget.profileId),
                                    ));
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  StreamBuilder(
                                    stream: postRef
                                        .where('ownerId',
                                            isEqualTo: widget.profileId)
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot snap = snapshot.data;
                                        List<DocumentSnapshot> docs = snap.docs;
                                        return StreamBuilder(
                                          stream: videoRef
                                              .where('ownerId',
                                                  isEqualTo: widget.profileId)
                                              .snapshots(),
                                          builder: (context,
                                              AsyncSnapshot<QuerySnapshot>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              QuerySnapshot snap =
                                                  snapshot.data;
                                              List<DocumentSnapshot> docs1 =
                                                  snap.docs;
                                              return buildCount(
                                                  "POSTS",
                                                  docs.length + docs1?.length ??
                                                      0);
                                            } else {
                                              return buildCount("POSTS", 0);
                                            }
                                          },
                                        );
                                      } else {
                                        return buildCount("POSTS", 0);
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 15.0),
                                    child: Container(
                                      height: 50.0,
                                      width: 0.3,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  StreamBuilder(
                                    stream: followersRef
                                        .doc(widget.profileId)
                                        .collection('userFollowers')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot snap = snapshot.data;
                                        List<DocumentSnapshot> docs = snap.docs;
                                        return buildCount(
                                            "FOLLOWERS", docs?.length ?? 0);
                                      } else {
                                        return buildCount("FOLLOWERS", 0);
                                      }
                                    },
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 15.0),
                                    child: Container(
                                      height: 50.0,
                                      width: 0.3,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  StreamBuilder(
                                    stream: followingRef
                                        .doc(widget.profileId)
                                        .collection('userFollowing')
                                        .snapshots(),
                                    builder: (context,
                                        AsyncSnapshot<QuerySnapshot> snapshot) {
                                      if (snapshot.hasData) {
                                        QuerySnapshot snap = snapshot.data;
                                        List<DocumentSnapshot> docs = snap.docs;
                                        return buildCount(
                                            "FOLLOWING", docs?.length ?? 0);
                                      } else {
                                        return buildCount("FOLLOWING", 0);
                                      }
                                    },
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  firebaseAuth.currentUser != null
                      ? buildProfileButton(user)
                      : Container(
                          height: 0,
                        ),
                ],
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );

  buildIcons() {
    if (isToggle) {
      return IconButton(
          icon: Icon(
            Icons.list,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              isToggle = false;
            });
          });
    } else if (isToggle == false) {
      return IconButton(
        icon: Icon(
          Icons.grid_on,
          color: Colors.white,
        ),
        onPressed: () {
          setState(() {
            isToggle = true;
          });
        },
      );
    }
  }

  buildCount(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w900,
              fontFamily: 'Ubuntu-Regular'),
        ),
        SizedBox(height: 3.0),
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              fontFamily: 'Ubuntu-Regular'),
        )
      ],
    );
  }

  buildPostView() {
    if (isToggle == true) {
      return buildGridPost();
    } else if (isToggle == false) {
      return buildPosts();
    }
  }

  buildPosts() {
    return StreamBuilderWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      text: "No Posts For The Moment",
      stream: postRef.where('ownerId', isEqualTo: widget.profileId).snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        PostModel posts = PostModel.fromJson(snapshot.data());
        return Posts(
          post: posts,
        );
      },
    );
  }

  buildGridPost() {
    return StreamGridWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      stream: postRef.where('ownerId', isEqualTo: widget.profileId).snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        PostModel posts = PostModel.fromJson(snapshot.data());
        return PostTile(
          post: posts,
        );
      },
    );
  }

  buildProfileButton(user) {
    bool isMe = false;
    if (firebaseAuth.currentUser != null)
      isMe = widget.profileId == firebaseAuth.currentUser.uid;
    if (isMe) {
      return buildButton(
        text: "Change Bio",
        function: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfile(
                  user: user,
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
        .doc(widget.profileId)
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
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    //remove from notifications feeds
    notificationRef
        .doc(widget.profileId)
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
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId())
        .set({});
    //updates the following collection of the currentUser
    followingRef
        .doc(currentUserId())
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});
    //update the notification feeds
    notificationRef
        .doc(widget.profileId)
        .collection('notifications')
        .doc(currentUserId())
        .set({
      "type": "follow",
      "ownerId": widget.profileId,
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
                Colors.white,
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  reportSystem() {
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
                            reportButton();
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
                      IconButton(
                          icon: Icon(
                            Icons.email_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Conversation(
                                    userId: widget.profileId,
                                    chatId: 'newChat',
                                  ),
                                ));
                          }),
                      Center(
                          child: Text('Send',
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

  reportButton() {
    return showModalBottomSheet(
        backgroundColor: GBottomNav,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: .4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Center(
                    child: Text(
                      'Select a reason',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Report account',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      onTap: () {
                        Navigator.pop(context);
                        reportAccountButton();
                      },
                    ),
                    ListTile(
                      title: Text('Report content',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      onTap: () {
                        report('Content report');
                      },
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  reportAccountButton() {
    return showModalBottomSheet(
        backgroundColor: GBottomNav,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 0.75,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Center(
                    child: Text(
                      'Select a reason',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                        title: Text('Posting Inappropriate Content',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () {
                          Navigator.pop(context);
                          reportPostingButton();
                        }),
                    ListTile(
                      title: Text('Inappropriate Profile Info',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      onTap: () {
                        report('Inappropriate Profile Info');
                      },
                    ),
                    ListTile(
                        title: Text('Intellectual property infringement',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () {
                          report('Intellectual property infringement');
                        }),
                    ListTile(
                        title: Text('Other',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () {
                          report('Other report');
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  reportPostingButton() {
    return showModalBottomSheet(
        backgroundColor: GBottomNav,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext context) {
          return FractionallySizedBox(
            heightFactor: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Center(
                    child: Text(
                      'Select a reason',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
                Divider(
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                        title: Text('Pornography and nudity',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () {
                          report('Pornography and nudity');
                        }),
                    ListTile(
                      title: Text('Illegal activities and regulated goods',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      onTap: () {
                        report('Illegal activities and regulated goods');
                      },
                    ),
                    ListTile(
                        title: Text('Hate speech',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () {
                          report('Hate speech');
                        }),
                    ListTile(
                        title: Text('Violent and graphic content',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () {
                          report('Violent and graphic content');
                        }),
                    ListTile(
                        title: Text('Suicide, self-harm, and dangerous acts',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        onTap: () {
                          report('Suicide, self-harm, and dangerous acts');
                        }),
                  ],
                )
              ],
            ),
          );
        });
  }

  report(String type) {
    Navigator.pop(context);
    reportRef.doc(widget.profileId).set({
      'accountId': widget.profileId,
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

  static Future<List<Video>> getVideoList(profileId) async {
    var data = await videoRef.get();
    var videoList = <Video>[];
    data.docs.forEach((element) {
      Video video = Video.fromJson(element.data());
      if (video.ownerId == profileId) videoList.add(video);
    });
    return videoList;
  }

  Future<void> GetVideoList(profileId) async {
    listvideo = await getVideoList(profileId);
  }
}
