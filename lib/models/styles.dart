import 'package:flutter/material.dart';
import 'data.dart';

class TextStyles {
  static TextStyle title = const TextStyle(
    color: Colors.white,
    fontSize: 24,
    letterSpacing: 0.5,
  );
  static TextStyle titleError = const TextStyle(
    color: Colors.red,
    fontSize: 20,
    letterSpacing: 0.5,
  );
  static TextStyle textField = const TextStyle(
    color: Colors.white,
    fontSize: 20,
    letterSpacing: 0.5,
  );
  static TextStyle textFieldLabel = const TextStyle(
    color: Colors.deepPurpleAccent, 
    letterSpacing: 0.5
  );
  static TextStyle buttonLight = const TextStyle(
    color: Colors.black,
    fontSize: 20,
    letterSpacing: 0.5,
  );
  static TextStyle buttonPurple = const TextStyle(
    color: Colors.white,
    fontSize: 20,
    letterSpacing: 0.5,
  );
  static TextStyle buttonDark = const TextStyle(
    color: Colors.deepPurpleAccent,
    fontSize: 20,
    letterSpacing: 0.5,
  );
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
