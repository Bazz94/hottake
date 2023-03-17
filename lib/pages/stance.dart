import 'package:flutter/foundation.dart';
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

  @override
  void dispose() {
    print("//// dispose stance page");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Globals.topic == null) {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: kIsWeb ? Container() : null,
        title: Text(
            Globals.topic != null ? Globals.topic!.title : "Topic is null"),
      ),
      body: kIsWeb
          ? getWebUI()
          : Center(
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
                        Navigator.popAndPushNamed(context, '/chat');
                      }
                    }
                    if (directionDown) {
                      againstFontSize += 0.3;
                      forFontSize -= 0.3;
                      if (draggedFarEnough) {
                        againstFontSize = 100;
                        stanceColor = Colors.redAccent;
                        Globals.stance = 'nay';
                        Navigator.popAndPushNamed(context, '/chat');
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
                                letterSpacing: 0.5,
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
                            style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 40,
                                letterSpacing: 0.5),
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
                                letterSpacing: 0.5,
                                fontSize: againstFontSize.clamp(10, 100)),
                          )),
                        ),
                      ],
                    )),
              ),
            ),
    );
  }

  Widget getWebUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.blue[300]),
                    onPressed: () { 
                      Globals.stance = 'yay';
                      Navigator.popAndPushNamed(context, '/chat');
                     },
                    child: Text(
                  'For',
                  style: TextStyle(
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontSize: forFontSize.clamp(10, 100)),
                )),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: TextButton(
                  style: TextButton.styleFrom(backgroundColor: Colors.red[300]),
                    onPressed: () {
                      Globals.stance = 'nay';
                      Navigator.popAndPushNamed(context, '/chat');
                    },
                    child: Text(
                      'Against',
                      style: TextStyle(
                          color: Colors.white,
                          letterSpacing: 0.5,
                          fontSize: forFontSize.clamp(10, 100)),
                    )),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
