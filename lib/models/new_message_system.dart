import 'package:cloud_firestore/cloud_firestore.dart';

import 'enum/message_type.dart';

class Message {
  String msgId;
  String content;
  String senderUid;
  MessageType type;
  Timestamp time;

  Message({this.msgId, this.content, this.senderUid, this.type, this.time});

  Message.fromJson(Map<String, dynamic> json) {
    msgId = json['msgId'];
    content = json['content'];
    senderUid = json['senderUid'];
    if (json['type'] == 'text') {
      type = MessageType.TEXT;
    } else {
      type = MessageType.IMAGE;
    }
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['content'] = this.content;
    data['senderUid'] = this.senderUid;
    if (this.type == MessageType.TEXT) {
      data['type'] = 'text';
    } else {
      data['type'] = 'image';
    }
    data['time'] = this.time;
    data['msgId'] = this.msgId;
    return data;
  }
}
