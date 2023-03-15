import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';
import 'package:hottake/pages/error.dart';
import 'package:hottake/services/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import '../pages/loading.dart';
import 'auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Init extends StatefulWidget {
  const Init({Key? key}) : super(key: key);

  @override
  State<Init> createState() => _Init();
}

class _Init extends State<Init> {
  AuthService auth = AuthService();
  late Future<Widget> _loaded;

  @override
  void initState() {
    _loaded = getData();
    ConnectivityService.subscription.onData((result) {
      setState(() {
        print("////1 Connection status: ${result.toString()}");
        if (result != ConnectivityResult.none) {
          ConnectivityService.isOnline = true;
        } else {
          ConnectivityService.isOnline = false;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    print("//// init dispose");
    ConnectivityService.dispose;
    super.dispose();
  }

  Future<Widget> getData() async {
    await auth.reloadUser();
    print("//// localUser: ${Globals.localUser}");
    if (Globals.localUser != null) {
      return Home();
    } else {
      return Login();
    }
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
    }

    if (ConnectivityService.isOnline == false) {
      return const ErrorPage();
    }

    return FutureBuilder<Widget>(
      future: _loaded,
      builder: (
        BuildContext context,
        AsyncSnapshot<Widget> widget,) 
        {
          print("//// build run: ${widget.hasData}");
          if (widget.hasData) {
            return widget.data!;
          } else {
            return const Loading();
          }
      },
    );
  }
}

