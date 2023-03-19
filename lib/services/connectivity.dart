
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static bool isOnline = false;
  ConnectivityService() {
    Connectivity().checkConnectivity().then((ConnectivityResult result) {
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