import 'dart:async';

import 'package:LIVE365/Inbox/components/conversation.dart';
import 'package:LIVE365/SizeConfig.dart';
import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/models/FakeRepository.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/profile/components/body.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../constants.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  User user;
  TextEditingController searchController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> users = [];
  List<DocumentSnapshot> filteredUsers = [];
  bool loading = true;

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  getUsers() async {
    QuerySnapshot snap = await usersRef.get();
    List<DocumentSnapshot> doc = snap.docs;
    users = doc;
    filteredUsers = doc;
    setState(() {
      loading = false;
    });
  }

  search(String query) {
    if (query == "") {
      filteredUsers = users;
    } else {
      List userSearch = users.where((userSnap) {
        Map user = userSnap.data();
        String userName = user['username'];
        return userName.toLowerCase().contains(query.toLowerCase());
      }).toList();

      setState(() {
        filteredUsers = userSearch;
      });
    }
  }

  removeFromList(index) {
    filteredUsers.removeAt(index);
  }

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [getAllUsers()],
    );
  }

  Widget getVideosAndUsers() {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        return Scaffold(
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
            child: Container(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(50.0),
                      child: TextFormField(
                          cursorColor: black,
                          controller: searchController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search,
                                  color: GBottomNav, size: 30.0),
                              contentPadding:
                                  EdgeInsets.only(left: 15.0, top: 15.0),
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'SFProDisplay-Black'))),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _buildTrendHeading(sizingInformation,
                      title: "PkCricketFever",
                      range: "2.7b",
                      descrition: "Trending Hashtag"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildListView(),
                  SizedBox(height: 20),
                  _buildTrendHeading(sizingInformation,
                      title: "SportLover",
                      range: "13.7b",
                      descrition: "Trending Hashtag"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildListView(),
                  SizedBox(height: 20),
                  _buildTrendHeading(sizingInformation,
                      title: "myOutFit",
                      range: "7.7b",
                      descrition: "Trending Hashtag"),
                  SizedBox(
                    height: 10,
                  ),
                  _buildListView(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getAllUsers() {
    return ResponsiveBuilder(builder: (context, sizingInformation) {
      return Scaffold(
          body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
        child: Container(
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0),
                child: Material(
                  elevation: 5.0,
                  borderRadius: BorderRadius.circular(50.0),
                  child: TextFormField(
                      cursorColor: black,
                      controller: searchController,
                      onChanged: (query) {
                        search(query);
                      },
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon:
                              Icon(Icons.search, color: GBottomNav, size: 30.0),
                          contentPadding:
                              EdgeInsets.only(left: 15.0, top: 15.0),
                          hintText: 'Search',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'SFProDisplay-Black'))),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              buildUsers()
            ],
          ),
        ),
      ));
    });
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
            if (doc.id == currentUserId()) {
              Timer(Duration(milliseconds: 50), () {
                setState(() {
                  removeFromList(index);
                });
              });
            }
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
                  trailing: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Conversation(
                              userId: doc.id,
                              chatId: 'newChat',
                            ),
                          ));
                    },
                    child: Icon(CupertinoIcons.chat_bubble_fill,
                        color: Colors.white),
                  ),
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

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Body(profileId: profileId),
        ));
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );

  Container _buildListView() {
    return Container(
      height: 180,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: FakeRepository.assetData.length,
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                child: Image.asset(FakeRepository.assetData[index]),
              ),
            );
          }),
    );
  }

  Container _buildTrendHeading(SizingInformation sizingInformation,
      {String title, String descrition, String range}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: getProportionateScreenWidth(30),
            height: getProportionateScreenHeight(40),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.all(Radius.circular(50))),
            child: Text(
              "#",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: sizingInformation.localWidgetSize.width * 0.80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(descrition,
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
