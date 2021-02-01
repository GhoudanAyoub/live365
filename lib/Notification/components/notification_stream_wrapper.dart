import 'package:LIVE365/SizeConfig.dart';
import 'package:LIVE365/components/indicators.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

class ActivityStreamWrapper extends StatelessWidget {
  final Stream<dynamic> stream;
  final ItemBuilder<DocumentSnapshot> itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsets padding;

  const ActivityStreamWrapper({
    Key key,
    @required this.stream,
    @required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data.documents.toList();
          return list.length == 0
              ? Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 250.0),
                      child: Center(
                        child: Column(
                          children: [
                            IconButton(
                                icon: SvgPicture.asset(
                              'assets/icons/Chat bubble Icon.svg',
                              color: Colors.white,
                              height: getProportionateScreenHeight(50),
                              width: getProportionateScreenWidth(50),
                            )),
                            buildText('All activity'),
                            Text(
                              "Notifications  about your account will appear here",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: "SFProDisplay-Regular",
                                  color: Colors.grey[400]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: padding,
                  scrollDirection: scrollDirection,
                  itemCount: list.length,
                  shrinkWrap: shrinkWrap,
                  physics: physics,
                  itemBuilder: (BuildContext context, int index) {
                    return itemBuilder(context, list[index]);
                  },
                );
        } else {
          return circularProgress(context);
        }
      },
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(
              fontSize: 24,
              fontFamily: "SFProDisplay-Regular",
              color: Colors.white),
        ),
      );
}
