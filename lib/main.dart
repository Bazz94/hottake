import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hottake/services/auth.dart';
import 'package:hottake/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:hottake/services/init.dart';
import 'package:hottake/pages/login.dart';
import 'package:hottake/pages/home.dart';
import 'package:hottake/pages/signup.dart';
import 'package:hottake/pages/settings.dart';
import 'package:hottake/widgets/chatInit.dart';
import 'package:hottake/pages/stancePage.dart';
import 'package:hottake/models/data.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb){
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: Constants.apiKey,
            appId: Constants.appId,
            messagingSenderId: Constants.messagingSenderId,
            projectId: Constants.projectId));
  } else {
    await Firebase.initializeApp();
  }

  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. debug provider
    // 2. safety net provider
    // 3. play integrity provider
    androidProvider: AndroidProvider.debug,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          appBarTheme: const AppBarTheme(
            color: Colors.deepPurple,
          ),
          backgroundColor: Colors.grey[850],
          scaffoldBackgroundColor: Colors.grey[850],
          fontFamily: 'LeagueSpartan',
        ),
        home: Init(),
        routes: {
          '/init': (context) => Init(),
          '/login': (context) => Login(),
          '/signup': (context) => Signup(),
          '/home': (context) => Home(),
          '/settings': (context) => SettingsScreen(),
          '/stancePage': (context) => StancePage(),
          '/stancePage/chat': (context) => ChatInit(),
        },
      ),
    );
  }
}
