import 'package:flutter/material.dart';
import 'package:hottake/shared/data.dart';
import 'package:hottake/pages/error.dart';
import 'package:hottake/services/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import '../widgets/loading.dart';
import '../services/auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Init extends StatefulWidget {
  const Init({Key? key, this.reset = false}) : super(key: key);
  final bool reset;
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
    print("reset: ${widget.reset}");
    var user = Provider.of<LocalUser?>(context);
    if (user != null) {
      if (user != Globals.localUser) {
        setState(() {
          if (widget.reset == true) {
            _loaded = getData();
          }
        });
      }
      Globals.localUser = user;
      print('//// current uid: ${Globals.localUser!.uid}');
    } 
    print('//// online: ${ConnectivityService.isOnline}');
    if (ConnectivityService.isOnline == false) {
      return const ErrorPage();
    }

    return FutureBuilder<Widget>(
      future: _loaded,
      builder: (
        BuildContext context,
        AsyncSnapshot<Widget> widget,) 
        {
          print("//// hasData: ${widget.hasData}");
          print('//// current uid: ${Globals.localUser}');
          if (widget.hasData) {
            print("//// widget: ${widget.data.toString()}");
            
            return widget.data!;
          } else {
            return Loading();
          }
      },
    );
  }
}

