import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';
import 'package:hottake/pages/error.dart';
import 'package:hottake/services/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import 'auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Init extends StatefulWidget {
  const Init({Key? key}) : super(key: key);

  @override
  State<Init> createState() => _Init();
}

class _Init extends State<Init> {
  AuthService auth = AuthService();

  @override
  void initState() {
    
    ConnectivityService.subscription.onData((result) {
      setState(() {
        print("//// Connection status: ${result.toString()}");
        if (result != ConnectivityResult.none) {
          ConnectivityService.connectionsStatus = true;
        } else {
          ConnectivityService.connectionsStatus = false;
        }
      });
    });
    super.initState();
  } 

  @override
  void dispose() { 
    ConnectivityService.dispose();
    super.dispose();
  } 

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

    if (ConnectivityService.connectionsStatus == false) {
      return ErrorPage();
    }

    print("//// Global localUser on init: ${Globals.localUser}");
    return Globals.localUser == null 
      ? const Login() 
      : const Home();
  }
}
