import "package:cloud_firestore/cloud_firestore.dart";
import 'package:hottake/models/data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hottake/services/auth.dart';

class DatabaseService {
  late String? uid = AuthService().getUid;
  DatabaseService({this.uid});

  //Get user collection
  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  //updates to firestore and will create if there is no doc
  Future updateUserData(int reputation) async {
    return await _usersCollection.doc(uid).set({
      'reputation': reputation,
    });
  }

  Future<int?> get getReputation async {
    DocumentSnapshot doc = await _usersCollection.doc(uid).get();
    final data = doc.data() as Map<String, dynamic>;
    return data['reputation'];
  }

  //Get topics collection
  static final CollectionReference _topicsCollection =
      FirebaseFirestore.instance.collection('topics');

  Future<List<Topic>> get topics async {
    List<Future<Topic>>? futureList;
    List<Topic> list = <Topic>[];
    await _topicsCollection.get().then(
        (snap) => {
              futureList = snap.docs.map((doc) async {
                final data = doc.data() as Map<String, dynamic>;
                String? imageURL = '';
                imageURL = await _downloadURL(data['image']);
                return Topic(
                  title: data['title'],
                  description: data['description'] ?? '',
                  image: imageURL,
                );
              }).toList(),
            },
        onError: (e) => print(e.toString()));
    for (var futureTopic in futureList!) {
      await futureTopic.then((topic) => {
            list.add(topic),
          });
    }
    return list;
  }

  Future<String?> _downloadURL(String path) async {
    try {
      final ref = FirebaseStorage.instance.ref();
      String url = await ref.child(path).getDownloadURL();
      return url;
    } catch (e) {
      String msg = e.toString();
    }
    return null;
  }

  //Get chats collection
  static final CollectionReference _chatsCollection =
      FirebaseFirestore.instance.collection('chats');

  void sendMessage(String? chatID, String message, LocalUser owner) {
    Map<String, dynamic> data = {
      'content': message,
      'owner': owner.uid,
      'time': DateTime.now()
    };
    if (chatID != null) {
      _chatsCollection.doc(chatID).collection("messages").add(data);
    } else {
      print("////message could not be sent");
    }
  }

  //stream for reading chat
  Stream<List<ChatMessage>?> get messages {
    return _chatsCollection
        .doc(Globals.chatID)
        .collection("messages")
        .orderBy("time")
        .limit(100)
        .snapshots()
        .map(_snapToMessages);
  }

  List<ChatMessage> _snapToMessages(QuerySnapshot snap) {
    List<ChatMessage> list = [];
    for (var doc in snap.docs) {
      print("////chat message list: ${doc.data()}");
      if (doc.get('content') != "") {
        list.add(ChatMessage(
            content: doc.get('content'),
            owner: doc.get('owner'),
            time: DateTime.parse(doc.get('time').toDate().toString())));
      }
    }
    return list;
  }

  //get Info from chat
  Stream<Future<Chat?>> get chats {
    print("//// chat retrieved");
    return _chatsCollection.doc(Globals.chatID).snapshots().map(_snapToChat);
  }

  Future<Chat?> _snapToChat(DocumentSnapshot? doc) async {
    if (doc != null) {
      final data = doc.data();
      if (data != null) {
        final dataMap = data as Map<String, dynamic>;
        LocalUser? nay, yay;
        bool active;
        if (Globals.stance == 'yay') {
          yay = Globals.localUser!;
          nay = await uidToLocalUser(dataMap['nay']);
          Globals.opponentUser = nay;
        } else {
          yay = await uidToLocalUser(dataMap['yay']);
          Globals.opponentUser = yay;
          nay = Globals.localUser!;
        }
        active = dataMap['active'];
        print("////1 chatid: ${Globals.chatID}");
        print("////1 topic: ${Globals.topic}");
        if (Globals.chatID != null && Globals.topic != null) {
          return Chat(
            chatID: Globals.chatID!,
            topic: Globals.topic!,
            active: active,
            yay: yay,
            nay: nay,
          );
        }
      }
    }
    return null;
  }

  Future<LocalUser?> uidToLocalUser(String? id) async {
    String? username;
    int? reputation;
    if (id != null && id != "null") {
      await _usersCollection.doc(id).get().then((doc) {
        print("////opponent: ${doc.data()}");
        final data = doc.data() as Map<String, dynamic>;
        username = data['username'];
        reputation = data['reputation'];
      });
      return LocalUser(uid: id, username: username!, reputation: reputation!);
    }
    return null;
  }

  void endChat() {
    _chatsCollection.doc(Globals.chatID).update({"active": false});
  }

  void sendReview(String? review) {
    if (Globals.stance == "nay") {
      _chatsCollection.doc(Globals.chatID).update({"nayReview": review});
    } else {
      _chatsCollection.doc(Globals.chatID).update({"yayReview": review});
    }
  }
}
