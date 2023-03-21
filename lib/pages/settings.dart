/* 
  This page shows the username, email and reputation of the user.
  It also allows the user to change their username.
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hottake/services/auth.dart';
import 'package:hottake/widgets/loading.dart';
import 'package:hottake/widgets/init.dart';
import '../shared/data.dart';
import '../services/connectivity.dart';
import '../services/database.dart';
import '../shared/styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();

  late TextEditingController _controllerUsername;
  late TextEditingController _controllerEmail;
  late bool usernameEditable;
  DatabaseService database = DatabaseService();
  int? _reputation;
  String? _username;
  late Future<Map<String, dynamic>?> _loaded;

  @override
  void initState() {
    usernameEditable = false;
    _loaded = database.getUserData;
    _controllerUsername = TextEditingController(text: "");
    _controllerEmail = Globals.localUser == null
        ? TextEditingController(text: "")
        : TextEditingController(text: Globals.localUser!.email);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _editUsername() {
    setState(() {
      if (usernameEditable == true &&
          Globals.localUser!.username != _controllerUsername.text) {
        database.updateUsername(_controllerUsername.text);
        Globals.localUser!.username = _controllerUsername.text;
      }
      usernameEditable = !usernameEditable;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Globals.localUser == null) {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }

    if (ConnectivityService.isOnline == false) {
      if (mounted) {
        Future.delayed(Duration.zero, () {
          Navigator.popAndPushNamed(context, '/init');
        });
      }
    }

    return FutureBuilder<Map<String, dynamic>?>(future: _loaded.catchError((e) {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
      return null;
    }), builder: (
      context,
      AsyncSnapshot<Map<String, dynamic>?> snap,
    ) {
      if (!snap.hasData) {
        return const Loading();
      }
      final map = snap.data;
      _reputation = map!['reputation'];
      _username = map['username'];
      if (Globals.localUser!.username != _controllerUsername.text) {//new
        Globals.localUser!.username = _username;
        _controllerUsername = TextEditingController(text: _username);
      }
      Globals.localUser!.reputation = _reputation;
      
      return Scaffold(
        appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            centerTitle: true,
            title: Text("Settings", style: TextStyles.title),
            leading: Globals.getIsWeb(context)
                ? Container()
                : IconButton(
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Go back',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Container(
                      height: 10,
                    ),
                    //Username
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          //Row 1
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextField(
                                maxLengthEnforcement:
                                    MaxLengthEnforcement.enforced,
                                maxLength: 16,
                                enabled: usernameEditable,
                                controller: _controllerUsername,
                                style: TextStyles.textField,
                                cursorColor: Colors.deepPurpleAccent,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.deepPurple),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepPurpleAccent),
                                  ),
                                  labelText: 'Username',
                                  labelStyle: TextStyle(
                                      color: Colors.deepPurpleAccent,
                                      letterSpacing: 0.5,
                                      height:
                                          0.1 //Issue with this widget so a custom style is used
                                      ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: IconButton(
                                  icon: usernameEditable
                                      ? const Icon(Icons.check_outlined)
                                      : const Icon(Icons.create),
                                  color: Colors.white,
                                  onPressed: _editUsername,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Email
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          enabled: false,
                          controller: _controllerEmail,
                          style: TextStyles.textField,
                          cursorColor: Colors.deepPurpleAccent,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.deepPurpleAccent),
                            ),
                            labelText: 'Email',
                            labelStyle: TextStyles.textFieldLabel,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Colors.grey[850],
                          surfaceTintColor: Colors.deepPurpleAccent,
                          child: Row(
                            children: [
                              Text(
                                "Reputation: ",
                                style: TextStyles.textField,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Globals.getReputationColour(
                                        _reputation),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    //log out button
                    Container(
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurpleAccent,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () async {
                          await _auth.signOut();
                          Future.delayed(Duration.zero, () {
                             Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      const Init(reset: true)),
                              ModalRoute.withName('/init'),
                            );
                          });
                        },
                        child: Text(
                          'Log out',
                          style: TextStyles.buttonDark,
                        ),
                      ),
                    ),
                    Expanded(flex: 5, child: Container())
                  ],
                ),
              )),
        ),
      );
    });
  }
}
