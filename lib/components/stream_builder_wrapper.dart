import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

class StreamBuilderWrapper extends StatelessWidget {
  final Stream<dynamic> stream;
  final ItemBuilder<DocumentSnapshot> itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics physics;
  final EdgeInsets padding;
  final String text;

  const StreamBuilderWrapper({
    Key key,
    @required this.stream,
    @required this.itemBuilder,
    this.text,
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
          var list = snapshot.data.docs.toList();
          return list.length == 0
              ? Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(
                    child: Container(
                      child: Text(
                        text,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        padding: padding,
                        scrollDirection: scrollDirection,
                        itemCount: list.length,
                        shrinkWrap: shrinkWrap,
                        physics: physics,
                        itemBuilder: (BuildContext context, int index) {
                          return itemBuilder(context, list[index]);
                        },
                      )
                    ],
                  ),
                );
        } else {
          return Center(
            child: Lottie.asset('assets/lotties/loading-animation.json'),
          );
        }
      },
    );
  }
}
