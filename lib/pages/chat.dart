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

enum Phase { searching, debate, review, post }

enum DropDownItems { report, leave }

class _ChatState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  Phase phase = Phase.searching;
  String? opponentUsername = "waiting..."; //default value
  final chatController = TextEditingController();
  final scrollController = ScrollController();
  DatabaseService database = DatabaseService(uid: Globals.localUser!.uid);
  ServerService server = ServerService(uid: Globals.localUser!.uid);
  PresenceService presence = PresenceService(uid: Globals.localUser!.uid);
  bool opponentOffline = false;
  bool submittedReport = false; //flag used to stop user from deleting chat
  bool postMessageSentOnce = false;
  DropDownItems? dropDownItem;
  bool chatSearchOnce = false;

  @override
  void initState() {
    print("//// chat called");
    super.initState();
  }

  @override
  void dispose() async {
    // Clean up the controller when the widget is disposed.
    presence.goOffline(Globals.chatID);
    chatController.dispose();
    Globals.chatID = null;
    Globals.opponentUser = null;
    messages.clear();
    print("//// dispose chat screen");
    super.dispose();
    
  }

  @override
  Widget build(BuildContext context) {
    //Searching

    if (phase == Phase.searching) {
      if (chatSearchOnce == false) {
         chatSearchOnce = true;
         server.requestChat.then((value) {
          setState(() {
            if (value == null) {
              print("//// error getting chat");
              Navigator.popAndPushNamed(context, '/home');
            }
            });
        });
      }
      
      print("//// chatID: ${Globals.chatID}");

      if (Globals.chatID != null) {
        final chatFuture = Provider.of<Future<Chat?>>(context, listen: true);
        chatFuture.then((chat) {
          if (chat != null) {
            print("////chat data received: ${chat.chatID}");
            presence.goOnline(Globals.chatID!);
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

    //Debating
    if (phase == Phase.debate) {
      if (Globals.opponentUser != null) {
        final opponentActive = Provider.of<bool?>(context);
        final chatFuture = Provider.of<Future<Chat?>>(context, listen: true);

        chatFuture.then((chat) {
          if (chat != null) {
            if (chat.active == false) {
              setState(() {
                phase = Phase.review;
              });
            }
          }
        });

        if (opponentActive != null) {
          print("//// Opponent active: $opponentActive");
          if (opponentActive == false) {
            if (opponentOffline == false) {
              opponentOffline = true;
              database.sendMessage(
                  Globals.chatID!,
                  "    ${Globals.opponentUser!.username} has left the chat    ",
                  LocalUser(uid: "admin"));
              messages.add(ChatMessage(
                  content:
                      "    ${Globals.opponentUser!.username} has left the chat    ",
                  owner: "admin",
                  time: DateTime.now()));
              setState(() {
                phase = Phase.review;
              });
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

    //Review
    if (phase == Phase.review) {
      //ask user to review opponent
      if (postMessageSentOnce == false) {
        setState(() {
          postMessageSentOnce = true;
          messages.add(ChatMessage(
              content: "    How was your interaction?    ",
              owner: "admin",
              time: DateTime.now()));
        });
      }
    }

    //Post
    if (phase == Phase.post) {}

    return phase == Phase.searching
        ? const Searching()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: SafeArea(
              child: Scaffold(
                  appBar: AppBar(
                    centerTitle: true,
                    title: titleWidget(),
                    actions: [
                      phase != Phase.debate ? Container() : endButton(),
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
                          child: bottomInteractions(phase)),
                    ],
                  )),
            ),
          );
  }

  //// Utility functions

  Widget bottomInteractions(Phase phase) {
    if (phase == Phase.debate) {
      return bottomTextBar();
    }
    if (phase == Phase.review) {
      return reviewButtons();
    }
    if (phase == Phase.post) {
      return nextButton();
    }
    return Container();
  }

  //// Widgets

  Widget endButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
      ),
      onPressed: () {
        //End chat
        setState(() {
          database.endChat();
          database.sendMessage(
            Globals.chatID,
            "${Globals.localUser!.username} has ended the chat",
            LocalUser(uid: "admin"),
          );
        });
      },
      child: const Text(
        'End',
        style: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget titleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(opponentUsername == null ? "none" : opponentUsername!),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Globals.opponentUser != null 
                ? Globals.getReputationColour(Globals.opponentUser!.reputation!)
                : Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        )
      ],
    );
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

  Widget nextButton() {
    return Row(
      children: [
        //button Next
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
              child: Card(
                  color: Colors.deepPurpleAccent,
                  child: InkWell(
                    onTap: () async {
                      //Start Searching for new opponent
                      print("//// Next Pressed!");
                      await presence.goOffline(Globals.chatID); 
                      Navigator.popAndPushNamed(context, '/loading');
                    },
                    child: const Center(
                      child: Text("Next",
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget reviewButtons() {
    return Row(
      children: [
        //button Good
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 2, 1, 2),
              child: Card(
                  color: Colors.green,
                  child: InkWell(
                    onTap: () {
                      //
                      database.sendReview("good");
                      setState(() {
                        messages.add(ChatMessage(
                            content: "    Good    ",
                            owner: "admin",
                            time: DateTime.now()));
                        phase = Phase.post;
                      });
                    },
                    child: const Center(
                      child: Text("Good",
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  )),
            ),
          ),
        ),
        //button Bad
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(1, 2, 2, 2),
              child: Card(
                  color: Colors.redAccent,
                  child: InkWell(
                    onTap: () {
                      //
                      database.sendReview("bad");
                      setState(() {
                        messages.add(ChatMessage(
                            content: "    Bad    ",
                            owner: "admin",
                            time: DateTime.now()));
                        phase = Phase.post;
                      });
                    },
                    child: const Center(
                      child: Text("Bad",
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                    ),
                  )),
            ),
          ),
        ),
      ],
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
