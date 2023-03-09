import 'package:flutter/material.dart';
import 'package:hottake/services/auth.dart';
import 'package:hottake/pages/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  final AuthService _auth = AuthService();

  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    super.dispose();
  }

  String signUpError = '';
  bool buttonCheck = false;

  String? get _usernameErrorText {
    final text = usernameController.value.text;
    if (text.isEmpty && buttonCheck) {
      return 'required';
    } else {
      return '';
    }
  }
  String? get _emailErrorText {
    final text = emailController.value.text;
    if (text.isEmpty & buttonCheck) {
      return 'required';
    }else {
      return '';
    }
  }
  String? get _passwordErrorText {
    final text = passwordController.value.text;
    if (text.isEmpty && buttonCheck) {
      return 'required';
    }else {
      return '';
    }
  }
  String? get _password2ErrorText {
    final text = password2Controller.value.text;
    if (text != passwordController.value.text) {
      return 'Passwords do not match';
    } else {
      return '';
    }
  }

  void _submit() async{
    String username = usernameController.text.toString();
    String email = emailController.text.toString();
    String password = password2Controller.text.toString();
    User? result = await _auth.register(username,email,password); //username has no unique check
    if (result == null){
      setState(() {
        signUpError = "Invalid email";
        isLoading = false;
      });
    } else {

      Navigator.pop(context);
    }
  }

  OutlineInputBorder customOutlineInputBorder() {
    return const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.deepPurple),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == true ? Loading() : Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        centerTitle: true,
        title: const Text("Sign Up"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SizedBox(
                    height: 20,
                    child: Text(
                        signUpError,
                        style: TextStyle(color: Colors.red,fontSize: 20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SizedBox(
                    height: 70,
                    child: TextField(
                      onChanged: (_) => setState(() {}),
                      controller: usernameController,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                      cursorColor: Colors.deepPurpleAccent,
                      decoration: InputDecoration(
                        errorText: _usernameErrorText,
                        errorBorder: customOutlineInputBorder(),
                        enabledBorder: customOutlineInputBorder(),
                        focusedBorder: customOutlineInputBorder(),
                        focusedErrorBorder: customOutlineInputBorder(),
                        labelText: 'Username',
                        labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SizedBox(
                    height: 70,
                    child: TextField(
                      onChanged: (_) => setState(() {}),
                      controller: emailController,
                      style: const TextStyle(color: Colors.white,fontSize: 20),
                      cursorColor: Colors.deepPurpleAccent,
                      decoration: InputDecoration(
                        errorText: _emailErrorText,
                        errorBorder: customOutlineInputBorder(),
                        enabledBorder: customOutlineInputBorder(),
                        focusedBorder: customOutlineInputBorder(),
                        focusedErrorBorder: customOutlineInputBorder(),
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SizedBox(
                    height: 70,
                    child: TextField(
                      onChanged: (_) => setState(() {}),
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white,fontSize: 20),
                      cursorColor: Colors.deepPurpleAccent,
                      decoration: InputDecoration(
                        errorText: _passwordErrorText,
                        errorBorder: customOutlineInputBorder(),
                        enabledBorder: customOutlineInputBorder(),
                        focusedBorder: customOutlineInputBorder(),
                        focusedErrorBorder: customOutlineInputBorder(),
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: SizedBox(
                    height: 70,
                    child: TextField(
                      onChanged: (_) => setState(() {}),
                      controller: password2Controller,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white,fontSize: 20),
                      cursorColor: Colors.deepPurpleAccent,
                      decoration: InputDecoration(
                        errorText: _password2ErrorText,
                        errorBorder: customOutlineInputBorder(),
                        enabledBorder: customOutlineInputBorder(),
                        focusedBorder: customOutlineInputBorder(),
                        focusedErrorBorder: customOutlineInputBorder(),
                        labelText: 'Password Check',
                        labelStyle: const TextStyle(color: Colors.deepPurpleAccent),
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: () async {
                      setState(() => buttonCheck = true);
                      if ((usernameController.value.text.isNotEmpty &&
                          emailController.value.text.isNotEmpty) &&
                          (passwordController.value.text.isNotEmpty &&
                              (password2Controller.value.text.toString() ==
                                  passwordController.value.text.toString()))) {
                        setState(() => isLoading = true);
                        _submit();
                      }
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 24),
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
