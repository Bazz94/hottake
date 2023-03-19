import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hottake/services/connectivity.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    
    return SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.grey[850],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  const Flexible(
                    flex: 3,
                    child: SizedBox(),
                  ), //Spacing
                  Flexible(
                    flex: 1,
                    child: Text( ConnectivityService.isOnline == false
                      ? "Lost connection..."
                      : "An error has occurred",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          letterSpacing: 0.5),
                    ),
                  ),
                  const Flexible(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                    ),
                  ), //Spacing
                  const Flexible(
                    flex: 1,
                    child: SpinKitFoldingCube(
                      color: Colors.deepPurpleAccent,
                      size: 100,
                    ),
                  ),
                  const Flexible(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                    ),
                  ), //Spacing
                  ConnectivityService.isOnline == false ? Spacer()
                    : OutlinedButton(
                      onPressed: () {
                        Future.delayed(Duration.zero, () {
                            Navigator.popAndPushNamed(context, '/init');
                          });
                      }, 
                      child: Text("Ok")
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