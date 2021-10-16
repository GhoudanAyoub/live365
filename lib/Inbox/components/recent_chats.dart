import 'package:LIVE365/components/chat_item.dart';
import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/models/new_message_system.dart';
import 'package:LIVE365/profile/components/user_view_model.dart';
import 'package:LIVE365/services/chat_service.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';

class Chats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UserViewModel viewModel =
        Provider.of<UserViewModel>(context, listen: false);
    viewModel.setUser();
    return Scaffold(
      body: StreamBuilder(
          stream: userChatsStream('${viewModel.user.uid ?? ""}'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List chatList = snapshot.data.documents;
              if (chatList.isNotEmpty) {
                return ListView.separated(
                  itemCount: chatList.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot chatListSnapshot = chatList[index];
                    return StreamBuilder(
                      stream: messageListStream(chatListSnapshot.id),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List messages = snapshot.data.documents;
                          Message message =
                              Message.fromJson(messages.first.data());
                          List users = chatListSnapshot.data()['users'];
                          users.remove('${viewModel.user?.uid ?? ""}');
                          String recipient = users[0];
                          return GestureDetector(
                            child: ChatItem(
                              userId: recipient,
                              messageCount: messages?.length,
                              msg: message?.content,
                              time: message?.time,
                              chatId: chatListSnapshot.id,
                              type: message?.type,
                              currentUserId: viewModel.user?.uid ?? "",
                            ),
                            onLongPress: () {
                              deleteConversation(context, chatListSnapshot.id);
                            },
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        height: 0.5,
                        width: MediaQuery.of(context).size.width / 1.3,
                        child: Divider(),
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text('No Chats'));
              }
            } else {
              return Center(
                child: circularProgress(context),
              );
            }
          }),
    );
  }

  deleteConversation(BuildContext parentContext, chatId) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: GBottomNav,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  ChatService().deleteConversation(chatId);
                },
                child: Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
  }

  Stream<QuerySnapshot> userChatsStream(String uid) {
    return chatRef.where('users', arrayContains: '$uid').snapshots();
  }

  Stream<QuerySnapshot> messageListStream(String documentId) {
    return chatRef.doc(documentId).collection('messages').snapshots();
  }
}
