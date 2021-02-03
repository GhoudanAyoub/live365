import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class Video {
  String id;
  String videoId;
  String videoTitle;
  String ownerId;
  String username;
  String userPic;
  String songName;
  String tags;
  String description;
  String mediaUrl;
  Timestamp timestamp;

  VideoPlayerController controller;

  Video.name(
      {this.id,
      this.videoId,
      this.videoTitle,
      this.username,
      this.ownerId,
      this.userPic,
      this.songName,
      this.tags,
      this.description,
      this.mediaUrl,
      this.timestamp});

  Video.fromJson(Map<dynamic, dynamic> json) {
    id = json['id'];
    videoId = json['videoId'];
    videoTitle = json['videoTitle'];
    ownerId = json['ownerId'];
    username = json['username'];
    userPic = json['userPic'];
    songName = json['songName'];
    tags = json['tags'];
    description = json['description'];
    mediaUrl = json['mediaUrl'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['videoId'] = this.videoId;
    data['videoTitle'] = this.videoTitle;
    data['ownerId'] = this.ownerId;
    data['username'] = this.username;
    data['userPic'] = this.userPic;
    data['songName'] = this.songName;
    data['tags'] = this.tags;
    data['description'] = this.description;
    data['mediaUrl'] = this.mediaUrl;
    data['timestamp'] = this.timestamp;
    return data;
  }

  Future<Null> loadController() async {
    controller = VideoPlayerController.network(mediaUrl);
    await controller.initialize();
    controller.setLooping(true);
  }
}
