
import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import 'package:hottake/services/database.dart';

class Init extends StatefulWidget {
  const Init({Key? key}) : super(key: key);

  @override
  State<Init> createState() => _Init();
}

class _Init extends State<Init> {

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<LocalUser?>(context);
    String? uid;
    if (user != null) {
      uid = user.uid;
      bool changed = false;
      if (user != Globals.localUser) {
        changed = true;
      }
      print('//// current uid: $uid');
      Globals.localUser = user;
      DatabaseService database = DatabaseService(uid: uid);
      database.getReputation.then((reputation) {
        if (reputation != null && changed == true) {
          Globals.localUser!.reputation = reputation;
          print("//// reputation: $reputation");
        }
      });
    }

    return user == null ? Login() : Home();
  }
}
