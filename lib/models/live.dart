class Live {
  String username;
  String channelName;
  String hostImage;
  String image;
  int channelId;
  bool me = false;

  Live(
      {this.username,
      this.channelName,
      this.hostImage,
      this.image,
      this.channelId,
      this.me});

  static Live fromJson(Map<String, dynamic> json) => Live(
        username: json['username'],
        image: json['image'],
        channelId: json['channelId'],
        channelName: json['channelName'],
        hostImage: json['hostImage'],
        me: json['me'],
      );
}
