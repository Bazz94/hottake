import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hottake/pages/loading.dart';
import 'package:hottake/services/database.dart';
import 'package:hottake/models/data.dart';
import '../models/styles.dart';
import '../services/connectivity.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Widget>> _loaded;

  @override
  void initState() {
    print("//// Home init");
    Globals.stance = null;
    Globals.topic = null;
    _loaded = _load();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Widget>> _load() async {
    DatabaseService database = DatabaseService();
    List<Topic> topics = await database.topics;
    List<Widget> wids = <Widget>[];
    wids.add(myLabel);
    for (var t in topics) {
      wids.add(makeTile(t));
    }
    return wids;
  }

  @override
  Widget build(BuildContext context) {
    if (Globals.localUser == null) {
      print("//// uid is null");
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }

    print("//// flag 0: ${ConnectivityService.isOnline}");
    if (ConnectivityService.isOnline == false) {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }

    return WillPopScope(
        onWillPop: _onWillPop,
        child: FutureBuilder<List<Widget>>(future: _loaded.catchError((error) {
          Future.delayed(Duration.zero, () {
            Navigator.popAndPushNamed(context, '/error');
          });
        }), builder:
            (BuildContext context, AsyncSnapshot<List<Widget>> listTopics) {
          List<Widget> children = <Widget>[];
          if (listTopics.hasData) {
            children = listTopics.data!;
            return Scaffold(
                appBar: AppBar(
                  // Here we take the value from the MyHomePage object that was created by
                  // the App.build method, and use it to set our appbar title.
                  centerTitle: true,
                  title: Text('Hottake', style: TextStyles.title),
                  leading: Container(),
                  actions: [ kIsWeb
                        ? ElevatedButton(
                          style: ElevatedButton.styleFrom(shape: const ContinuousRectangleBorder(),
                            backgroundColor: Colors.deepPurple,
                            side: const BorderSide(width: 0.5,color: Colors.white)
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            }, 
                          child: Text("Profile",style: TextStyles.buttonPurple)) 
                        : IconButton(
                          icon: const Icon(Icons.settings),
                          tooltip: 'Navigation menu',
                          onPressed: () {
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                  ],
                ),
                body: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 16, 5, 16),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: children,
                          ),
                        )),
                  ),
                ));
          } else {
            return const Loading();
          }
        }));
  }

  Widget myLabel = Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Text(
        'Pick a topic',
        textAlign: TextAlign.center,
        style: TextStyles.title,
      ),
    ),
  );

  Widget makeTile(Topic t) {
    Image image;
    if (t.image != null) {
      image = Image.memory(t.image!, width: 110, height: 110, fit: BoxFit.fill);
    } else {
      image = Image.asset("assets/images/error_image.png",
          width: 110, height: 110, fit: BoxFit.fill);
    }
    return SizedBox(
      height: 110,
      child: Card(
          color: Colors.deepPurpleAccent,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              Globals.topic = t;
              Future.delayed(Duration.zero, () {
                Navigator.pushNamed(context, '/stance');
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                image,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10),
                            Center(
                                child: Text(t.title, style: TextStyles.title)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }

  Future<bool> _onWillPop() {
    if (kIsWeb) {
      ConnectivityService.dispose();
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Confirm Exit"),
              content: const Text("Are you sure you want to exit?"),
              actions: <Widget>[
                TextButton(
                  child: const Text("YES"),
                  onPressed: () {
                    SystemNavigator.pop();
                    ConnectivityService.dispose();
                    exit(0);
                  },
                ),
                TextButton(
                  child: const Text("NO"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    }
    return Future.value(true);
  }
}
