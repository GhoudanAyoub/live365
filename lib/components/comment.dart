import 'package:LIVE365/components/stream_comments_wrapper.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/post.dart';
import 'package:LIVE365/models/post_comments.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../SizeConfig.dart';
import '../constants.dart';
import 'cached_image.dart';

class Comments extends StatefulWidget {
  final PostModel post;

  Comments({this.post});

  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  UserModel user;

  final DateTime timestamp = DateTime.now();
  TextEditingController commentsTEC = TextEditingController();

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        centerTitle: true,
        title: Text('COMMENTS'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            buildImageCard(),
            Expanded(
              child: buildComments(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: GBottomNav,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[500],
                      offset: Offset(0.0, 1.5),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
                constraints: BoxConstraints(
                  maxHeight: 190.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: commentsTEC,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            hintText: "Write your comment...",
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color: Colors.white,
                            ),
                          ),
                          maxLines: null,
                        ),
                        trailing: GestureDetector(
                          onTap: addComments,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageCard() => Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              height: 350.0,
              width: MediaQuery.of(context).size.width,
              child: cachedNetworkImage(widget.post.mediaUrl),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              title: Text(
                widget.post.description == null ? "" : widget.post.description,
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Text(timeago.format(widget.post.timestamp.toDate()),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
                    SizedBox(width: 3.0),
                    StreamBuilder(
                      stream: likesRef
                          .where('postId', isEqualTo: widget.post.postId)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          QuerySnapshot snap = snapshot.data;
                          List<DocumentSnapshot> docs = snap.docs;
                          return buildLikesCount(context, docs?.length ?? 0);
                        } else {
                          return buildLikesCount(context, 0);
                        }
                      },
                    ),
                    SizedBox(width: 5.0),
                    buildLikeButton()
                  ],
                ),
              ),
            )
          ],
        ),
      );
  buildFullPost() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(30.0),
          ),
          child: Stack(
            children: [
              Container(
                height: 320.0,
                width: MediaQuery.of(context).size.width - 18.0,
                child: cachedNetworkImage(widget.post.mediaUrl),
              ),
              Positioned(
                left: 0.0,
                bottom: 0.0,
                width: getProportionateScreenWidth(350),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.1),
                      ])),
                ),
              ),
              Positioned(
                left: 10.0,
                top: 10.0,
                right: 10.0,
                child: buildPostHeader(),
              ),
              Positioned(
                left: 10.0,
                bottom: 10.0,
                right: 10.0,
                child: buildPostButtom(),
              )
            ],
          ),
        ),
      ],
    );
  }

  buildPostButtom() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
      title: Text(
        widget.post.description == null ? "" : widget.post.description,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Text(timeago.format(widget.post.timestamp.toDate()),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(width: 3.0),
            StreamBuilder(
              stream: likesRef
                  .where('postId', isEqualTo: widget.post.postId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  QuerySnapshot snap = snapshot.data;
                  List<DocumentSnapshot> docs = snap.docs;
                  return buildLikesCount(context, docs?.length ?? 0);
                } else {
                  return buildLikesCount(context, 0);
                }
              },
            ),
          ],
        ),
      ),
      trailing: Wrap(children: [
        buildLikeButton(),
      ]),
    );
  }

  buildPostHeader() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
      leading: buildUserDp(),
      title: Text(
        widget.post.username,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(widget.post.tags,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.normal)),
    );
  }

  buildUserDp() {
    return StreamBuilder(
      stream: usersRef.doc(widget.post.ownerId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          UserModel user = UserModel.fromJson(snapshot.data.data());
          return CircleAvatar(
            radius: 25.0,
            backgroundImage: NetworkImage(user.photoUrl),
          );
        }
        return Container();
      },
    );
  }

  addComments() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    user = UserModel.fromJson(doc.data());
    commentRef.doc(widget.post.postId).collection("comments").add({
      "username": user.username,
      "comment": commentsTEC.text,
      "timestamp": timestamp,
      "userDp": user.photoUrl,
      "userId": user.id,
    });

    bool isNotMe = widget.post.ownerId != currentUserId();
    if (isNotMe) {
      notificationRef.doc(widget.post.ownerId).collection('notifications').add({
        "type": "comment",
        "commentData": commentsTEC.text,
        "username": user.username,
        "userId": user.id,
        "userDp": user.photoUrl,
        "postId": widget.post.postId,
        "mediaUrl": widget.post.mediaUrl,
        "timestamp": timestamp,
      });
    }
    commentsTEC.clear();
  }

  buildComments() {
    return CommentsStreamWrapper(
      shrinkWrap: true,
      stream: commentRef
          .doc(widget.post.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        CommentModel comments = CommentModel.fromJson(snapshot.data());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(comments.userDp),
              ),
              title: Text(
                comments.username,
                style:
                    TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
              ),
              subtitle: Text(
                timeago.format(comments.timestamp.toDate()),
                style: TextStyle(fontSize: 12.0, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80.0),
              child: Text(
                comments.comment,
                style:
                    TextStyle(fontWeight: FontWeight.w400, color: Colors.white),
              ),
            ),
            Divider(
              color: Colors.white,
              indent: 20,
              endIndent: 25,
            )
          ],
        );
      },
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: widget.post.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot?.data?.docs ?? [];
          return IconButton(
            onPressed: () {
              if (docs.isEmpty) {
                likesRef.add({
                  'userId': currentUserId(),
                  'postId': widget.post.postId,
                  'dateCreated': Timestamp.now(),
                });
                addLikesToNotification();
              } else {
                likesRef.doc(docs[0].id).delete();

                removeLikeFromNotification();
              }
            },
            icon: docs.isEmpty
                ? Icon(
                    CupertinoIcons.heart,
                  )
                : Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                  ),
          );
        }
        return Container();
      },
    );
  }

  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count likes',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(widget.post.ownerId)
          .collection('notifications')
          .doc(widget.post.postId)
          .set({
        "type": "like",
        "username": user.username,
        "userId": currentUserId(),
        "userDp": user.photoUrl,
        "postId": widget.post.postId,
        "mediaUrl": widget.post.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != widget.post.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(widget.post.ownerId)
          .collection('notifications')
          .doc(widget.post.postId)
          .get()
          .then((doc) => {
                if (doc.exists) {doc.reference.delete()}
              });
    }
  }
}
