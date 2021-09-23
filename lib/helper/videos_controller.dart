import 'package:LIVE365/models/video.dart';
import 'package:LIVE365/services/remote_services.dart';
import 'package:get/get.dart';

class VideosController extends GetxController {
  var isLoading = true.obs;
  var videoList = [].obs;

  @override
  void onInit() {
    fetchVideos();
    super.onInit();
  }

  void fetchVideos() async {
    try {
      isLoading(true);
      List<Video> videos = await RemoteServices.fetchVideos();
      if (videos != null) {
        videoList.assignAll(videos);
      }
    } finally {
      isLoading(false);
    }
  }
}
