import 'package:flutter/material.dart';
import 'package:hottake/models/data.dart';


class StancePage extends StatefulWidget {
  const StancePage({Key? key}) : super(key: key);

  @override
  State<StancePage> createState() => _StancePageState();
}

class _StancePageState extends State<StancePage> {
  Color? stanceColor = Colors.grey[850];
  double forFontSize = 35;
  double againstFontSize = 35;
  int startPoint = 0;
  String uid = Globals.localUser!.uid;

  @override
  void dispose() {
    print("//// dispose stance page");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(Globals.topic!.title),
          ),
          body: Center(
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                setState(() {
                  forFontSize = 35;
                  againstFontSize = 35;
                });
              },
              onVerticalDragStart: (details) {
                startPoint = details.globalPosition.dy.toInt();
              },
              onVerticalDragUpdate: (details) {
                bool draggedFarEnough =
                    (startPoint - details.globalPosition.dy.toInt()).abs() >
                        150;
                bool directionUp = details.delta.direction < 0;
                bool directionDown = details.delta.direction > 0;
                setState(() {
                  if (directionUp) {
                    forFontSize += 0.3;
                    againstFontSize -= 0.3;
                    if (draggedFarEnough) {
                      forFontSize = 100;
                      stanceColor = Colors.blue[300];
                      Globals.stance = 'yay';
                      Navigator.pushNamed(context, '/stance/chat');
                    }
                  }
                  if (directionDown) {
                    againstFontSize += 0.3;
                    forFontSize -= 0.3;
                    if (draggedFarEnough) {
                      againstFontSize = 100;
                      stanceColor = Colors.redAccent;
                      Globals.stance = 'nay';
                      Navigator.pushNamed(context, '/stance/chat');
                    }
                  }
                });
              },
              child: Container(
                  color: stanceColor,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Center(
                            child: Text(
                          'For',
                          style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: forFontSize.clamp(10, 100)),
                        )),
                      ),
                      Expanded(
                          flex: 2,
                          child: Transform.rotate(
                              angle: 1.6,
                              child: Icon(Icons.chevron_left,
                                  size: 40, color: Colors.grey[600]))),
                      Expanded(
                        flex: 2,
                        child: Center(
                            child: Text(
                          'Swipe',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 40),
                        )),
                      ),
                      Expanded(
                          flex: 2,
                          child: Transform.rotate(
                              angle: -1.6,
                              child: Icon(Icons.chevron_left,
                                  size: 40, color: Colors.grey[600]))),
                      Expanded(
                        flex: 8,
                        child: Center(
                            child: Text(
                          'Against',
                          style: TextStyle(
                              color: Colors.red[300],
                              fontSize: againstFontSize.clamp(10, 100)),
                        )),
                      ),
                    ],
                  )),
            ),
          ),
        );
  }
}
