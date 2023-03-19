import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hottake/pages/chat.dart';
import 'package:hottake/pages/error.dart';
import 'package:hottake/services/auth.dart';
import 'package:hottake/services/connectivity.dart';
import 'package:hottake/widgets/loading.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hottake/pages/init.dart';
import 'package:hottake/pages/signup.dart';
import 'package:hottake/pages/settings.dart';
import 'package:hottake/pages/chatInit.dart';
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
    // 1. debug provider
    // 3. play integrity provider
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
    AuthService auth = AuthService();
    String? uid = auth.getUid;
    print('//// initial uid: $uid');
    
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
        home: Init(),
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