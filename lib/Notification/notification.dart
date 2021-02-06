import 'package:LIVE365/Inbox/components/recent_chats.dart';
import 'package:LIVE365/components/notification_items.dart';
import 'package:LIVE365/models/notification.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff_navigation_bar/ff_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'components/notification_stream_wrapper.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  int pageIndex = 0;
  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  final tab = new TabBar(tabs: <Tab>[
    new Tab(icon: new Icon(Icons.chat_outlined)),
    new Tab(icon: new Icon(Icons.mark_chat_unread_outlined)),
  ]);

  Widget getBody2() {
    return Scaffold(
        appBar: new PreferredSize(
      preferredSize: tab.preferredSize,
      child: new Card(
        elevation: 26.0,
        color: Theme.of(context).primaryColor,
        child: tab,
      ),
    ));
  }

  List<Widget> containers = [
    Scaffold(
      body: ListView(
        children: [
          ActivityStreamWrapper(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              stream: notificationRef
                  .doc(firebaseAuth.currentUser.uid)
                  .collection('notifications')
                  .orderBy('timestamp', descending: true)
                  .limit(20)
                  .snapshots(),
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (_, DocumentSnapshot snapshot) {
                ActivityModel activities =
                    ActivityModel.fromJson(snapshot.data());
                return ActivityItems(
                  activity: activities,
                );
              })
        ],
      ),
    ),
    Chats(),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: 'Notification',
              ),
              Tab(
                text: 'Chat',
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

  deleteAllItems() async {
//delete all notifications associated with the authenticated user
    QuerySnapshot notificationsSnap = await notificationRef
        .doc(firebaseAuth.currentUser.uid)
        .collection('notifications')
        .get();
    notificationsSnap.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Widget Footer2() {
    return FFNavigationBar(
      theme: FFNavigationBarTheme(
        barBackgroundColor: GBottomNav,
        selectedItemBorderColor: GBottomNav,
        selectedItemBackgroundColor: Colors.orange,
        selectedItemIconColor: Colors.white,
        selectedItemLabelColor: Colors.white,
      ),
      selectedIndex: pageIndex,
      onSelectTab: (index) {
        setState(() {
          pageIndex = index;
        });
      },
      items: [
        FFNavigationBarItem(
          iconData: CupertinoIcons.chat_bubble_2_fill,
          label: 'Notification',
        ),
        FFNavigationBarItem(
          iconData: CupertinoIcons.chat_bubble_text,
          label: 'Chat',
        ),
      ],
    );
  }
}
