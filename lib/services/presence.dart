import 'package:firebase_database/firebase_database.dart';
import 'package:hottake/models/data.dart';

class PresenceService {
  String uid;
  static bool isOnline = false;
  static bool? opponentOnline;
  static bool queueOffline = false;
  static String? localChatID;
  PresenceService({required this.uid});

  static final presenceRef = FirebaseDatabase.instance.ref("presence/");

  goOnline(String chatID) async {
    if (isOnline != true) {
      localChatID = chatID;
      print('//// Go online');
      isOnline = true;
      await presenceRef.child("$chatID/$uid").set({
        'active': true,
      });
      await presenceRef.child("$chatID/$uid").onDisconnect().set({
        'active': false,
        'onDisconnect': true
      });
      if (queueOffline == true) {
        goOffline();
        queueOffline = false;
      }
    }
  }

  goOffline() async {
    if (isOnline == true) {
      await presenceRef.child("$localChatID/$uid").set({
        'active': false
      });
      await presenceRef.child("$localChatID/$uid").onDisconnect().cancel();
      isOnline = false;
      print("//// Go offline");
    } else {
      print("//// goOffline called but already offline");
      queueOffline = true;
    }
  }

  Stream<bool?> get opponentStatus {
    DatabaseReference childRef = presenceRef.child("${Globals.chatID}/${Globals.opponentUser!.uid}/active");
    return childRef.onValue.map(_snapToBool);
  }

  bool? _snapToBool(DatabaseEvent event){
    dynamic value = event.snapshot.value;
    if (value != null) {
      return value;
    }
    return null;
  }
}