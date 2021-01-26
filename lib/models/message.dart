import 'package:flutter/material.dart';

import '../utils.dart';

class MessageField {
  static final String createdAt = 'createdAt';
}

class messages {
  final String sender;
  final String receiver;
  final String urlAvatar;
  final String username;
  final String message;
  final DateTime createdAt;

  const messages({
    @required this.sender,
    @required this.receiver,
    @required this.urlAvatar,
    @required this.username,
    @required this.message,
    @required this.createdAt,
  });

  static messages fromJson(Map<String, dynamic> json) => messages(
        sender: json['sender'],
        receiver: json['receiver'],
        urlAvatar: json['urlAvatar'],
        username: json['username'],
        message: json['message'],
        createdAt: Utils.toDateTime(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'sender': sender,
        'receiver': receiver,
        'urlAvatar': urlAvatar,
        'username': username,
        'message': message,
        'createdAt': Utils.fromDateTimeToJson(createdAt),
      };
}
