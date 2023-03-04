import "package:cloud_firestore/cloud_firestore.dart";
import 'package:hottake/models/data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hottake/services/auth.dart';
import 'package:hottake/services/presence.dart';

class DatabaseService {
  late String? uid = AuthService().getUid;
  static int key = 1;
  DatabaseService({this.uid});

  //Get user collection
  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  //updates to firestore and will create if there is no doc
  Future updateUserData(String username, int reputation, int impact) async {
    return await _usersCollection.doc(uid).set({
      'username': username,
      'reputation': reputation,
      'impact': impact,
    });
  }

  //Get users stream
  Stream<DocumentSnapshot?> get users {
    return _usersCollection.doc(uid).snapshots();
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

  sendMessage(String? chatID, String message, LocalUser owner) {
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
        .snapshots().map(_snapToMessages);
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

      // .collection("messages")
      // .orderBy("time", "asc")


  //get Info from chat
  Stream<Future<Chat?>> get chats {
    return _chatsCollection.doc(Globals.chatID).snapshots().map(_snapToChat);
  }

  Future<Chat?> _snapToChat(DocumentSnapshot? doc) async {
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      LocalUser? nay, yay;
      bool active;
      if (Globals.stance == 'yay') {
        yay = Globals.localUser!;
        nay = await idToLocalUser(data['nay']);
        Globals.opponentUser = nay;
      } else {
        yay = await idToLocalUser(data['yay']);
        Globals.opponentUser = yay;
        nay = Globals.localUser!;
      }
      active = data['active'] == "true" ? true : false;
      return Chat(
        chatID: Globals.chatID!,
        topic: Globals.topic!,
        active: active,
        yay: yay,
        nay: nay,
      );
    }
    return null;
  }

  Future<LocalUser?> idToLocalUser(String? id) async {
    String? username;
    if (id != null && id != "null") {
      await _usersCollection.doc(id).get().then((doc) {
        print("////opponent: ${doc.data()}");
        final data = doc.data() as Map<String, dynamic>;
        username = data['username'];
      });
      return LocalUser(uid: id, username: username!);
    }
    return null;
  }
}
