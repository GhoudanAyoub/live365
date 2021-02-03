import 'dart:io';

import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/services/user_service.dart';
import 'package:LIVE365/services/video_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VideoViewModel extends ChangeNotifier {
  //Services
  UserService userService = UserService();
  VideoService postService = VideoService();

  //Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ImagePicker picker = ImagePicker();
  //Variables
  bool loading = false;
  String username;
  String songName;
  String videoTitle;
  File mediaUrl;
  String location;
  String bio;
  String description;
  String email;
  String commentData;
  String ownerId;
  String userId;
  String type;
  String tags;
  File userDp;
  String imgLink;
  bool edit = false;
  String id;
//controllers
  TextEditingController locationTEC = TextEditingController();

  //Setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  setVideo(Video video) {
    if (video != null) {
      songName = video.songName;
      videoTitle = video.videoTitle;
      description = video.description;
      imgLink = video.mediaUrl;
      tags = video.tags;
      edit = true;
      edit = false;
      notifyListeners();
    } else {
      edit = false;
      notifyListeners();
    }
  }

  setUsername(String val) {
    print('SetName $val');
    username = val;
    notifyListeners();
  }

  setMediaUrl(File val) {
    print('SetMediaUrl $val');
    mediaUrl = val;
    loading = false;
    notifyListeners();
  }

  setDescription(String val) {
    print('SetDescription $val');
    description = val;
    notifyListeners();
  }

  setBio(String val) {
    print('SetBio $val');
    bio = val;
    notifyListeners();
  }

  setTags(String val) {
    print('SetTags $val');
    tags = val;
    notifyListeners();
  }

  setSongName(String val) {
    print('SetSongName $val');
    songName = val;
    notifyListeners();
  }

  setVideoTitle(String val) {
    print('SetVideoTitle $val');
    videoTitle = val;
    notifyListeners();
  }

  //Functions

  uploadVideos() async {
    try {
      loading = true;
      notifyListeners();
      await postService.uploadVideo(
          mediaUrl, songName, videoTitle, tags, description);
      loading = false;
      resetVedio();
      notifyListeners();
    } catch (e) {
      print(e);
      loading = false;
      resetVedio();
      showInSnackBar('Uploaded successfully!');
      notifyListeners();
    }
  }

  resetVedio() {
    mediaUrl = null;
    description = null;
    songName = null;
    videoTitle = null;
    location = null;
    edit = null;
    notifyListeners();
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}
