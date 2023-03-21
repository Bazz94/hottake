/*
  Loads after a topic and stance has been picked. A http request is sent to create a chat room
  and return the chat id. The loading widget is displayed while waiting for a chat id. After 
  the chat id is received the Chat Screen is loaded.        
*/
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hottake/pages/chat.dart';
import 'package:hottake/services/presence.dart';
import 'package:hottake/widgets/error.dart';
import 'package:provider/provider.dart';
import '../shared/data.dart';
import '../services/connectivity.dart';
import '../services/database.dart';
import '../services/server.dart';
import 'loading.dart';

class ChatInit extends StatefulWidget {
  const ChatInit({Key? key}) : super(key: key);

  @override
  State<ChatInit> createState() => _ChatInitState();
}

class _ChatInitState extends State<ChatInit> {
  ServerService server = ServerService();
  late Future<bool> _loaded;
  ConnectivityService connectivity = ConnectivityService();
  

  @override
  void initState() {
    connectivity.subscription.onData((result) {
      if (kDebugMode) {
        print("//// Connection status: ${result.toString()}");
      }
      if (result != ConnectivityResult.none) {
        ConnectivityService.isOnline = true;
      } else {
        ConnectivityService.isOnline = false;
      }
      setState(() {});
    });
    _loaded = getChat;
    super.initState();
  }

  @override
  void dispose() {
    if (Globals.chatID != null) {
      PresenceService.goOffline(Globals.chatID!);
    }
    connectivity.dispose;
    super.dispose();
  }

  Future<bool> get getChat async{
    String? chatID = await server.requestChat;
    if (chatID == null) {
      return false;
    } 
    PresenceService.goOnline(chatID);
    return true;
  }

  @override
  Widget build(BuildContext context) {

    if (ConnectivityService.isOnline == false) {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }

    return MultiProvider(providers: [
      StreamProvider<Future<Chat?>>(
        create: (context) => DatabaseService.chats,
        initialData: Future.value(null),
      ),
      StreamProvider<List<ChatMessage>?>(
        create: (context) => DatabaseService().messages,
        initialData: null,
      ),
      StreamProvider<bool?>(
        create: (context) =>
            PresenceService().opponentStatus,
        initialData: null,
      ),
    ], child: FutureBuilder<bool>(
          future: _loaded,
          builder: (
            BuildContext context,
            AsyncSnapshot<bool> snap,) 
            {
              if (!snap.hasData) {
                return const Loading();
              }
              
              if (snap.data!) { 
                return const ChatScreen();
              } else {
                return const ErrorPage();
              }
            },
        )
    );
  }
}