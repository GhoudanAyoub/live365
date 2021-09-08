import 'package:LIVE365/models/video.dart';
import 'package:http/http.dart' as http;

class RemoteServices {
  static var client = http.Client();

  static Future<List<Video>> fetchVideos() async {
    var response =
        await client.get(Uri.parse('http://172.29.128.1:3000/api/videos'));
    if (response.statusCode == 200) {
      var jsonString = response.body;
      return VideoFromJson(jsonString);
    } else {
      return null;
    }
  }
}
