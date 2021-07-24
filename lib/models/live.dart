import 'package:cloud_firestore/cloud_firestore.dart';

class Live {
  String id;
  String ownerId;
  String username;
  String channelName;
  String hostImage;
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
      );
}
