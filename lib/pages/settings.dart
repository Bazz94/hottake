import 'package:flutter/material.dart';
import 'package:hottake/services/auth.dart';
import "package:hottake/pages/loading.dart";

import '../models/data.dart';


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

  @override
  void initState() {
    super.initState();
    usernameEditable = false;
    _controllerUsername = Globals.localUser!.username == null 
      ? TextEditingController(text: 'placeholder')
      : TextEditingController(text: Globals.localUser!.username);
    _controllerEmail = Globals.localUser!.email == null
        ? TextEditingController(text: 'placeholder')
        : TextEditingController(text: Globals.localUser!.email);
        print("//// Username: ${Globals.localUser!.username}");
  }

  void _editUsername() {
    setState(() {
      print("//// flag 1 $usernameEditable");
      print("//// flag 2: ${_controllerUsername.text}");
      print("//// flag 3: ${Globals.localUser!.username}");
      if(usernameEditable == true 
       && Globals.localUser!.username != _controllerUsername.text) {
        _auth.updateUsername(_controllerUsername.text);
        print("//// Username changed");
      }
      usernameEditable = !usernameEditable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true ? const Loading() : Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        title: const Text("Settings"),
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
                  child: Row(
                    //Row 1
                    children: [
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            enabled: usernameEditable,
                            controller: _controllerUsername,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.deepPurpleAccent,
                            decoration: const InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurple),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.deepPurpleAccent),
                              ),
                              labelText: 'Username',
                              labelStyle:
                                  TextStyle(color: Colors.deepPurpleAccent),
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
                // Email
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      enabled: false,
                      controller: _controllerEmail,
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.deepPurpleAccent,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurple),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.deepPurpleAccent),
                        ),
                        labelText: 'Email',
                        labelStyle:
                            TextStyle(color: Colors.deepPurpleAccent),
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
                          const Text(
                            "Reputation: ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Globals.getReputationColour(
                                          Globals.localUser!.reputation!),
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
                      foregroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                        setState(() => isLoading = true);
                        Navigator.pushNamed(context, '/init');
                        try {
                          await _auth.signOut();
                        } catch (e) {
                          setState(() => isLoading = false);
                          print(e.toString());
                        }
                    },
                    child: const Text(
                      'Log out',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container())
              ],
            )),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////
