import 'package:firebase_database/firebase_database.dart';
import 'package:hottake/models/data.dart';

class PresenceService {
  String uid;
  static bool isOnline = false;
  PresenceService({required this.uid});

  static final presenceRef = FirebaseDatabase.instance.ref("presence/");

  goOnline(String chatID) async {
    if (isOnline != true) {
      print('////Go online');
      isOnline = true;
      await presenceRef.child("$chatID/$uid").set({
        'active': "true"
      });
      await presenceRef.child("$chatID/$uid").onDisconnect().set({
        'active': "false"
      });
    }
  }

  goOffline(String? chatID) async {
    if (isOnline == true) {
      await presenceRef.child("$chatID/$uid").set({
        'active': "false"
      });
      isOnline = false;
      print("////Go offline");
    }
  }

  Stream<bool?> get opponentStatus {
    return presenceRef.child("${Globals.chatID}/${Globals.opponentUser!.uid}/active").onValue.map(_snapToBool);
  }

  bool? _snapToBool(DatabaseEvent event){
    dynamic value = event.snapshot.value;
    if (value != null) {
      return value == "true" ? true : false;
    }
    return null;
  }
}