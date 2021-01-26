import 'package:LIVE365/models/UserMessages.dart';
import 'package:flutter/material.dart';

import 'file:///C:/Users/ayoub/StudioProjects/live365/lib/discover/components/user_cards.dart';

import '../constants.dart';

class DiscoverScreen extends StatelessWidget {
  TextEditingController _searchController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 5,
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
                  userMessages.length,
                  (index) {
                    return index.isNegative
                        ? Center(child: CircularProgressIndicator())
                        : UserCards(
                            id: userMessages[index]["id"].toString(),
                            name: userMessages[index]["name"],
                            image: userMessages[index]["img"],
                            cardIndex: 1,
                            status: userMessages[index]["status"],
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
}
