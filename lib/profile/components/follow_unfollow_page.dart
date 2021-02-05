import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'body.dart';

class FollowUnfollowPage extends StatefulWidget {
  final profileId;

  const FollowUnfollowPage({Key key, this.profileId}) : super(key: key);

  @override
  _FollowUnfollowPageState createState() => _FollowUnfollowPageState();
}

class _FollowUnfollowPageState extends State<FollowUnfollowPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;
  String id;

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  List<Widget> containers = [
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.blue,
    ),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.profileId;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Followers',
              ),
              Tab(
                text: 'Following',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: containers,
        ),
      ),
    );
  }

  buildUsers() {
    if (!loading) {
      if (filteredUsers.isEmpty) {
        return Center(
          child: Text("No User Found",
              style: TextStyle(fontWeight: FontWeight.bold)),
        );
      } else {
        return ListView.builder(
          itemCount: filteredUsers.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            DocumentSnapshot doc = filteredUsers[index];
            UserModel user = UserModel.fromJson(doc.data());
            return Column(
              children: [
                ListTile(
                  onTap: () => showProfile(context, profileId: user?.id),
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.0),
                  leading: CircleAvatar(
                    radius: 35.0,
                    backgroundImage: NetworkImage(user?.photoUrl),
                  ),
                  title: Text(user?.username,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(user?.email,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                Divider(),
              ],
            );
          },
        );
      }
    } else {
      return Center(
        child: circularProgress(context),
      );
    }
  }

  getUsers(uid) async {
    DocumentSnapshot snap = await usersRef.doc(uid).get();

    setState(() {
      loading = false;
    });
  }

  getFollowers() {
    return StreamBuilder(
      stream: followersRef
          .doc(widget.profileId)
          .collection('userFollowers')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          QuerySnapshot snap = snapshot.data;
          List<DocumentSnapshot> docs = snap.docs;
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  getFollowings() {
    return StreamBuilder(
      stream: followingRef
          .doc(widget.profileId)
          .collection('userFollowing')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          QuerySnapshot snap = snapshot.data;
          List<DocumentSnapshot> docs = snap.docs;
          return Container();
        } else {
          return Container();
        }
      },
    );
  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Body(profileId: profileId),
        ));
  }
}
