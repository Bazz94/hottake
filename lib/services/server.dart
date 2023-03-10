import 'package:hottake/models/data.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';

class ServerService {
  String uid;
  ServerService({required this.uid});

  Future<String?> get requestChat async {
    Map dataToSend = {
      'reputation': Globals.localUser!.reputation,
      'topic': Globals.topic!.title,
      'stance': Globals.stance,
    };
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('requestChat',
              options:
                  HttpsCallableOptions(timeout: const Duration(seconds: 10)))
          .call(dataToSend);

      Map? data = _jsonToMap(json.encode(result.data));
      print('//// received from server: $data');
      if (data != null) {
        Globals.chatID = data["chat"];

        return Globals.chatID;
      }
    } on FirebaseFunctionsException catch (error) {
      String theError = error.toString();
      print("//// requestChat: ${error.toString()}");
    }
    return null;
  }

  Map? _jsonToMap(String file) {
    return jsonDecode(file) as Map<String, dynamic>;
  }
}
