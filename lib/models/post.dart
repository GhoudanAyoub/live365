class Post {
  final String name;
  final String email;
  final String img;
  final String desc;

  Post({this.name, this.email, this.img, this.desc});

  static Post fromJson(Map<String, dynamic> json) => Post(
      name: json['name'],
      email: json['email'],
      img: json['img'],
      desc: json['desc']);
}
