import 'package:firebase_database/firebase_database.dart';
import 'package:hottake/shared/data.dart';
import 'package:hottake/services/connectivity.dart';

class PresenceService {
  static bool _isOnline = false;
  static bool? opponentOnline;
  

  static final _presenceRef = FirebaseDatabase.instance.ref("presence/");

  static goOnline(String chatID) async {
    if (_isOnline != true && ConnectivityService.isOnline) {
      String uid = Globals.localUser!.uid;
      print('//// Go online: $chatID');
      try {
        _isOnline = true;
        await _presenceRef.child("$chatID/$uid").set({
          'active': true,
        });
        await _presenceRef.child("$chatID/$uid").onDisconnect().set({
          'active': false,
        });
      } catch (error) {
        print("//// goOnline: ${error.toString()}");
      }
    }
  }

  static goOffline(String chatID) async {
    if (_isOnline == true && ConnectivityService.isOnline) {
      String uid = Globals.localUser!.uid;
      print("//// Go offline $chatID");
      try {
        await _presenceRef.child("$chatID/$uid").set({'active': false});
        await _presenceRef.child("$chatID/$uid").onDisconnect().cancel();
        _isOnline = false;
      } catch (error) {
        print("//// goOffline: ${error.toString()}");
      }
    } else {
      print("//// goOffline called but already offline");
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
