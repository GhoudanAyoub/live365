import 'package:LIVE365/Settings/setting_screen.dart';
import 'package:LIVE365/components/post_tiles.dart';
import 'package:LIVE365/components/post_view.dart';
import 'package:LIVE365/components/stream_builder_wrapper.dart';
import 'package:LIVE365/components/stream_grid_wrapper.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/post.dart';
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
        .doc(FirebaseAuth.instance.currentUser.uid)
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
            toolbarHeight: 5.0,
            collapsedHeight: 6.0,
            expandedHeight: 380.0,
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
                    buildIcons(),
                  ],
                ),
              ),
              buildPostView()
            ]);
          })),
          /*
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
          )*/
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
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
      stream: postRef
          .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser.uid)
          .snapshots(),
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
      return Container();
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
                appBgColor,
                GBottomNav,
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

  Widget DisplayUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: getProportionateScreenHeight(30)),
        Container(
            child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: getProportionateScreenWidth(10)),
              IconButton(
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
                  }),
              SizedBox(
                width: getProportionateScreenWidth(260),
                height: getProportionateScreenHeight(10),
              ),
              IconButton(
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  onPressed: () {}),
              SizedBox(width: getProportionateScreenWidth(10)),
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
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser.uid)
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
                                    .doc(FirebaseAuth.instance.currentUser.uid)
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
                                    .doc(FirebaseAuth.instance.currentUser.uid)
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
