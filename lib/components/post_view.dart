import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/post.dart';
import 'package:LIVE365/profile/components/body.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
//import 'package:like_button/like_button.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'comment.dart';
import 'indicators.dart';

class Posts extends StatefulWidget {
  final PostModel post;

  Posts({this.post});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  UserModel user;
  int l, c;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Card(
        elevation: 3,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Stack(
          children: [buildImage(context), buildPostButtom()],
        ),
      ),
    );
  }

  buildImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: CachedNetworkImage(
        imageUrl: widget.post.mediaUrl,
        placeholder: (context, url) {
          return circularProgress(context);
        },
        errorWidget: (context, url, error) {
          return Icon(Icons.error, color: Colors.white);
        },
        fit: BoxFit.cover,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  //***************
  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count likes',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 10.0, color: Colors.white),
      ),
    );
  }

  buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Text(
        '- $count comments',
        style: TextStyle(
            fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
      ),
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
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.white)),
            SizedBox(width: 3.0),
            StreamBuilder(
              stream: likesRef
                  .where('postId', isEqualTo: widget.post.postId)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  QuerySnapshot snap = snapshot.data;
                  List<DocumentSnapshot> docs = snap.docs;
                  l = docs?.length ?? 0;
                  return buildLikesCount(context, docs?.length ?? 0);
                } else {
                  return buildLikesCount(context, 0);
                }
              },
            ),
            SizedBox(width: 5.0),
            StreamBuilder(
              stream: commentRef
                  .doc(widget.post.postId)
                  .collection("comments")
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  QuerySnapshot snap = snapshot.data;
                  List<DocumentSnapshot> docs = snap.docs;
                  c = docs?.length ?? 0;
                  return buildCommentsCount(context, docs?.length ?? 0);
                } else {
                  return buildCommentsCount(context, 0);
                }
              },
            ),
          ],
        ),
      ),
      trailing: Wrap(children: [
        buildLikeButton(),
        firebaseAuth.currentUser != null
            ? IconButton(
                icon: Icon(
                  CupertinoIcons.chat_bubble,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Comments(post: widget.post),
                    ),
                  );
                },
              )
            : Container(
                width: 0,
                height: 0,
              ),
      ]),
    );
  }

  buildPostHeader() {
    if (firebaseAuth.currentUser != null) {
      bool isMe = currentUserId() == widget.post.ownerId;
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
        leading: buildUserDp(),
        title: Text(
          widget.post.username,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(widget.post.tags == null ? 'LIVE365' : widget.post.tags,
            style:
                TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
        trailing: isMe
            ? IconButton(
                icon: Icon(
                  Feather.more_horizontal,
                  color: Colors.white,
                ),
                onPressed: () => handleDelete(context),
              )
            : null,
      );
    } else
      return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
        leading: buildUserDp(),
        title: Text(
          widget.post.username,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(widget.post.tags == null ? 'LIVE365' : widget.post.tags,
            style:
                TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
        trailing: IconButton(
          ///Feature coming soon
          icon: Icon(CupertinoIcons.bookmark, color: Colors.white, size: 25.0),
          onPressed: () {},
        ),
      );
  }

  buildUserDp() {
    return StreamBuilder(
      stream: usersRef.doc(widget.post.ownerId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          UserModel user = UserModel.fromJson(snapshot.data.data());
          return GestureDetector(
            onTap: () => showProfile(context, profileId: user?.id),
            child: CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
          );
        }
        return Container();
      },
    );
  }

  buildLikeButton() {
    if (firebaseAuth.currentUser != null)
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
                  ? Icon(CupertinoIcons.heart, color: Colors.white)
                  : Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.red,
                    ),
            );
          }
          return Container();
        },
      );
    else
      return Icon(CupertinoIcons.heart, color: Colors.white);
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

  handleDelete(BuildContext parentContext) {
    //shows a simple dialog box
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text('Delete Post'),
              ),
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

//you can only delete your own posts
  deletePost() async {
    postRef.doc(widget.post.id).delete();

//delete notification associated with that given post
    QuerySnapshot notificationsSnap = await notificationRef
        .doc(widget.post.ownerId)
        .collection('notifications')
        .where('postId', isEqualTo: widget.post.postId)
        .get();
    notificationsSnap.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

//delete all the comments associated with that given post
    QuerySnapshot commentSnapshot =
        await commentRef.doc(widget.post.postId).collection('comments').get();
    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Body(profileId: profileId),
      ),
    );
  }
}
