import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hottake/services/auth.dart';
import "package:hottake/pages/loading.dart";
import 'package:hottake/services/init.dart';
import '../models/data.dart';
import '../models/styles.dart';
import '../services/connectivity.dart';
import '../services/database.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _auth = AuthService();

  bool isLoading = false;

  late TextEditingController _controllerUsername;
  late TextEditingController _controllerEmail;
  late bool usernameEditable;
  DatabaseService database = DatabaseService();

  @override
  void initState() {
    database.getReputation.then((reputation) {
      if (reputation != null) {
        setState(() {
          Globals.localUser!.reputation = reputation;
        });
      }
    });
    usernameEditable = false;
    _controllerUsername = Globals.localUser!.username == null
        ? TextEditingController(text: 'placeholder')
        : TextEditingController(text: Globals.localUser!.username);
    _controllerEmail = Globals.localUser!.email == null
        ? TextEditingController(text: 'placeholder')
        : TextEditingController(text: Globals.localUser!.email);

    super.initState();
  }

  @override
  void dispose() {
    print("//// dispose settings page");
    super.dispose();
  }

  void _editUsername() {
    setState(() {
      if (usernameEditable == true &&
          Globals.localUser!.username != _controllerUsername.text) {
        _auth.updateUsername(_controllerUsername.text);
      }
      usernameEditable = !usernameEditable;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Globals.localUser == null) {
      print("//// uid is null on settings");
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

    return isLoading == true
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              // Here we take the value from the MyHomePage object that was created by
              // the App.build method, and use it to set our appbar title.
              centerTitle: true,
              title: Text("Settings", style: TextStyles.title),
            ),
            resizeToAvoidBottomInset: false,
            body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                                        height: 0.1 //Issue with this widget so a custom style is used
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
                                borderSide:
                                    BorderSide(color: Colors.deepPurple),
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
                                          Globals.localUser!.reputation),
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
                            setState(() => isLoading = true);
                            await _auth.signOut();
                            Future.delayed(Duration.zero, () {
                              //Navigator.pop(context);
                              bool reset = true;
                              Navigator.popAndPushNamed(context, '/init');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Init(reset: true),
                                ),
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
                  )),
            ),
          );
  }
}
