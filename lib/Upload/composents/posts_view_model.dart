import 'dart:io';

import 'package:LIVE365/home/home_screen.dart';
import 'package:LIVE365/models/post.dart';
import 'package:LIVE365/services/post_service.dart';
import 'package:LIVE365/services/user_service.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants.dart';

class PostsViewModel extends ChangeNotifier {
  //Services
  UserService userService = UserService();
  PostService postService = PostService();

  //Keys
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Variables
  bool loading = false;
  String username;
  File mediaUrl;
  final picker = ImagePicker();
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

  setPost(PostModel post) {
    if (post != null) {
      description = post.description;
      imgLink = post.mediaUrl;
      tags = post.tags;
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

  //Functions
  pickImage({bool camera = false}) async {
    loading = true;
    notifyListeners();
    try {
      PickedFile pickedFile = await picker.getImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      File croppedFile = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: GBottomNav,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
      mediaUrl = File(croppedFile.path);
      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Cancelled');
    }
  }

  uploadPosts(context) async {
    try {
      loading = true;
      notifyListeners();
      await postService.uploadPost(context, mediaUrl, tags, description);
      loading = false;
      resetPost();
      notifyListeners();
    } catch (e) {
      print(e);
      loading = false;
      resetPost();
      showInSnackBar('Uploaded successfully!');
      notifyListeners();
    }
  }

  uploadProfilePicture(BuildContext context) async {
    if (mediaUrl == null) {
      showInSnackBar('Please select an image');
    } else {
      try {
        loading = true;
        notifyListeners();
        await postService.uploadProfilePicture(
            mediaUrl, firebaseAuth.currentUser);
        loading = false;
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
        notifyListeners();
      } catch (e) {
        print(e);
        loading = false;
        showInSnackBar('Uploaded successfully!');
        notifyListeners();
      }
    }
  }

  resetPost() {
    mediaUrl = null;
    description = null;
    location = null;
    edit = null;
    notifyListeners();
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}
