import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/data.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (Globals.topic != null) {
      
      print("//// pushNamed chat page");
      Navigator.popAndPushNamed(context, '/stance/chat');
    }

    return Container(
      color: Colors.grey[850],
      child: const Center(
        child: SpinKitSquareCircle(
          color: Colors.deepPurpleAccent,
          size: 50,
        ),
      ),
    );
  }
}
