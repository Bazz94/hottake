
import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import 'package:hottake/services/database.dart';

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
    }
    auth.reloadUser().then((value) {
      print("//// reload user successful");
    })
    .onError((error, stackTrace) {
      print("//// reload user error");
      setState(() {
        user = null;
      });
    });

    return user == null ? Login() : Home();
  }
}
