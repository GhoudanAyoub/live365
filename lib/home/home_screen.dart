import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:live365/components/cam_icon.dart';
import 'package:live365/profile/profile_screen.dart';

import '../constants.dart';
import 'components/body.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  @override
  _State createState() => _State();
}

class _State extends State<HomeScreen> {
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: getFooter(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: <Widget>[
        Body(),
        Center(
          child: Text(
            "Discover",
            style: TextStyle(
                color: white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            "Upload",
            style: TextStyle(
                color: white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
          child: Text(
            "Messaging",
            style: TextStyle(
                color: white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        ProfileScreen(),
      ],
    );
  }

  Widget getFooter() {
    List bottomItems = [
      {"icon": "assets/icons/Phone.svg", "label": "Home", "isIcon": true},
      {
        "icon": "assets/icons/Search Icon.svg",
        "label": "Search",
        "isIcon": true
      },
      {"icon": "", "label": "", "isIcon": false},
      {
        "icon": "assets/icons/Chat bubble Icon.svg",
        "label": "Inbox",
        "isIcon": true
      },
      {"icon": "assets/icons/User Icon.svg", "label": "Me", "isIcon": true}
    ];
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(color: GBottomNav),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(bottomItems.length, (index) {
            return bottomItems[index]['isIcon']
                ? InkWell(
                    onTap: () {
                      selectedTab(index);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        IconButton(
                          icon: SvgPicture.asset(
                            bottomItems[index]['icon'],
                            color: white,
                          ),
                        ),
                        Center(
                          child: Text(
                            bottomItems[index]['label'],
                            style: TextStyle(
                                color: white,
                                fontFamily: "SFProDisplay-Regular",
                                fontSize: 10),
                          ),
                        )
                      ],
                    ),
                  )
                : InkWell(
                    onTap: () {
                      selectedTab(index);
                    },
                    child: CamIcon());
          }),
        ),
      ),
    );
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
