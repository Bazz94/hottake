import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/searching.dart';
import 'package:hottake/services/database.dart';
import 'package:hottake/services/presence.dart';
import 'package:hottake/services/server.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatState();
}

enum Phase { searching, debate, post, inactive }

class _ChatState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  Phase phase = Phase.searching;
  late String? opponentUsername = "waiting..."; //default value
  final chatController = TextEditingController();
  final scrollController = ScrollController();
  DatabaseService database = DatabaseService(uid: Globals.localUser!.uid);
  ServerService server = ServerService(uid: Globals.localUser!.uid);
  PresenceService presence = PresenceService(uid: Globals.localUser!.uid);
  bool opponentOffline = false;
  bool submittedReport = false; //flag used to stop user from deleting chat

  @override
  void initState() {
    server.requestChat.then((value) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() async {
    // Clean up the controller when the widget is disposed.
    chatController.dispose();
    presence.goOffline(Globals.chatID);
    Globals.chatID = null;
    Globals.stance = null;
    Globals.topic = null;
    Globals.opponentUser = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (phase == Phase.searching) {
      print("////chatID: ${Globals.chatID}");
      if (Globals.chatID != null) {
        final chatFuture = Provider.of<Future<Chat?>>(context, listen: true);
        chatFuture.then((chat) {
          if (chat != null) {
            print("////chat data received: ${chat.chatID}");
            if (chat.yay != null && chat.nay != null) {
              print("opponent has been found");
              presence.goOnline(Globals.chatID!);
              if (Globals.localUser!.uid == chat.yay!.uid) {
                opponentUsername = chat.nay?.username!;
              } else {
                opponentUsername = chat.yay?.username!;
              }
              setState(() {
                phase = Phase.debate;
              });
            }
          }
        });
      }
    }

    if (phase == Phase.debate) {
      if (Globals.opponentUser != null) {
        //
        //final opponentActive = Provider.of<bool?>(context);
        PresenceService.updateOpponentStatus();
        bool? opponentActive = PresenceService.opponentOnline;
        if (opponentActive != null) {
          print("//// 2.Opponent active: $opponentActive");
          print("opponent id: ${Globals.opponentUser!.uid}");
          print("my id: ${Globals.localUser!.uid}");
          if (opponentActive == false) {
            if (opponentOffline == false) {
              opponentOffline = true;
              database.sendMessage(
                  Globals.chatID!,
                  "    ${Globals.opponentUser!.username} has left the chat    ",
                  LocalUser(uid: "admin"));
              messages.add(ChatMessage(
                  content: "    ${Globals.opponentUser!.username} has left the chat    ",
                  owner:  "admin",
                  time: DateTime.now()
              ));
              phase = Phase.post;
            }
          }
        }
      }

      final chatList = Provider.of<List<ChatMessage>?>(context);
      if (chatList != null) {
        setState(() {
          messages = chatList;
        });
      }
    }

    if (phase == Phase.post) {
      //ask user to review opponent
    }


    print('//// phase: $phase');
    return phase == Phase.searching
        ? const Searching()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: SafeArea(
              child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: Text(
                        opponentUsername == null ? "none" : opponentUsername!),
                    actions: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Leave chat',
                      onPressed: () {
                        _onWillPop();
                      },
                    ),
                  ),
                  body: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          reverse: true,
                          child: Column(
                            children: [
                              Stack(
                                children: <Widget>[feedWidget()],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: phase == Phase.debate ? bottomTextBar() : Container()),
                    ],
                  )),
            ),
          );
    //);
  }

  Widget feedWidget() {
    return ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Align(
            alignment: MessageStyle.getAlignment(messages[index].owner),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: MessageStyle.getBubbleColor(messages[index].owner),
              ),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    messages[index].content,
                    style: TextStyle(
                        fontSize: 15,
                        color:
                            MessageStyle.getTextColor(messages[index].owner)),
                  ),
                  const SizedBox(
                    height: 6,
                  ),
                  Text(
                    '${messages[index].time.hour}:${messages[index].time.minute}',
                    style: TextStyle(
                        fontSize: 9,
                        color:
                            MessageStyle.getTextColor(messages[index].owner)),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget bottomTextBar() {
    return Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            child: Container(
              padding: const EdgeInsets.only(left: 10),
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 3,
                      minLines: 1,
                      cursorColor: Colors.deepPurpleAccent,
                      controller: chatController,
                      decoration: const InputDecoration(
                          hintText: "Write message...",
                          hintStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    height: 43,
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          database.sendMessage(Globals.chatID,
                              chatController.text, Globals.localUser!);
                          chatController.clear();
                          scrollController.jumpTo(messages.length - 1);
                        });
                      },
                      backgroundColor: Colors.deepPurple,
                      elevation: 0,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _onWillPop() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Exit"),
            content: const Text("Are you sure you want to leave the chat?"),
            actions: <Widget>[
              TextButton(
                child: const Text("YES"),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Home()),
                    ModalRoute.withName('/home'),
                  );
                },
              ),
              TextButton(
                child: const Text("NO"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    return Future.value(true);
  }
}
