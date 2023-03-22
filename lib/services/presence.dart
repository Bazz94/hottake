/* 
  This class creates a chat doc in the Firebase Realtime Database. The chat doc has the
  user that are connected to the chat room as children and user has a value called 
  active. When a user joins a chat then the chat id doc is create and the users active 
  value is set to true. When a user leaves the chat then the active value is set to false.
  This data is kept on the Realtime Database since firestore does not have an onDisconnect
  function. onDisconnect will set active to false in the case that the user closes their
  app or disconnects from the internet.  
*/

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:hottake/shared/data.dart';
import 'package:hottake/services/connectivity.dart';

class PresenceService {
  static bool _isOnline = false;
  static bool? opponentOnline;
  
  static final _presenceRef = FirebaseDatabase.instance.ref("presence/");

  static goOnline(String chatID, String topic) async {
    if (_isOnline != true && ConnectivityService.isOnline) {
      String uid = Globals.localUser!.uid;
      if (kDebugMode) {
        print("//// Go online $chatID $topic");
      }
      try {  // '/chats/'
        _isOnline = true;
        await _presenceRef.child("$topic/chats/$chatID/$uid").set({
          'active': true,
        });
        await _presenceRef.child("$topic/chats/$chatID/$uid").onDisconnect().set({
          'active': false,
        });
      } catch (error) {
        if (kDebugMode) {
          print("//// goOnline error: ${error.toString()}");
        }
      }
    }
  }

  static goOffline(String chatID, String topic) async {
    if (_isOnline == true && ConnectivityService.isOnline) {
      String uid = Globals.localUser!.uid;
      if (kDebugMode) {
        print("//// Go offline $chatID $topic");
      }
      try {
        await _presenceRef.child("$topic/chats/$chatID/$uid").set({'active': false});
        await _presenceRef.child("$topic/chats/$chatID/$uid").onDisconnect().cancel();
        _isOnline = false;
      } catch (error) {
        if (kDebugMode) {
          print("//// goOffline error: ${error.toString()}");
        }
      }
    } else {
      if (kDebugMode) {
        print("//// goOffline called but already offline");
      }
    }
  }

  Stream<bool?> get opponentStatus {
    DatabaseReference childRef = _presenceRef
        .child("${Globals.topic!.title}/chats/${Globals.chatID}/${Globals.opponentUser!.uid}/active");
    return childRef.onValue.map(_snapToBool).handleError((error) {
      if (kDebugMode) {
        print("//// get opponentStatus error: ${error.toString()}");
      }
    });
  }

  bool? _snapToBool(DatabaseEvent event) {
    dynamic value = event.snapshot.value;
    if (value != null) {
      return value;
    }
    return null;
  }
}
