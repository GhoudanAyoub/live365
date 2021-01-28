import 'package:LIVE365/discover/components/mycard.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'file:///C:/Users/ayoub/StudioProjects/live365/lib/discover/components/user_cards.dart';

import '../constants.dart';
import '../utils.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  TextEditingController _searchController = new TextEditingController();
  users user;
  List<users> list = [];
  final auth = FirebaseService();

  @override
  void initState() {
    super.initState();
    list = [];
    DbChangeList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    controller: _searchController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon:
                            Icon(Icons.search, color: GBottomNav, size: 30.0),
                        contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                        hintText: 'Search',
                        hintStyle: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'SFProDisplay-Black'))),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GridView.count(
              crossAxisCount: 2,
              primary: false,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 4.0,
              shrinkWrap: true,
              children: <Widget>[
                ...List.generate(
                  list.length,
                  (index) {
                    return index.isNegative
                        ? Center(child: CircularProgressIndicator())
                        : list[index].name == auth.getCurrentUserName()
                            ? Mycard(
                                id: list[index].id,
                                name: list[index].name,
                                image: list[index].img,
                                cardIndex: 1,
                                status: 'online',
                              )
                            : UserCards(
                                id: list[index].id,
                                name: list[index].name,
                                image: list[index].img,
                                cardIndex: 1,
                                status: 'Away',
                              );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void DbChangeList() {
    FirebaseFirestore.instance
        .collection("Users")
        .orderBy("followers", descending: true)
        .snapshots()
        .transform(Utils.transformer(users.fromJson))
        .listen((result) {
      setState(() {
        list = [];
        user = new users(
            id: auth.getCurrentUID(),
            name: auth.getCurrentUserName(),
            img: auth.getProfileImage());
        list.add(user);
      });
      final userList = result.data;
      if (userList.isEmpty) {
        return Center(
          child: buildText('No User Found'),
        );
      } else {
        for (users u in userList) {
          setState(() {
            list.add(u);
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
}
