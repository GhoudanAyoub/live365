class users {
  final String id;
  final String name;
  final String email;
  final int like;
  final int following;
  final int followers;

  users(
      {this.id,
      this.name,
      this.email,
      this.like,
      this.following,
      this.followers});

  static users fromJson(Map<String, dynamic> json) => users(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        like: json['like'],
        following: json['following'],
        followers: json['followers'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'like': like,
        'following': following,
        'followers': followers,
      };
}
