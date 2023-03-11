import 'package:flutter/cupertino.dart';
import 'package:hottake/pages/chat.dart';
import 'package:hottake/services/presence.dart';
import 'package:provider/provider.dart';


import '../models/data.dart';
import '../services/database.dart';

class ChatInit extends StatelessWidget {
  const ChatInit({Key? key}) : super(key: key);

  
  @override
  Widget build(BuildContext context) {

    return MultiProvider(providers: [
        StreamProvider<Future<Chat?>>(
          create: (context) => DatabaseService().chats,
          initialData: Future.value(null),
        ),
      StreamProvider<List<ChatMessage>?>(
        create: (context) => DatabaseService().messages,
        initialData: null,
      ),
      StreamProvider<bool?>(
        create: (context) => PresenceService(uid: Globals.localUser!.uid).opponentStatus,
        initialData: null,
      ),
      ], child: ChatScreen()
    );
  }
}
