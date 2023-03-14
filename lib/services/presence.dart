import 'package:firebase_database/firebase_database.dart';
import 'package:hottake/models/data.dart';

class PresenceService {
  String uid;
  static bool _isOnline = false;
  static bool? opponentOnline;
  static bool _queueOffline = false;
  static String? _localChatID;
  PresenceService({required this.uid});

  static final _presenceRef = FirebaseDatabase.instance.ref("presence/");

  goOnline(String chatID) async {
    if (_isOnline != true) {
      _localChatID = chatID;
      print('//// Go online');
      try {
        _isOnline = true;
        await _presenceRef.child("$chatID/$uid").set({
          'active': true,
        });
        await _presenceRef.child("$chatID/$uid").onDisconnect().set({
          'active': false,
        });
        if (_queueOffline == true) {
          goOffline();
          _queueOffline = false;
        }
      } catch (error) {
        print("//// goOnline: ${error.toString()}");
      }
    }
  }

  goOffline() async {
    if (_isOnline == true) {
      try {
        await _presenceRef.child("$_localChatID/$uid").set({'active': false});
        await _presenceRef.child("$_localChatID/$uid").onDisconnect().cancel();
        _isOnline = false;
        print("//// Go offline");
      } catch (error) {
        print("//// goOffline: ${error.toString()}");
      }
    } else {
      print("//// goOffline called but already offline");
      _queueOffline = true;
    }
  }

  Stream<bool?> get opponentStatus {
    DatabaseReference childRef = _presenceRef
        .child("${Globals.chatID}/${Globals.opponentUser!.uid}/active");
    return childRef.onValue.map(_snapToBool).handleError((error) {
      print("//// get opponentStatus ${error.toString()}");
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
