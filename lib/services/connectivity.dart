
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static bool connectionsStatus = false;

  static final subscription = Connectivity().onConnectivityChanged
  .listen((ConnectivityResult result) {
    print("//// Connection status: ${result.toString()}");
    if (result != ConnectivityResult.none) {
      connectionsStatus = true;
    } else {
      connectionsStatus = false;
    }
  });

  static dispose() {
    subscription.cancel();
  }
}