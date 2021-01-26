import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/message_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'components/chat_detail_page.dart';
import 'components/header_inbox_page.dart';

class Inbox extends StatelessWidget {
  TextEditingController _searchController = new TextEditingController();
  final auth = FirebaseService();
  var fireStore = FirebaseFirestore.instance;
  List ListUserMessage = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(context),
    );
  }

  Widget getBody(BuildContext context) {
    return SafeArea(
        child: ListView(
      padding: EdgeInsets.only(left: 20, right: 20, top: 15),
      children: <Widget>[
        FutureBuilder(
          future: auth.getCurrentUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return DisplayUserInformation(context, snapshot);
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
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
                        color: Colors.grey, fontFamily: 'SFProDisplay-Black'))),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        StreamBuilder<List<MessageList>>(
          stream: FirebaseService.getUsers(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return buildText('Something Went Wrong Try later');
                } else {
                  final MessageList = snapshot.data;

                  if (MessageList.isEmpty) {
                    return buildText('No Message Found');
                  } else
                    return Column(
                      children: [DisplayUsersMessage(context, MessageList)],
                    );
                }
            }
          },
        ),
        /*
        StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("Message")
              .doc(FirebaseAuth.instance.currentUser.displayName)
              .collection("users")
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return DisplayUsersMessage(context, snapshot);
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),

         */
      ],
    ));
  }

  Widget DisplayUsersMessage(context, MessageList) {
    /*
    ListUserMessage.add(MessageList(m["id"], m['name'], m['img'], m['online'],
        m['live'], m['message'], m['created_at']));*/

    return Column(
      children: <Widget>[
        Column(
          children: List.generate(MessageList.length, (index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ChatDetailPage(
                              Messagelist: MessageList[index],
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 75,
                      height: 75,
                      child: Stack(
                        children: <Widget>[
                          MessageList[index].online
                              ? Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: red, width: 3)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Container(
                                      width: 75,
                                      height: 75,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: NetworkImage(
                                                  MessageList[index].img),
                                              fit: BoxFit.cover)),
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              MessageList[index].img),
                                          fit: BoxFit.cover)),
                                ),
                          MessageList[index].online
                              ? Positioned(
                                  top: 48,
                                  left: 52,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                        color: online,
                                        shape: BoxShape.circle,
                                        border:
                                            Border.all(color: white, width: 3)),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          MessageList[index].name,
                          style: TextStyle(
                              color: white,
                              fontSize: 17,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 135,
                          child: Text(
                            MessageList[index].message == null
                                ? ""
                                : MessageList[index].message +
                                    " - " +
                                    MessageList[index].created_at.toString(),
                            style: TextStyle(
                                fontSize: 15,
                                color: grey_toWhite.withOpacity(0.8)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          }),
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
  Widget DisplayUserInformation(BuildContext context, AsyncSnapshot snapshot) {
    final authData = snapshot.data;
    return Column(
      children: <Widget>[
        InboxHeader(
          image: auth.getProfileImage(),
        ),
      ],
    );
  }
}
