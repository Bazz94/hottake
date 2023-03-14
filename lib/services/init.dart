import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import 'auth.dart';

class Init extends StatefulWidget {
  const Init({Key? key}) : super(key: key);

  @override
  State<Init> createState() => _Init();
}

class _Init extends State<Init> {
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<LocalUser?>(context);
    String? uid;
    if (user != null) {
      uid = user.uid;
      if (user != Globals.localUser) {
        setState(() {});
      }
      print('//// current uid: $uid');
      Globals.localUser = user;
      auth.reloadUser().then((value) {
        print("//// reload user successful");
      }).catchError((error, stackTrace) {
        print("//// reload error: ${error.toString()}");
        Globals.localUser = null;
      });
    }

    print("//// Global localUser on init: ${Globals.localUser}");
    return Globals.localUser == null ? const Login() : const Home();
  }
}
