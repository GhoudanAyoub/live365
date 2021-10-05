import 'dart:io';

import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/services/remote_services.dart';
import 'package:LIVE365/services/services.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class VideoService extends Service {
  String videoId = Uuid().v4();
  UserModel user;

  uploadProfilePicture(File image, User user) async {
    String link = await uploadImage(profilePic, image);
    var ref = usersRef.doc(user.uid);
    ref.update({
      "photoUrl": link,
    });
  }

  static Future<List<Video>> getVideoList() async {
    var data = await videoRef.get();
    var videoList = <Video>[];
    data.docs.forEach((element) {
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    });
    return videoList;
  }

  uploadVideo(context, File image, String songName, String videoTitle,
      String tags, String description) async {
    String link = await uploadV(videos, image);
    DocumentSnapshot doc =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    user = UserModel.fromJson(doc.data());
    var ref = videoRef.doc();
    //MySql
    RemoteServices.addVideos(context, ref, link, user, image, songName,
        videoTitle, tags, description);

    //Firebase
    ref.set({
      "id": ref.id,
      "videoId": ref.id,
      "videoTitle": videoTitle,
      "username": user.username,
      "ownerId": firebaseAuth.currentUser.uid,
      "userPic": user.photoUrl,
      "songName": songName,
      "mediaUrl": link,
      "description": description,
      "tags": tags,
      "timestamp": Timestamp.now(),
    }).catchError((e) {
      print(e);
    });
  }

  uploadComment(String username, String comment, String userDp, String userId,
      String postId) async {
    await commentRef.doc(postId).collection("comments").add({
      "username": username,
      "comment": comment,
      "timestamp": Timestamp.now(),
      "userDp": userDp,
      "userId": userId,
    });
  }

  addCommentToNotification(
      String type,
      String commentData,
      String username,
      String userId,
      String postId,
      String mediaUrl,
      String ownerId,
      String userDp) async {
    await notificationRef.doc(ownerId).collection('notifications').add({
      "type": type,
      "commentData": commentData,
      "username": username,
      "userId": userId,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }

  addLikesToNotification(String type, String username, String userId,
      String postId, String mediaUrl, String ownerId, String userDp) async {
    await notificationRef
        .doc(ownerId)
        .collection('notifications')
        .doc(postId)
        .set({
      "type": type,
      "username": username,
      "userId": firebaseAuth.currentUser.uid,
      "userDp": userDp,
      "postId": postId,
      "mediaUrl": mediaUrl,
      "timestamp": Timestamp.now(),
    });
  }
}
