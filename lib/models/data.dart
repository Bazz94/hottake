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
  String? image;
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

class MessageStyle {
  static Color? getBubbleColor(String owner) {
    if (owner == Globals.localUser!.uid) {
      return Colors.grey[900];
    } else if (owner == "admin") {
      return Colors.grey[200];
    } else {
      return Colors.deepPurpleAccent;
    }
  }

  static Alignment getAlignment(String user) {
    if (user == Globals.localUser!.uid) {
      return Alignment.topRight;
    } else if (user == "admin") {
      return Alignment.topCenter;
    } else {
      return Alignment.topLeft;
    }
  }

  static Color getTextColor(String owner) {
    if (owner == "admin") {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }
}
