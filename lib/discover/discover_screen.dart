import 'package:LIVE365/discover/components/mycard.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/FakeRepository.dart';
import 'package:LIVE365/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

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
                          controller: _searchController,
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

  void DbChangeList() {
    FirebaseFirestore.instance
        .collection("Users")
        .snapshots()
        .transform(Utils.transformer(users.fromJson))
        .listen((result) {
      final liveList = result;
      if (liveList.isEmpty) {
        return Center(
          child: buildText('No User Found'),
        );
      } else {
        for (users u in liveList) {
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
            width: 40,
            height: 40,
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

  void UserList() {
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
                : Mycard(
                    id: list[index].id,
                    name: list[index].name,
                    image: list[index].img,
                    cardIndex: 1,
                    status: list[index].status,
                  );
          },
        ),
      ],
    );
  }
}
