import 'package:LIVE365/Settings/setting_screen.dart';
import 'package:LIVE365/components/post_tiles.dart';
import 'package:LIVE365/components/post_view.dart';
import 'package:LIVE365/components/stream_builder_wrapper.dart';
import 'package:LIVE365/components/stream_grid_wrapper.dart';
import 'package:LIVE365/components/video_view.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/post.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/profile/components/profile_pic.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class Body extends StatefulWidget {
  final profileId;

  const Body({Key key, this.profileId}) : super(key: key);
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final auth = FirebaseService();
  User user;
  bool isLoading = false;
  int postCount = 0;
  int followersCount = 0;
  int followingCount = 0;
  bool isToggle = true;
  bool isVideo = false;
  bool isFollowing = false;
  UserModel users;
  UserModel user1;
  final DateTime timestamp = DateTime.now();
  ScrollController controller = ScrollController();

  currentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            toolbarHeight: 4.0,
            collapsedHeight: 5.0,
            expandedHeight: 390.0,
            flexibleSpace: FlexibleSpaceBar(
              background: StreamBuilder(
                stream: usersRef.doc(widget.profileId).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    user1 = UserModel.fromJson(snapshot.data.data());
                    return DisplayUserInfo();
                  }
                  return Container();
                },
              ),
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
                    IconButton(
                        icon: Icon(
                          Icons.video_collection_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            isToggle = false;
                            isVideo = false;
                          });
                        }),
                    buildIcons(),
                  ],
                ),
              ),
              buildPostView()
            ]);
          })),
        ],
      ),
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
              isVideo = false;
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
            isVideo = false;
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
    if (isToggle == true && isVideo == false) {
      return buildGridPost();
    } else if (isToggle == false && isVideo == false) {
      return buildPosts();
    } else if (isToggle == false && isVideo == true) {
      return buildVideos();
    }
  }

  buildVideos() {
    return StreamBuilderWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      text: "No Posts For The Moment",
      stream:
          videoRef.where('ownerId', isEqualTo: widget.profileId).snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        Video video = Video.fromJson(snapshot.data());
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Videos(
            video: video,
          ),
        );
      },
    );
  }

  buildPosts() {
    return StreamBuilderWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      text: "No Posts For The Moment",
      stream: postRef.where('ownerId', isEqualTo: widget.profileId).snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        PostModel posts = PostModel.fromJson(snapshot.data());
        return Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Posts(
            post: posts,
          ),
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
    //if isMe then display "edit profile"
    bool isMe = widget.profileId == firebaseAuth.currentUser.uid;
    if (isMe) {
      return FlatButton(
        child: Text(
          "Change Bio =>",
          style: TextStyle(color: white),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingScreen(
                  users: user1,
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

  Widget DisplayUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: getProportionateScreenHeight(30)),
        Container(
            width: SizeConfig.screenWidth - 10,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: getProportionateScreenWidth(10)),
                  widget.profileId == firebaseAuth.currentUser.uid
                      ? IconButton(
                          icon: Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SettingScreen(
                                    users: user1,
                                  ),
                                ));
                          })
                      : Container(),
                  SizedBox(
                    width: getProportionateScreenWidth(260),
                    height: getProportionateScreenHeight(10),
                  ),
                  widget.profileId == firebaseAuth.currentUser.uid
                      ? IconButton(
                          icon: Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {})
                      : Container(),
                  SizedBox(width: getProportionateScreenWidth(10))
                ],
              ),
            )),
        StreamBuilder(
          stream: usersRef.doc(widget.profileId).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              UserModel user = UserModel.fromJson(snapshot.data.data());
              return Column(
                children: <Widget>[
                  ProfilePic(
                    image: auth.getProfileImage(),
                  ),
                  SizedBox(height: 5),
                  Text("${user.username ?? 'Anonymous'}",
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(22),
                        color: GTextColorWhite,
                        fontFamily: "SFProDisplay-Bold",
                        fontWeight: FontWeight.bold,
                      )),
                  SizedBox(height: 5),
                  Column(
                    children: [
                      Center(
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                            child: Text(
                                "${user.bio.isEmpty ? 'Lorem ipsum, or lipsum as it is sometimes known, graphic or web designs.' : user.bio}",
                                textAlign: TextAlign.center,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                    return buildCount(
                                        "POSTS", docs?.length ?? 0);
                                  } else {
                                    return buildCount("POSTS", 0);
                                  }
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15.0),
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
                                padding: const EdgeInsets.only(bottom: 15.0),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  buildProfileButton(user),
                ],
              );
            }
            return Container();
          },
        ),
      ],
    );
  }
}
