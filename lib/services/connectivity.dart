
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static bool isOnline = false;

  static final subscription = Connectivity().onConnectivityChanged
  .listen((ConnectivityResult result) {
    print("//// Connection status: ${result.toString()}");
    if (result != ConnectivityResult.none) {
      isOnline = true;
    } else {
      isOnline = false;
    }
  });

  static dispose() {
    subscription.cancel();
  }
}