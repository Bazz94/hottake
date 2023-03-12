import 'package:firebase_auth/firebase_auth.dart';
import 'package:hottake/models/data.dart';
import 'package:hottake/services/database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class AuthService{
  static final  FirebaseAuth _auth = FirebaseAuth.instance;
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

  //Change FirebaseUser to a LocalUser
  LocalUser? getLocalUserFromFirebaseUser(User? user){
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
    return _auth.authStateChanges()
        .map((User? user) => getLocalUserFromFirebaseUser(user));
  }

  //register with Email and Password
  Future<User?> register(String username,String email, String password) async {
    try {
      UserCredential? result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _user = result.user;
      await _user!.updateDisplayName(username);
      
      //create a new doc in firestore users
      await DatabaseService(uid: _user!.uid).updateUserData(50); //default values
      return _user;
    } catch(e) {
        print(e.toString());
        return null;
    }
  }

  //sign in
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential? result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _user = result.user;
      return _user;
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  //Google Sign In
  Future<User?> googleSignIn() async {

    final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

    if (googleSignInAccount != null) {

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        _user = userCredential.user;
        if (userCredential.additionalUserInfo!.isNewUser) {
          //Create new user in database
          await DatabaseService(uid: _user!.uid).updateUserData(50);
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

  //sign out
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      _user = null;
    } catch(e) {
      print(e.toString());
    }
  }

  Future updateUsername(String displayName) async {
    Globals.localUser!.username = displayName;
    return await _user!.updateDisplayName(displayName);
  }
}