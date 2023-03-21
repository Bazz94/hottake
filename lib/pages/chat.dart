/* 
  After receiving a chat id this page is loaded in and the searching widget is displayed.
  When an opponent has been found then the chat UI loads in and the users can discuss the
  topic. A user can end the chat and is then asked to review the interaction with the
  opposing user. A button is displayed so that the user can queue for another chat with 
  the same topic and stance.
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hottake/shared/data.dart';
import 'package:hottake/widgets/searching.dart';
import 'package:hottake/services/database.dart';
import 'package:hottake/services/presence.dart';
import 'package:provider/provider.dart';
import '../services/connectivity.dart';
import '../shared/styles.dart';
import '../widgets/init.dart';
// import 'dart:html' as html;                             //comment out for android build then see line 66

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
  DatabaseService database = DatabaseService();
  final focusNode = FocusNode();

  bool opponentOffline = false;
  bool submittedReport = false;
  bool postMessageSentOnce = false;
  DropDownItems? dropDownItem;
  bool chatSearchOnce = false;

  @override
  void initState() {
    if (kDebugMode) {
      print("//// init chat");
    }
    super.initState();
  }

  @override
  void dispose() {
    chatController.dispose();
    if (kDebugMode) {
      print("//// dispose chat");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // if (kIsWeb) {                                      // Comment out for android build
    //   html.window.onBeforeUnload.listen((event) {
    //     Future.delayed(Duration.zero, () {
    //       Navigator.pop(context);
    //     });
    //   });
    // }
    //Searching

    if (ConnectivityService.isOnline == false) {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }

    if (phase == Phase.searching) {
      if (Globals.chatID != null) {
        final chatFuture = Provider.of<Future<Chat?>>(context, listen: true);
        chatFuture.then((chat) {
          if (chat != null) {
            if (kDebugMode) {
              print("//// chat data received: ${chat.chatID}");
            }

            if (chat.yay != null && chat.nay != null) {
              if (kDebugMode) {
                print("//// opponent has been found");
              }
              if (Globals.localUser!.uid == chat.yay!.uid) {
                opponentUsername = chat.nay!.username!;
              } else {
                opponentUsername = chat.yay!.username!;
              }
              if (mounted) {
                setState(() {
                  phase = Phase.debate;
                });
              }
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
              if (mounted) {
                setState(() {
                  phase = Phase.review;
                });
              }
            }
          }
        });

        if (opponentActive != null) {
          if (kDebugMode) {
            print("//// Opponent active: $opponentActive");
          }
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
        postMessageSentOnce = true;
        setState(() {
          messages.add(ChatMessage(
              content: "    How was your interaction?    ",
              owner: "admin",
              time: DateTime.now()));
        });
      }
    }

    return phase == Phase.searching
        ? const Searching()
        : WillPopScope(
            onWillPop: _onWillPop,
            child: SafeArea(
              child: Scaffold(
                  appBar: AppBar(
                      centerTitle: true,
                      title: getTitleWidget(),
                      actions: [
                        phase != Phase.debate ? Container() : endButton(),
                      ],
                      leading: Globals.getIsWeb(context)
                          ? Container()
                          : IconButton(
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'Leave chat',
                              onPressed: () {
                                _onWillPop();
                              },
                            )),
                  body: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              reverse: true,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: <Widget>[feedWidget()],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          bottomInteractions(phase),
                        ],
                      ),
                    ),
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
        database.endChat();
        database.sendMessage(
          Globals.chatID,
          "${Globals.localUser!.username} has ended the chat",
          LocalUser(uid: "admin"),
        );
        setState(() {});
      },
      child: Text(
        'End',
        style: TextStyles.buttonPurple,
      ),
    );
  }

  Widget getTitleWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(opponentUsername == null ? "none" : opponentUsername!,
            style: TextStyles.title),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Globals.opponentUser != null
                  ? Globals.getReputationColour(
                      Globals.opponentUser!.reputation!)
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
                      await PresenceService.goOffline(Globals.chatID!);
                      Navigator.popAndPushNamed(context, '/chat');
                    },
                    child: Center(
                      child: Text("Next", style: TextStyles.buttonPurple),
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
                    child: Center(
                      child: Text("Good", style: TextStyles.buttonPurple),
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
                    child: Center(
                      child: Text("Bad", style: TextStyles.buttonPurple),
                    ),
                  )),
            ),
          ),
        ),
      ],
    );
  }

  void _send() async {
    if (chatController.text.isNotEmpty) {
      database.sendMessage(
          Globals.chatID, chatController.text, Globals.localUser!);
    }
    if (kDebugMode) {
      print('//// sent Message: ${chatController.text}');
    }

    if (scrollController.hasClients) {
      scrollController.jumpTo(messages.length - 1);
    }
    chatController.clear();
    focusNode.requestFocus();
    setState(() {});
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
                      focusNode: focusNode,
                      inputFormatters: Globals.getIsWeb(context)
                          ? [FilteringTextInputFormatter.deny(RegExp(r"\n"))]
                          : null,
                      keyboardType: TextInputType.multiline,
                      textInputAction: Globals.getIsWeb(context)
                          ? TextInputAction.send
                          : TextInputAction.newline,
                      maxLines: 3,
                      minLines: 1,
                      maxLength: 1000,
                      onSubmitted: (value) {
                        _send();
                      },
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      style: const TextStyle(fontSize: 16),
                      cursorColor: Colors.deepPurpleAccent,
                      controller: chatController,
                      decoration: const InputDecoration(
                          counterText: "",
                          hintText: "Write a message...",
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
                        _send();
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
    if (Globals.getIsWeb(context)) {
      database.endChat();
       database.sendMessage(
        Globals.chatID,
        "${Globals.localUser!.username} has ended the chat",
        LocalUser(uid: "admin"),
      );
      PresenceService.goOffline(Globals.chatID!);
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => const Init()),
        ModalRoute.withName('/init'),
      );
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm chat exit"),
              content: const Text("Are you sure you want to leave the chat?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("YES"),
                  onPressed: () {
                    database.endChat();
                     database.sendMessage(
                      Globals.chatID,
                      "${Globals.localUser!.username} has ended the chat",
                      LocalUser(uid: "admin"),
                    );
                    PresenceService.goOffline(Globals.chatID!);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => const Init()),
                      ModalRoute.withName('/init'),
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
    }
    return Future.value(true);
  }
}
