import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../models/data.dart';
import '../models/styles.dart';

class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    

    return SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.grey[850],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                    flex: 3,
                    child: SizedBox(),
                  ), //Spacing
                  const Flexible(
                    flex: 1,
                    child: SpinKitSquareCircle(
                      color: Colors.deepPurpleAccent,
                      size: 50,
                    ),
                  ),
                  const Flexible(
                    flex: 1,
                    child: SizedBox(
                      height: 60,
                    ),
                  ), //Spacing
                  Flexible(
                    flex: 1,
                    child: Text(
                      'Loading...',
                      style: TextStyles.buttonPurple,
                    ),
                  ),
                  const Flexible(
                    flex: 3,
                    child: SizedBox(),
                  ), //Spacing
                ],
              ),
            ),
          ),
        ),
    );
  }
}
