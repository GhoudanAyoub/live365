import 'dart:convert';
import 'dart:io';

import 'package:LIVE365/models/live.dart';
import 'package:LIVE365/models/post.dart';
import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class RemoteServices {
  static var client = http.Client();

  static Future<String> fetchToken(String ChannelName) async {
    var response = await client.get(Uri.parse(
        'http://172.104.161.105/api/access_token?channelName=$ChannelName'));
    if (response.statusCode == 500) {
      var jsonString = jsonDecode(response.body);
      return jsonString["error"];
    } else {
      var jsonString = jsonDecode(response.body);
      return jsonString["Token"];
    }
  }

  static Future<List<Video>> fetchVideos() async {
    var response =
        await client.get(Uri.parse('http://172.104.161.105/api/videos'));
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return VideoFromJson(jsonString);
    } else {
      return null;
    }
  }

  static Future<List<Live>> fetchLives() async {
    var response =
        await client.get(Uri.parse('http://172.104.161.105/api/lives'));
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return LiveFromJson(jsonString);
    } else {
      return null;
    }
  }

  static Future<List<PostModel>> fetchPosts() async {
    var response =
        await client.get(Uri.parse('http://172.104.161.105/api/posts'));
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return postFromJson(jsonString);
    } else {
      return null;
    }
  }

  static void addVideos(context, ref, link, user, File image, String songName,
      String videoTitle, String tags, String description) async {
    Map<String, String> header = {"Content-Type": "application/json"};
    var url = 'http://172.104.161.105/api/video/add';
    var data = {
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
    };
    var response = await http.post(Uri.parse(url),
        headers: header, body: json.encode(data));
    print('${response.body}');
    var message = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: message["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: primary,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      Fluttertoast.showToast(
          msg: message["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: primary,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  static void addPosts(context, ref, link, user, File image, String tags,
      String description) async {
    Map<String, String> header = {"Content-Type": "application/json"};
    var url = 'http://172.104.161.105/api/post/add';
    var data = {
      "id": ref.id,
      "postId": ref.id,
      "username": user.username,
      "ownerId": firebaseAuth.currentUser.uid,
      "mediaUrl": link,
      "description": description == null ? "" : description,
      "tags": tags == null ? "" : tags
    };
    var response = await http.post(Uri.parse(url),
        headers: header, body: json.encode(data));
    var message = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: message["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: primary,
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
          msg: message["message"],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: primary,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
