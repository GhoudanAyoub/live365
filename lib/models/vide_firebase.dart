import 'package:LIVE365/models/video.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideosAPI {
  List<Video> listVideos = List<Video>();

  VideosAPI() {
    load();
  }

  void load() async {
    listVideos = await getVideoList();
  }

  Future<List<Video>> getVideoList() async {
    var data = await FirebaseFirestore.instance.collection("Videos").get();

    var videoList = <Video>[];
    var videos;

    if (data.docs.length == 0) {
      // await addDemoData();
      videos = (await FirebaseFirestore.instance.collection("Videos").get());
    } else {
      videos = data;
    }

    videos.docs.forEach((element) {
      Video video = Video.fromJson(element.data());
      videoList.add(video);
    });

    return videoList;
  }
/*
  Future<Null> addDemoData() async {
    for (var video in data) {
      await FirebaseFirestore.instance.collection("Videos").add(video);
    }
  }

 */
}
