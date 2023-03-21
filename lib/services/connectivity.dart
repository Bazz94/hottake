/* 
  Used to notify the app that there has been a loss of internet connectivity.
  subscription is over written in the widgets that use this class since setState 
  cannot be called from here. 
*/

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static bool isOnline = false;
  ConnectivityService() {
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
      if (kDebugMode) {
        print("////check connectivity");
      }
      if (result != ConnectivityResult.none) {
        isOnline = true;
      } else {
        isOnline = false;
      }
    });
  }

  final subscription = Connectivity().onConnectivityChanged
  .listen((ConnectivityResult result) {});


  dispose() {
    subscription.cancel();
  }
}