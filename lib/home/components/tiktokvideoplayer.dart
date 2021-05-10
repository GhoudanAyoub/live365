import 'package:LIVE365/models/video.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';

class VideoListController {
  VideoListController();

  void setPageContrller(PageController pageController) {
    pageController.addListener(() {
      var p = pageController.page;
      if (p % 1 == 0) {
        int target = p ~/ 1;
        if (index.value == target) return;
        // 播放当前的，暂停其他的
        var oldIndex = index.value;
        var newIndex = target;
        playerOfIndex(oldIndex).seekTo(0);
        playerOfIndex(oldIndex).pause();
        playerOfIndex(newIndex).start();
        // 完成
        index.value = target;
      }
    });
  }

  FijkPlayer playerOfIndex(int index) => playerList[index];

  int get videoCount => playerList.length;
  addVideoInfo(List<Video> list) {
    for (var info in list) {
      playerList.add(
        FijkPlayer()
          ..setDataSource(
            info.mediaUrl,
            autoPlay: playerList.length == 0,
            showCover: true,
          )
          ..setLoop(0),
      );
    }
  }

  init(PageController pageController, List<Video> initialList) {
    addVideoInfo(initialList);
    setPageContrller(pageController);
  }

  ValueNotifier<int> index = ValueNotifier<int>(0);

  List<FijkPlayer> playerList = [];

  ///
  FijkPlayer get currentPlayer => playerList[index.value];

  bool get isPlaying => currentPlayer.state == FijkState.started;

  void dispose() {
    for (var player in playerList) {
      player.dispose();
    }
    playerList = [];
  }
}
