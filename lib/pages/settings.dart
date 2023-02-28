import 'package:flutter/material.dart';
import 'package:hottake/services/auth.dart';
import "package:hottake/pages/loading.dart";

import '../services/init.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final AuthService _auth = AuthService();

  bool isLoading = false;

  late TextEditingController _controllerUsername;
  bool usernameEditable = false;

  @override
  void initState() {
    super.initState();
    _controllerUsername = TextEditingController(text: 'Cakemix7');
  }

  void _editUsername() {
    setState(() {
      usernameEditable = !usernameEditable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true ? Loading() : Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        title: const Text("Settings"),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Container(
                  height: 10,
                ),
                Row(
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
                Container(
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      primary: Colors.deepPurple,
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
              ],
            )),
      ),
    );
  }
}

/////////////////////////////////////////////////////////////////////////////
