/* 
  This class calls the http request from the Firebase Function called requestChat.
  The topic and stance of the requesting user are sent to the firebase function and
  a chat id is returned to the user.
*/

import 'package:flutter/foundation.dart';
import 'package:hottake/shared/data.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:convert';

class ServerService {

  Future<String?> get requestChat async {
    Map dataToSend = {
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
      if (data != null) {
        Globals.chatID = data["chat"];
        return Globals.chatID;
      }
    } on FirebaseFunctionsException catch (error) {
      if (kDebugMode) {
        print("//// requestChat: ${error.toString()}");
      }
    }
    return null;
  }

  Map? _jsonToMap(String file) {
    return jsonDecode(file) as Map<String, dynamic>;
  }
}