import 'dart:io';

import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/services/services.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class PostService extends Service {
  String postId = Uuid().v4();
  UserModel user;

  uploadProfilePicture(File image, User user) async {
    String link = await uploadImage(profilePic, image);
    var ref = usersRef.doc(user.uid);
    ref.update({
      "photoUrl": link,
    });
  }

  uploadPost(File image, String tags, String description) async {
    String link = await uploadImage(posts, image);
    DocumentSnapshot doc =
        await usersRef.doc(firebaseAuth.currentUser.uid).get();
    user = UserModel.fromJson(doc.data());
    var ref = postRef.doc();
    ref.set({
      "id": ref.id,
      "postId": ref.id,
      "username": user.username,
      "ownerId": firebaseAuth.currentUser.uid,
      "mediaUrl": link,
      "description": description == null ? "" : description,
      "tags": tags == null ? "" : tags,
      "timestamp": Timestamp.now(),
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
