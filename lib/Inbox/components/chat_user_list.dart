import 'package:LIVE365/models/UserMessages.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import 'chat_detail_page.dart';

class ChatUserList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: List.generate(userMessages.length, (index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => ChatDetailPage()));
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
                        userMessages[index]['live']
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
                                                userMessages[index]['img']),
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
                                            userMessages[index]['img']),
                                        fit: BoxFit.cover)),
                              ),
                        userMessages[index]['online']
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
                        userMessages[index]['name'],
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 135,
                        child: Text(
                          userMessages[index]['message'] +
                              " - " +
                              userMessages[index]['created_at'],
                          style: TextStyle(
                              fontSize: 15, color: black.withOpacity(0.8)),
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
    );
  }
}
