import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

List<PostModel> postFromJson(String str) =>
    List<PostModel>.from(json.decode(str).map((x) => PostModel.fromJson(x)));

String postToJson(List<PostModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PostModel {
  String id;
  String postId;
  String ownerId;
  String username;
  String tags;
  String description;
  String mediaUrl;
  // dynamic likesCount;
  // dynamic likes;
  Timestamp timestamp;

  PostModel({
    this.id,
    this.postId,
    this.ownerId,
    this.tags,
    this.description,
    this.mediaUrl,
    // this.likesCount,
    // this.likes,
    this.username,
    this.timestamp,
  });
  PostModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    ownerId = json['ownerId'];
    tags = json['tags'];
    username = json['username'];
    description = json['description'];
    mediaUrl = json['mediaUrl'];
    // likesCount = json['likes'].length ?? 0;
    // likes = json['likes'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postId'] = this.postId;
    data['ownerId'] = this.ownerId;
    data['tags'] = this.tags;
    data['description'] = this.description;
    data['mediaUrl'] = this.mediaUrl;
    // data['likesCount']= this.likesCount;
    // data['likes'] = this.likes;
    data['timestamp'] = this.timestamp;
    data['username'] = this.username;
    return data;
  }
}
