/*
  Loads first when the app runs, if there is a user logged in then the Home Page UI is displayed. 
  If there is no user logged in then the Login Page is loaded. While the user data is being loaded
  then the Loading Widget is displayed.        
*/
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hottake/shared/data.dart';
import 'package:hottake/widgets/error.dart';
import 'package:hottake/services/connectivity.dart';
import 'package:provider/provider.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/login.dart';
import 'package:hottake/widgets/loading.dart';
import 'package:hottake/services/auth.dart';
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
  ConnectivityService connectivity = ConnectivityService();

  @override
  void initState() {
    connectivity.subscription.onData((result) {
      if (kDebugMode) {
        print("//// Connection status: ${result.toString()}");
      }
      if (result != ConnectivityResult.none) {
        ConnectivityService.isOnline = true;
      } else {
        ConnectivityService.isOnline = false;
      }
      setState(() {});
    });
    _loaded = getData();
    super.initState();
  }

  @override
  void dispose() {
    connectivity.dispose;
    super.dispose();
  }

  Future<Widget> getData() async {
    await auth.reloadUser().onError((error, stackTrace) {
      return const Login();
    });
    if (kDebugMode) {
      print("//// localUser: ${Globals.localUser}");
    }
    if (Globals.localUser != null) {
      return const Home();
    } else {
      return const Login();
    }
  }

  @override
  Widget build(BuildContext context) {
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
    }

    return FutureBuilder<Widget>(
      future: _loaded,
      builder: (
        BuildContext context,
        AsyncSnapshot<Widget> widget,
      ) {
        if (kDebugMode) {
          print('//// online: ${ConnectivityService.isOnline}');
        }
        if (ConnectivityService.isOnline == false) {
          return const ErrorPage();
        }
        if (widget.hasData) {
          return widget.data!;
        } else {
          return const Loading();
        }
      },
    );
  }
}
