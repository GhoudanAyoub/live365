import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<Live> LiveFromJson(String str) =>
    List<Live>.from(json.decode(str).map((x) => Live.fromJson(x)));

String LiveToJson(List<Live> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Live {
  String id;
  String ownerId;
  String username;
  String channelName;
  String hostImage;
  String channelToken;
  String image;
  String views;
  int channelId;
  bool me = false;
  Timestamp startAt;
  Timestamp endAt;

  Live({
    this.id,
    this.ownerId,
    this.username,
    this.channelName,
    this.hostImage,
    this.image,
    this.channelId,
    this.views,
    this.me,
    this.startAt,
    this.endAt,
    this.channelToken,
  });

  static Live fromJson(Map<String, dynamic> json) => Live(
        id: json['id'],
        username: json['username'],
        ownerId: json['ownerId'],
        image: json['image'],
        channelId: json['channelId'],
        channelName: json['channelName'],
        hostImage: json['hostImage'],
        views: json['views'],
        me: json['me'],
        startAt: json['startAt'],
        endAt: json['endAt'],
        channelToken: json['channelToken'],
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['image'] = this.image;
    data['channelId'] = this.channelId;
    data['ownerId'] = this.ownerId;
    data['username'] = this.username;
    data['channelName'] = this.channelName;
    data['hostImage'] = this.hostImage;
    data['views'] = this.views;
    data['me'] = this.me;
    data['startAt'] = this.startAt;
    data['endAt'] = this.endAt;
    data['channelToken'] = this.channelToken;
    return data;
  }
}
