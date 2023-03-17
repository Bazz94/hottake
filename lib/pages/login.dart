import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hottake/services/auth.dart';
import 'package:hottake/pages/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/styles.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  bool isLoading = false;
  final TextStyle myStyle = const TextStyle(fontSize: 20, letterSpacing: 0.5);
  String headerText = 'Welcome';
  TextStyle titleStyle = TextStyles.title;
  bool buttonCheck = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool resetPasswordHidden = true;

  @override
  void initState() {
    print("//// login page init");
    super.initState();
  }

  String? get _emailErrorText {
    final text = emailController.value.text;

    if (text.isEmpty && buttonCheck) {
      return 'required';
    } else {
      return '';
    }
  }

  String? get _passwordErrorText {
    final text = passwordController.value.text;
    if (text.isEmpty && buttonCheck) {
      return 'required';
    }
    {
      return '';
    }
  }

  void _submit() async {
    String email = emailController.text.toString();
    String password = passwordController.text.toString();
    User? result = await _auth.signIn(email, password);
    if (result == null) {
      setState(() {
        headerText = 'Incorrect email or password';
        titleStyle = TextStyles.titleError;
        isLoading = false;
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }
  }

  void _submitGoogle() async {
    User? result = await _auth.googleSignIn();
    if (result == null) {
      setState(() {
        headerText = 'Google sign in failed';
        titleStyle = TextStyles.titleError;
        isLoading = false;
      });
    } else {
      Future.delayed(Duration.zero, () {
        Navigator.popAndPushNamed(context, '/init');
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    print("//// dispose login page");
    passwordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  OutlineInputBorder customOutlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text("Hottake", style: TextStyles.title),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Container(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          headerText,
                          style: titleStyle
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SizedBox(
                          height: 70,
                          child: TextField(
                            onChanged: (_) => setState(() {}),
                            controller: emailController,
                            style: TextStyles.textField,
                            cursorColor: Colors.deepPurpleAccent,
                            decoration: InputDecoration(
                              errorText: _emailErrorText,
                              errorBorder: customOutlineInputBorder(),
                              enabledBorder: customOutlineInputBorder(),
                              focusedBorder: customOutlineInputBorder(),
                              focusedErrorBorder: customOutlineInputBorder(),
                              labelText: 'Email',
                              labelStyle: TextStyles.textFieldLabel,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: SizedBox(
                          height: 70,
                          child: TextField(
                            obscureText: true,
                            onChanged: (_) => setState(() {}),
                            controller: passwordController,
                            style: TextStyles.textField,
                            cursorColor: Colors.deepPurpleAccent,
                            decoration: InputDecoration(
                              errorText: _passwordErrorText,
                              errorBorder: customOutlineInputBorder(),
                              enabledBorder: customOutlineInputBorder(),
                              focusedBorder: customOutlineInputBorder(),
                              focusedErrorBorder: customOutlineInputBorder(),
                              labelText: 'Password',
                              labelStyle: TextStyles.textFieldLabel,
                            ),
                          ),
                        ),
                      ),
                      //Login Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () {
                            setState(() {
                              buttonCheck = true;
                              if (emailController.value.text.isNotEmpty &&
                                  passwordController.value.text.isNotEmpty) {
                                isLoading = true;
                                _submit();
                              }
                            });
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 24, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      //Google Login Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () async {
                            setState(() => isLoading = true);
                            _submitGoogle();
                          },
                          icon: const FaIcon(FontAwesomeIcons.google,
                              color: Colors.black),
                          label: Text(
                            'Google Login',
                            style: TextStyles.buttonLight,
                          ),
                        ),
                      ),
                      //SignUp Button
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          onPressed: () async {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Sign up',
                            style: TextStyles.buttonPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
