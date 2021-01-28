class users {
  final String id;
  final String name;
  final String email;
  final String img;
  final String subName;
  final String quot;
  final int like;
  final int following;
  final int followers;

  users(
      {this.id,
      this.name,
      this.email,
      this.like,
      this.following,
      this.followers,
      this.img,
      this.subName,
      this.quot});

  static users fromJson(Map<String, dynamic> json) => users(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        like: json['like'],
        img: json['img'],
        subName: json['subName'],
        quot: json['quot'],
        following: json['following'],
        followers: json['followers'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'like': like,
        'subName': subName,
        'quot': quot,
        'img': img,
        'following': following,
        'followers': followers,
      };
}
