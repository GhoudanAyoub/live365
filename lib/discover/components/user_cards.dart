import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';

class UserCards extends StatelessWidget {
  final String id;
  final String image;
  final String name;
  final String status;
  final int cardIndex;

  const UserCards(
      {Key key, this.id, this.image, this.name, this.status, this.cardIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildCard(name, status, cardIndex);
  }

  Widget _buildCard(name, status, cardIndex) {
    return Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 7.0,
        child: Column(
          children: <Widget>[
            SizedBox(height: 12.0),
            Stack(children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(image), fit: BoxFit.cover)),
              ),
              Container(
                margin: EdgeInsets.only(left: 40.0),
                height: 20.0,
                width: 20.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: status == 'Away' ? Colors.amber : Colors.green,
                    border: Border.all(
                        color: Colors.white,
                        style: BorderStyle.solid,
                        width: 2.0)),
              )
            ]),
            SizedBox(height: 8.0),
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              status,
              style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                  color: Colors.grey),
            ),
            SizedBox(height: 15.0),
            Expanded(
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                        decoration: BoxDecoration(
                          color: status == 'Away' ? Colors.grey : GBottomNav,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10.0),
                              bottomRight: Radius.circular(10.0)),
                        ),
                        width: getProportionateScreenWidth(157.5),
                        child: Center(
                          child: Text(
                            'Request',
                            style: TextStyle(
                                color: Colors.white, fontFamily: 'Quicksand'),
                          ),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
        margin: cardIndex.isEven
            ? EdgeInsets.fromLTRB(10.0, 0.0, 20.0, 10.0)
            : EdgeInsets.fromLTRB(10.0, 0.0, 15.0, 10.0));
  }
}
