import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:hottake/pages/chat.dart';
import 'package:hottake/services/presence.dart';
import 'package:provider/provider.dart';
import '../shared/data.dart';
import '../services/connectivity.dart';
import '../services/database.dart';
import '../services/server.dart';
import '../widgets/loading.dart';

class ChatInit extends StatefulWidget {
  const ChatInit({Key? key}) : super(key: key);

  @override
  State<ChatInit> createState() => _ChatInitState();
}

class _ChatInitState extends State<ChatInit> {
  ServerService server = ServerService();
  late Future<bool> _loaded;

  @override
  void initState() {
    print("//// init initChat ");
    _loaded = getChat;
    ConnectivityService.subscription.onData((result) {
      setState(() {
        print("////2 Connection status: ${result.toString()}");
        if (result != ConnectivityResult.none) {
          ConnectivityService.isOnline = true;
        } else {
          ConnectivityService.isOnline = false;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (Globals.chatID != null) {
      PresenceService.goOffline(Globals.chatID!);
    }
    ConnectivityService.dispose;
    print("//// dispose initChat");
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
                Future.delayed(Duration.zero, () {
                  Navigator.popAndPushNamed(context, '/init');
                });
                
                return WillPopScope(
                  onWillPop: () async {
                    if(Globals.chatID != null) {
                      await PresenceService.goOffline(Globals.chatID!);
                    }
                    Future.delayed(Duration.zero, () {
                      Navigator.popAndPushNamed(context, '/init');
                    });
                    return Future.value(true);
                  },
                  child: const Loading()
                  );
              }
            },
        ));
  }
}