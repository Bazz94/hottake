import 'package:firebase_auth/firebase_auth.dart';
import 'package:hottake/models/data.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hottake/services/database.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static User? _user = _auth.currentUser;

  String? get getUid {
    if (_user != null) {
      String? uid = _user!.uid;
      return uid;
    } else {
      return null;
    }
  }

  Future reloadUser() async {
    if (_user != null) {
      try {
        await _user?.reload();
        print("//// reload user successful");
      } on FirebaseAuthException catch (error) {
        if (error.code != 'network-request-failed') {
          Globals.localUser = null;
        }
        print("//// error code: ${error.code}");
        print("//// reload error: ${error.toString()}");
      }
    }
    return null;
  }

  //Change FirebaseUser to a LocalUser
  LocalUser? _getLocalUserFromFirebaseUser(User? user) {
    if (user != null) {
      return LocalUser(
        uid: user.uid,
        username: user.displayName,
        email: user.email,
      );
    } else {
      return null;
    }
  }

  //change user stream
  Stream<LocalUser?> get userOnChange {
    //
    return _auth
        .authStateChanges()
        .map((User? user) => _getLocalUserFromFirebaseUser(user))
        .handleError((error) {
      print("//// get userOnChange: ${error.toString()}");
    });
  }

  //register with Email and Password
  Future<User?> register(String username, String email, String password) async {
    try {
      UserCredential? result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      _user = result.user;
      await _user!.updateDisplayName(username);
      return _user;
    } catch (e) {
      print("//// registration error: ${e.toString()}");
      return null;
    }
  }

  //sign in
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential? result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = result.user;
      return _user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //Google Sign In
  Future<User?> googleSignIn() async {
    if (kIsWeb) {

      var provider = GoogleAuthProvider();
      provider.setCustomParameters({"prompt": "select_account"});
      try {
        await _auth.signInWithRedirect(provider);
        return _auth.currentUser;
      } catch (error) {
        print("//// google error: ${error.toString()}");
        return null;
      }
    } else {

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn().catchError((error) {
        print("//// googleSignIn error: ${error.toString()}");
      });

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await _auth.signInWithCredential(credential);
          _user = userCredential.user;
          if (userCredential.additionalUserInfo!.isNewUser) {
            return _user;
          } else {
            return _user;
          }
        } catch (e) {
          print("//// Error googleSignIn: ${e.toString()}");
          return null;
        }
      } else {
        return null;
      }
    }
  }

  //sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      Globals.localUser = null;
      _user = null;
    } catch (e) {
      print(e.toString());
    }
  }

  Future updateUsername(String displayName) async {
    Globals.localUser!.username = displayName;
    DatabaseService database = DatabaseService();
    try {
      await database.updateUserData(displayName);
    } catch (error) {
      print("//// updateUsername: ${error.toString()}");
    }
    return await _user!.updateDisplayName(displayName).catchError((error) {
      print("//// updateDisplayName: ${error.toString()}");
    });
  }
}
