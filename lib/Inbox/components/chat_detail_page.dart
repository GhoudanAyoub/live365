import 'package:flutter/material.dart';
import 'package:live365/models/UserMessages.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import '../../theme.dart';
import 'chat_bubble.dart';

class ChatDetailPage extends StatefulWidget {
  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  TextEditingController _sendMessageController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: grey_toWhite.withOpacity(0.2),
        elevation: 0,
        leading: FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: black,
            )),
        title: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(
                          "https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=800&q=60"),
                      fit: BoxFit.cover)),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Tyler Nix",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: white),
                ),
                SizedBox(
                  height: 3,
                ),
                Text(
                  "Active now",
                  style: TextStyle(color: white.withOpacity(0.4), fontSize: 14),
                )
              ],
            )
          ],
        ),
        /*
        //todo : the phone  and  live buttons
        actions: <Widget>[
          Icon(
            LineIcons.phone,
            color: orange,
            size: 32,
          ),
          SizedBox(
            width: 15,
          ),
          Icon(
            LineIcons.video_camera,
            color: orange,
            size: 35,
          ),
          SizedBox(
            width: 8,
          ),
          Container(
            width: 13,
            height: 13,
            decoration: BoxDecoration(
                color: online,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white38)),
          ),
          SizedBox(
            width: 15,
          ),
        ],*/
      ),
      body: Body(),
      bottomSheet: Bottom(),
    );
  }

  Widget Bottom() {
    return Container(
      height: getProportionateScreenHeight(80),
      width: double.infinity,
      decoration: BoxDecoration(color: GBottomNav),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.add_circle,
                    size: 25,
                    color: white,
                  ),
                  SizedBox(
                    width: getProportionateScreenWidth(10),
                  ),
                  Icon(
                    Icons.camera_alt,
                    size: 25,
                    color: white,
                  ),
                  SizedBox(
                    width: getProportionateScreenWidth(10),
                  ),
                  Icon(
                    Icons.photo,
                    size: 25,
                    color: white,
                  ),
                  SizedBox(
                    width: getProportionateScreenWidth(10),
                  ),
                  Container(
                    width: getProportionateScreenWidth(230),
                    height: getProportionateScreenHeight(50),
                    decoration: BoxDecoration(
                        color: white, borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.2),
                      child: buildMsgFormField(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildMsgFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.black),
      controller: _sendMessageController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          return "";
        } else if (value == "fuck you") {
          return "******";
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: textTheme().bodyText2,
        hintStyle: textTheme().bodyText2,
        hintText: "Text",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  Widget Body() {
    return ListView(
      padding: EdgeInsets.only(right: 20, left: 20, top: 20, bottom: 80),
      children: List.generate(messages.length, (index) {
        return ChatBubble(
            isMe: messages[index]['isMe'],
            messageType: messages[index]['messageType'],
            message: messages[index]['message'],
            profileImg: messages[index]['profileImg']);
      }),
    );
  }
}
