// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, body_might_complete_normally_catch_error, must_be_immutable, non_constant_identifier_names, avoid_types_as_parameter_names

import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket/authentication/signup_screen.dart';
import 'package:supermarket/User/navbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  TextEditingController resetemail = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future login() async {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text, password: password.text);
        final SharedPreferences preferences =
            await SharedPreferences.getInstance();
        preferences.setBool('islogged', true);

        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext) => BottomnavBar()));
      } catch (e) {
        log(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.black,
            content: Text(
              '$e',
              style: TextStyle(color: Colors.lightBlue),
            )));
      }
    }

    Future googlesignin() async {
      final user = await GoogleSignIn().signIn().catchError((onError) {});
      if (user == null) {
        return;
      } else {
        final auth = await user.authentication;
        final credentials = GoogleAuthProvider.credential(
            idToken: auth.idToken, accessToken: auth.accessToken);
        await FirebaseAuth.instance.signInWithCredential(credentials);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BottomnavBar(),
          ),
        );
      }
    }

    Future forgot() async {
      try {
        if (resetemail.text.contains('@')) {
          await FirebaseAuth.instance
              .sendPasswordResetEmail(email: resetemail.text);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Email sent Successfully',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.blue,
              action: SnackBarAction(
                textColor: Colors.black,
                label: 'Cancel',
                onPressed: () {},
              ),
            ),
          );
          resetemail.clear();
          Navigator.pop(context);
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("An Error Occured ${e.toString()}"),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: email,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.lightBlue[200],
                          title: Text(
                            'Verify Your Email',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          content: TextField(
                            controller: resetemail,
                            decoration: InputDecoration(
                              labelText: 'Email to verify',
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(width: 2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.black),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.lightBlue),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                forgot();
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.black),
                              ),
                              child: Text(
                                'Verify',
                                style: TextStyle(color: Colors.lightBlue),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue),
                    ))),
            ElevatedButton(
              onPressed: () {
                login();
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
              child: Text(
                'Login',
                style: TextStyle(
                    color: Colors.lightBlue[200], fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Or',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                googlesignin();
              },
              style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.black),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('lib/Images/google.jpeg'),
                    height: 25,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sign in with Google',
                    style: TextStyle(
                        color: Colors.lightBlue[200],
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ));
                  },
                  child: Text(
                    'Signup',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
