import 'package:flutter/material.dart';

class Globals{
  static LocalUser? localUser;
  static LocalUser? opponentUser;
  static Topic? topic;
  static String? stance;
  static String? chatID;
}

enum Owner{
  receiver,sender
}

class LocalUser {
  final String uid;
  String? username;
  final String? email;
  int? reputation;                 //Value out of 10
  int? impact;                   //amount of minds changed
  LocalUser({
      required this.uid,
      this.username,
      this.email,
      this.reputation,
      this.impact,
  });
}

class Topic {
  String title;
  String description;
  String? image;
  Topic({required this.title,
         required this.description,
         this.image,
  });
}

class ChatMessage {
  String content;
  String owner;
  DateTime time;
  ChatMessage({required this.content, required this.owner,required this.time});
}

class Chat {
  String chatID;
  LocalUser? yay;
  LocalUser? nay;
  Topic topic;
  bool active;
  late List<ChatMessage> messages;
  Chat({required this.chatID,
        required this.topic,
        required this.active,
        this.yay,
        this.nay,
  });
}

class MessageStyle{
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
