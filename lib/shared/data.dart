import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Globals {
  static LocalUser? localUser;
  static LocalUser? opponentUser;
  static Topic? topic;
  static String? stance;
  static String? chatID;

  static Color getReputationColour(int? rep) {
    //goes from 0 (red) to 100 (green)
    const a = 255;
    var r = 255; //init
    var g = 255; //init
    const b = 0;
    if (rep == null) {
      return Colors.grey[850]!;
    }
    if (rep < 50) {
      g = (rep * 255 / 50).round();
    } else {
      rep = rep - 50;
      rep = rep * -1 + 50;
      r = (rep * 255 / 50).round();
    }

    return Color.fromARGB(a, r, g, b);
  }

  static bool getIsWeb(context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool platform;
    if (!kIsWeb) {
      platform = false;
    } {
      if (screenHeight / screenWidth > 1.6) {
        platform = false;
      } else {
        platform = true;
      }
    }
    return platform;
  }
}

enum Owner { receiver, sender }

class LocalUser {
  final String uid;
  String? username;
  final String? email;
  int? reputation;
  LocalUser({
    required this.uid,
    this.username,
    this.email,
    this.reputation,
  });
}

class Topic {
  String title;
  String description;
  Uint8List? image;
  Topic({
    required this.title,
    required this.description,
    this.image,
  });
}

class ChatMessage {
  String content;
  String owner;
  DateTime time;
  ChatMessage({required this.content, required this.owner, required this.time});
}

class Chat {
  String chatID;
  LocalUser? yay;
  LocalUser? nay;
  Topic topic;
  bool active;
  late List<ChatMessage> messages;
  Chat({
    required this.chatID,
    required this.topic,
    required this.active,
    this.yay,
    this.nay,
  });
}


