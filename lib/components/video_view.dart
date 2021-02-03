import 'package:LIVE365/SizeConfig.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/profile/components/body.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

import 'indicators.dart';

class Videos extends StatefulWidget {
  final Video video;

  Videos({this.video});

  @override
  _VideosState createState() => _VideosState();
}

class _VideosState extends State<Videos> {
  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  VideoPlayerController videoPlayerController;
  Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    videoPlayerController =
        new VideoPlayerController.network(widget.video.mediaUrl);
    _initializeVideoPlayerFuture = videoPlayerController.initialize().then((_) {
      setState(() {});
    });
  }

  UserModel user;
  int l, c;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(30.0),
              ),
              child: Stack(
                children: [
                  FutureBuilder(
                    future: _initializeVideoPlayerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return new Container(
                          child: Card(
                            key: new PageStorageKey(widget.video.mediaUrl),
                            elevation: 5.0,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Chewie(
                                    key: new PageStorageKey(
                                        widget.video.mediaUrl),
                                    controller: ChewieController(
                                      videoPlayerController:
                                          videoPlayerController,
                                      aspectRatio: 3 / 2,
                                      autoInitialize: true,
                                      looping: false,
                                      autoPlay: false,
                                      // Errors can occur for example when trying to play a video
                                      // from a non-existent URL
                                      errorBuilder: (context, errorMessage) {
                                        return Center(
                                          child: Text(
                                            errorMessage,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Center(
                          child: circularProgress(context),
                        );
                      }
                    },
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
            )
          ],
        ),
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
        widget.video.description == null ? "" : widget.video.description,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Row(
          children: [
            Text(timeago.format(widget.video.timestamp.toDate()),
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(width: 3.0),
            StreamBuilder(
              stream: likesRef
                  .where('postId', isEqualTo: widget.video.id)
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
                  .doc(widget.video.id)
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
        IconButton(
          icon: Icon(
            CupertinoIcons.chat_bubble,
            color: Colors.white,
          ),
          onPressed: () {
            /*
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => {Comments(post: widget.video)},
              ),
            );*/
          },
        ),
      ]),
    );
  }

  buildPostHeader() {
    bool isMe = currentUserId() == widget.video.ownerId;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
      leading: buildUserDp(),
      title: Text(
        widget.video.username,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
      subtitle: Text(widget.video.tags == null ? 'LIVE365' : widget.video.tags,
          style: TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
      trailing: isMe
          ? IconButton(
              icon: Icon(
                Feather.more_horizontal,
                color: Colors.white,
              ),
              onPressed: () => handleDelete(context),
            )
          : IconButton(
              ///Feature coming soon
              icon: Icon(CupertinoIcons.bookmark,
                  color: Colors.white, size: 25.0),
              onPressed: () {},
            ),
    );
  }

  buildUserDp() {
    return StreamBuilder(
      stream: usersRef.doc(widget.video.ownerId).snapshots(),
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
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: widget.video.id)
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
                  'postId': widget.video.id,
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
  }

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.video.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(widget.video.ownerId)
          .collection('notifications')
          .doc(widget.video.id)
          .set({
        "type": "like",
        "username": user.username,
        "userId": currentUserId(),
        "userDp": user.photoUrl,
        "postId": widget.video.id,
        "mediaUrl": widget.video.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != widget.video.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(widget.video.ownerId)
          .collection('notifications')
          .doc(widget.video.id)
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
    postRef.doc(widget.video.id).delete();

//delete notification associated with that given post
    QuerySnapshot notificationsSnap = await notificationRef
        .doc(widget.video.ownerId)
        .collection('notifications')
        .where('postId', isEqualTo: widget.video.id)
        .get();
    notificationsSnap.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

//delete all the comments associated with that given post
    QuerySnapshot commentSnapshot =
        await commentRef.doc(widget.video.id).collection('comments').get();
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
