
import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      print('//// current uid: $uid');
      Globals.localUser = user;
    }

    return MultiProvider(
        providers: [
          StreamProvider<DocumentSnapshot?>.value(
            value: DatabaseService(uid: uid).users,
            initialData: null,
          ),
        ],
        child:  user == null ? Login() : Home(),
    );
  }
}
