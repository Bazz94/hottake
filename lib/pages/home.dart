import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hottake/pages/loading.dart';
import 'package:hottake/services/database.dart';
import 'package:hottake/models/data.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Text title = const Text('Hottake');
  late Future<List<Widget>> _loaded;
  TextStyle myStyle = const TextStyle(fontSize: 24, color: Colors.white);
  DatabaseService database = DatabaseService(uid: Globals.localUser!.uid);

  @override
  void initState() {
    super.initState();
    print("//// Home init");
    Globals.stance = null;
    Globals.topic = null;
    _loaded = _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: _onWillPop,
        child: FutureBuilder<List<Widget>>(
            future: _loaded,
            builder:
                (BuildContext context, AsyncSnapshot<List<Widget>> listTopics) {
              List<Widget> children = <Widget>[];
              if (listTopics.hasData) {
                children = listTopics.data!;
                return Scaffold(
                    appBar: AppBar(
                      // Here we take the value from the MyHomePage object that was created by
                      // the App.build method, and use it to set our appbar title.
                      centerTitle: true,
                      title: title,
                      //leading:
                      actions: [
                        IconButton(
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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: children,
                            )),
                      ),
                    ));
              } else {
                return const Loading();
              }
            }));
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

  Widget myLabel = const Padding(
    padding: EdgeInsets.all(8.0),
    child: Center(
      child: Text('Pick a topic',
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 24, color: Colors.white)),
    ),
  );

  Widget makeTile(Topic t) {
    String loadingImg =
        'https://img.freepik.com/free-vector/white-abstract-background_23-2148806276.jpg?w=2000';
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        height: 110,
        child: Card(
            color: Colors.deepPurpleAccent,
            child: InkWell(
              onTap: () {
                Globals.topic = t;
                Navigator.pushNamed(context, '/stance');
              },
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      t.image != null ? t.image! : loadingImg,
                      alignment: Alignment.topLeft,
                      fit: BoxFit.fill,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(t.title, style: myStyle),
                ],
              ),
            )),
      ),
    );
  }

  Future<bool> _onWillPop() {
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
    return Future.value(true);
  }
}
