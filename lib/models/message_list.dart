import '../utils.dart';

class MessageListField {
  static final String lastMessageTime = 'created_at';
}

class MessageList {
  final String id;
  final String name;
  final String img;
  final bool online;
  final bool live;
  final String message;
  final DateTime created_at;

  MessageList({
    this.id,
    this.name,
    this.img,
    this.online,
    this.live,
    this.message,
    this.created_at,
  });
  MessageList copyWith({
    String id,
    String name,
    String img,
    bool online,
    bool live,
    String message,
    DateTime created_at,
  }) =>
      MessageList(
        id: id ?? this.id,
        name: name ?? this.name,
        img: img ?? this.img,
        online: online ?? this.online,
        live: live ?? this.live,
        message: message ?? this.message,
        created_at: created_at ?? this.created_at,
      );

  static MessageList fromJson(Map<String, dynamic> json) => MessageList(
      name: json['name'],
      img: json['img'],
      online: json['online'],
      live: json['live'],
      message: json['message'],
      created_at: Utils.toDateTime(json['created_at']));

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'img': img,
        'online': online,
        'live': live,
        'message': message,
        'created_at': Utils.fromDateTimeToJson(created_at),
      };

  static get initMessageList => <MessageList>[
        MessageList(
            created_at: DateTime.now(),
            img:
                "https://images.unsplash.com/photo-1571741140674-8949ca7df2a7?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
            live: true,
            message: "How are you doing?",
            name: "Michael Dam",
            online: true),
        MessageList(
            created_at: DateTime.now(),
            img:
                "https://images.unsplash.com/photo-1467272046618-f2d1703715b1?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60",
            live: false,
            message: "Long time no see!!",
            name: "Charly Race",
            online: false),
        MessageList(
            created_at: DateTime.now(),
            img:
                "https://images.unsplash.com/photo-1517070208541-6ddc4d3efbcb?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3319&q=80",
            live: true,
            message: "Glad to know you in person!",
            name: "Tyler Nix",
            online: false),
      ];
}
