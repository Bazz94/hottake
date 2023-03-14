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

  Future<int?> get getReputation async {
    try {
      DocumentSnapshot doc =
          await _usersCollection.doc(Globals.localUser!.uid).get();
      final data = doc.data();
      final dataMap = data as Map<String, dynamic>;
      return dataMap['reputation'];
    } catch (error) {
      print("//// getReputation: ${error.toString()}");
      return null;
    }
  }

  //Get topics collection
  static final CollectionReference _topicsCollection =
      FirebaseFirestore.instance.collection('topics');

  Future<List<Topic>> get topics async {
    List<Future<Topic>>? futureList;
    List<Topic> list = <Topic>[];
    await _topicsCollection
        .get()
        .then((snap) => {
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
            })
        .catchError((error) {
      print("//// get topics: ${error.toString()}");
    });
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
      print(e.toString());
      return null;
    }
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
      _chatsCollection
          .doc(chatID)
          .collection("messages")
          .add(data)
          .catchError((error) {
        print("//// sendMessage: ${error.toString()}");
      });
    } else {
      print("//// ChatID is null");
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
        .map(_snapToMessages)
        .handleError((error) {
      print("//// get messages: ${error.toString()}");
    });
  }

  List<ChatMessage> _snapToMessages(QuerySnapshot snap) {
    List<ChatMessage> list = [];
    for (var doc in snap.docs) {
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
    return _chatsCollection
        .doc(Globals.chatID)
        .snapshots()
        .map(_snapToChat)
        .handleError((error) {
      print("//// get chats: ${error.toString()}");
    });
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
          nay = await _uidToLocalUser(dataMap['nay']);
          Globals.opponentUser = nay;
        } else {
          yay = await _uidToLocalUser(dataMap['yay']);
          Globals.opponentUser = yay;
          nay = Globals.localUser!;
        }
        active = dataMap['active'];
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

  Future<LocalUser?> _uidToLocalUser(String? id) async {
    String? username;
    int? reputation;
    if (id != null && id != "null") {
      await _usersCollection.doc(id).get().then((doc) {
        print("//// opponent: ${doc.data()}");
        final data = doc.data() as Map<String, dynamic>;
        username = data['username'];
        reputation = data['reputation'];
      }).catchError((error) {
        print("//// _uidToLocalUser: ${error.toString()}");
        return null;
      });
      return LocalUser(uid: id, username: username!, reputation: reputation!);
    } else {
      return null;
    }
  }

  void endChat() {
    _chatsCollection
        .doc(Globals.chatID)
        .update({"active": false}).catchError((error) {
      print("//// endChat: ${error.toString()}");
    });
  }

  void sendReview(String? review) {
    try {
      if (Globals.stance == "nay") {
        _chatsCollection.doc(Globals.chatID).update({"nayReview": review});
      } else {
        _chatsCollection.doc(Globals.chatID).update({"yayReview": review});
      }
    } catch (error) {
      print("//// sendReview: ${error.toString()}");
    }
  }

  Future updateUserData(String username) async {
    return await _usersCollection
        .doc(Globals.localUser!.uid)
        .update({'username': username}).catchError((error) {
      print("//// updateUserData: ${error.toString()}");
    });
  }
}
