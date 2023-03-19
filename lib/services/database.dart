import 'dart:typed_data';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:hottake/shared/data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hottake/services/auth.dart';

class DatabaseService {
  late String? uid = AuthService().getUid;
  DatabaseService({this.uid});

  //Get user collection
  static final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<Map<String, dynamic>?> get getUserData async {
    try {
      DocumentSnapshot doc =
          await _usersCollection.doc(Globals.localUser!.uid).get();
      final data = doc.data();
      final dataMap = data as Map<String, dynamic>;
      return dataMap;
    } catch (error) {
      
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
                Uint8List? imageURL;
                imageURL = await _downloadImages(data['image']);
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

  Future<Uint8List?> _downloadImages(String path) async {
    final ref = FirebaseStorage.instance.ref().child(path);
    try {
      const oneMegabyte = 1024 * 1024;
      final Uint8List? data = await ref.getData(oneMegabyte);
      return data;
    } on FirebaseException catch (e) {
      print("//// _downloadImages error: ${e.toString()}");
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
        print("//// sendMessage error: ${error.toString()}");
      });
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
      print("//// get messages error: ${error.toString()}");
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
  static Stream<Future<Chat?>> get chats {
    return _chatsCollection
        .doc(Globals.chatID)
        .snapshots()
        .map(_snapToChat)
        .handleError((error) {
    });
  }

  static Future<Chat?> _snapToChat(DocumentSnapshot? doc) async {
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

  static Future<LocalUser?> _uidToLocalUser(String? id) async {
    String? username;
    int? reputation;
    if (id != null && id != "null") {
      await _usersCollection.doc(id).get().then((doc) {
        final data = doc.data() as Map<String, dynamic>;
        username = data['username'];
        reputation = data['reputation'];
      }).catchError((error) {
        print("//// _uidToLocalUser error: ${error.toString()}");
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
      print("//// endChat error: ${error.toString()}");
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
      print("//// sendReview error: ${error.toString()}");
    }
  }

  Future updateUsername(String username) async {
    return await _usersCollection
        .doc(Globals.localUser!.uid)
        .update({'username': username}).catchError((error) {
      print("//// updateUsername error: ${error.toString()}");
    });
  }

  Future setUserData(String username, int reputation) async {
    return await _usersCollection.doc(Globals.localUser!.uid).set(
        {'username': username, 'reputation': reputation}).catchError((error) {
      print("//// updateUserData error: ${error.toString()}");
    });
  }
}
