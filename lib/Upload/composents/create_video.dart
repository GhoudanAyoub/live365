import 'dart:io';

import 'package:LIVE365/Upload/composents/video_view_model.dart';
import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../constants.dart';
import '../../theme.dart';

class CreateVideo extends StatefulWidget {
  final File filePath;

  const CreateVideo({Key key, this.filePath}) : super(key: key);
  @override
  _CreateVideoState createState() => _CreateVideoState();
}

class _CreateVideoState extends State<CreateVideo> {
  VideoPlayerController _videoPlayerController;
  ImagePicker picker = ImagePicker();
  File _video;
  File file;
  VideoViewModel viewModel;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    currentUserId() {
      return firebaseAuth.currentUser.uid;
    }

    viewModel = Provider.of<VideoViewModel>(context);

    if (widget.filePath != null) {
      viewModel.setMediaUrl(widget.filePath);
      _videoPlayerController = VideoPlayerController.file(widget.filePath)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController.play();
          _videoPlayerController.setVolume(0);
        });
    }
    _pickVideo() async {
      file = await ImagePicker.pickVideo(source: ImageSource.gallery);
      _video = File(file.path);
      viewModel.setMediaUrl(_video);
      _videoPlayerController = VideoPlayerController.file(_video)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController.play();
          _videoPlayerController.setVolume(0);
        });
    }

    return WillPopScope(
      onWillPop: () async {
        await viewModel.resetVedio();
        return true;
      },
      child: ModalProgressHUD(
        progressIndicator: circularProgress(context),
        inAsyncCall: viewModel.loading,
        child: Scaffold(
          key: viewModel.scaffoldKey,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Feather.x),
              onPressed: () {
                viewModel.resetVedio();
                Navigator.pop(context);
              },
            ),
            title: Text('Post'.toUpperCase()),
            centerTitle: true,
            actions: [
              GestureDetector(
                onTap: () async {
                  await viewModel.uploadVideos(context);
                  Navigator.pop(context);
                  viewModel.resetVedio();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Post'.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              )
            ],
          ),
          body: ListView(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            children: [
              SizedBox(height: 15.0),
              StreamBuilder(
                stream: usersRef.doc(currentUserId()).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData) {
                    UserModel user = UserModel.fromJson(snapshot.data.data());
                    return ListTile(
                      leading: user.photoUrl != null && user.photoUrl != ""
                          ? CircleAvatar(
                              radius: 35.0,
                              backgroundImage: NetworkImage(user?.photoUrl),
                            )
                          : Image.asset(
                              "assets/images/Profile Image.png",
                              width: 70.0,
                            ),
                      title: Text(
                        user?.username,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: white),
                      ),
                      subtitle: Text(user?.email,
                          style: TextStyle(
                              fontWeight: FontWeight.normal, color: white)),
                    );
                  }
                  return Container();
                },
              ),
              InkWell(
                onTap: () => {if (widget.filePath == null) _pickVideo()},
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width - 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                    border: Border.all(
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                  child: _video != null
                      ? _videoPlayerController.value.initialized
                          ? AspectRatio(
                              aspectRatio:
                                  _videoPlayerController.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController),
                            )
                          : Container()
                      : Container(),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                style: TextStyle(color: Colors.white),
                initialValue: viewModel.description,
                keyboardType: TextInputType.name,
                onChanged: (val) => viewModel.setVideoTitle(val),
                decoration: InputDecoration(
                  labelStyle: textTheme().bodyText2,
                  hintStyle: textTheme().bodyText2,
                  labelText: "videoTitle",
                  hintText: "Enter your videoTitle",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                style: TextStyle(color: Colors.white),
                initialValue: viewModel.description,
                keyboardType: TextInputType.name,
                onChanged: (val) => viewModel.setSongName(val),
                decoration: InputDecoration(
                  labelStyle: textTheme().bodyText2,
                  hintStyle: textTheme().bodyText2,
                  labelText: "songName",
                  hintText: "Enter your songName",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                style: TextStyle(color: Colors.white),
                initialValue: viewModel.description,
                keyboardType: TextInputType.name,
                onChanged: (val) => viewModel.setDescription(val),
                decoration: InputDecoration(
                  labelStyle: textTheme().bodyText2,
                  hintStyle: textTheme().bodyText2,
                  labelText: "Description",
                  hintText: "Enter your Description",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                style: TextStyle(color: Colors.white),
                initialValue: viewModel.tags,
                keyboardType: TextInputType.name,
                onChanged: (val) => viewModel.setTags(val),
                decoration: InputDecoration(
                  labelStyle: textTheme().bodyText2,
                  hintStyle: textTheme().bodyText2,
                  labelText: "Hashtags",
                  hintText: "Enter your Hashtags",
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
