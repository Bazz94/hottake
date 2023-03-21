/* 
  App Check is enabled for this app on Web and Android.
*/

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hottake/widgets/error.dart';
import 'package:hottake/services/auth.dart';
import 'package:hottake/widgets/loading.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hottake/widgets/init.dart';
import 'package:hottake/pages/signup.dart';
import 'package:hottake/pages/settings.dart';
import 'package:hottake/widgets/chatInit.dart';
import 'package:hottake/pages/stance.dart';
import 'package:hottake/shared/data.dart';
import 'package:hottake/shared/private.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: Private.reCaptcha,
    androidProvider: AndroidProvider.debug,
    //androidProvider: AndroidProvider.playIntegrity,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    
    return MultiProvider(
      providers: [
        StreamProvider<LocalUser?>(
          create: (context) => AuthService().userOnChange,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        title: 'Hottake',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            color: Colors.deepPurple,
          ),
          scaffoldBackgroundColor: Colors.grey[850],
          fontFamily: 'LeagueSpartan',
          canvasColor: Colors.grey[850],
        ),
        home: const Init(),
        routes: {
          '/init': (context) => const Init(),
          '/signup': (context) => const Signup(),
          '/settings': (context) => const SettingsScreen(),
          '/stance': (context) => const StancePage(),
          '/chat':(context) => const ChatInit(),
          '/loading': (context) => const Loading(),
          '/error' :(context) => const ErrorPage(),
        },
      ),
    );
  }
}