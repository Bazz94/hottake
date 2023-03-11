import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hottake/pages/home.dart';

class Searching extends StatefulWidget {
  const Searching({Key? key}) : super(key: key);

  @override
  State<Searching> createState() => _SearchingState();
}

class _SearchingState extends State<Searching> {
  late DateTime startTime;
  String timeCounter = '0:00';
  int secs = 0;
  int mins = 0;
  late Timer timer;

  @override
  void initState() {
    startTime = DateTime.now();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    timer = Timer(const Duration(seconds: 1),() async {
      setState(() {
        double difference = startTime.difference(DateTime.now()).inSeconds.abs().toDouble();
        secs = difference.remainder(60).toInt();
        difference = difference/60;
        mins = difference.floor();
        if (secs > 9) {
          timeCounter = "$mins:$secs";
        } else {
          timeCounter = "$mins:0$secs";
        }
      });
    });


    return WillPopScope(
      onWillPop: () async {
        timer.cancel();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => const Home()),
          ModalRoute.withName('/home'),
        );
        return false;
      } ,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: Colors.grey[850],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(flex: 3, child: SizedBox(),), //Spacing
                  Flexible(
                    flex: 1,
                    child: Text(
                      timeCounter,
                      style: const TextStyle(color: Colors.white,fontSize: 18),
                    ),
                  ),
                  const Flexible(flex: 1, child: SizedBox(height: 50,),),  //Spacing
                  const Flexible(
                    flex: 1,
                    child: SpinKitFadingCircle(
                      color: Colors.deepPurpleAccent,
                      size: 100,
                    ),
                  ),
                  const Flexible(flex: 1, child: SizedBox(height: 50,),),  //Spacing
                  const Flexible(
                    flex: 1,
                    child: Text(
                      'Searching...',
                      style: TextStyle(color: Colors.white,fontSize: 20),
                    ),
                  ),
                  const Flexible(flex: 3, child: SizedBox(),),  //Spacing
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
