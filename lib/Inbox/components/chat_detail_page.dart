import 'package:LIVE365/components/IconBtnWithCounter.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/models/message.dart';
import 'package:LIVE365/models/message_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import '../../theme.dart';
import 'chat_bubble.dart';

class ChatDetailPage extends StatelessWidget {
  TextEditingController _sendMessageController = new TextEditingController();
  final MessageList Messagelist;

  ChatDetailPage({Key key, this.Messagelist}) : super(key: key);
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
                      image: NetworkImage(Messagelist.img), fit: BoxFit.cover)),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  Messagelist.name,
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
      body: Messages(),
      bottomSheet: newshit(),
    );
  }

  void sendMessage() async {
    await FirebaseService.uploadMessage(FirebaseAuth.instance.currentUser.uid,
        Messagelist.id, _sendMessageController.text);
    _sendMessageController.clear();
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
                    width: getProportionateScreenWidth(170),
                    decoration: BoxDecoration(
                        color: white, borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 0.2),
                      child: buildMsg2FormField(),
                    ),
                  ),
                  SizedBox(
                    width: getProportionateScreenWidth(10),
                  ),
                  IconBtnWithCounter(
                    svgSrc: "assets/icons/Chat bubble Icon.svg",
                    numOfitem: 0,
                    press: _sendMessageController.text.trim().isEmpty
                        ? null
                        : sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget newshit() => Container(
        color: GBottomNav,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _sendMessageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                  labelText: 'Type your message',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 0),
                    gapPadding: 10,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
            IconButton(
              padding: EdgeInsets.all(8),
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ],
        ),
      );
  Widget buildMsg2FormField() {
    return Expanded(
      child: TextField(
        style: TextStyle(color: Colors.black),
        controller: _sendMessageController,
        textCapitalization: TextCapitalization.sentences,
        autocorrect: true,
        enableSuggestions: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          hintText: "Text",
          border: OutlineInputBorder(
            borderSide: BorderSide(width: 0),
            gapPadding: 10,
            borderRadius: BorderRadius.circular(25),
          ),
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

  Widget Messages() => StreamBuilder<List<messages>>(
        stream: FirebaseService.getMessages(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return buildText('Something Went Wrong Try later');
              } else {
                final messages = snapshot.data;

                return messages.isEmpty
                    ? buildText('Say Hi..')
                    : ListView(
                        padding: EdgeInsets.only(
                            right: 20, left: 20, top: 20, bottom: 80),
                        children: List.generate(messages.length, (index) {
                          final message = messages[index];
                          if (message.receiver !=
                              FirebaseAuth.instance.currentUser.uid)
                            buildText('Say Hi..');
                          return ChatBubble(
                              isMe: true,
                              message: message.message,
                              profileImg: message.urlAvatar);
                        }),
                      );
                /*ListView.builder(
                        physics: BouncingScrollPhysics(),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];

                          return MessageWidget(
                            message: message,
                            isMe: message.idUser == myId,
                          );
                        },
                      );*/
              }
          }
        },
      );
  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 24),
        ),
      );
}
