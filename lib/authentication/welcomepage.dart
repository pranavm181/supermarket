// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:supermarket/authentication/login_screen.dart';
import 'package:supermarket/authentication/signup_screen.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'lib/Images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                "Your Everyday Shopping, Made Effortless!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                          ));
                    },
                    style: ButtonStyle(
                      fixedSize: WidgetStatePropertyAll(
                        Size.fromWidth(
                            MediaQuery.of(context).size.width / 2 - 10),
                      ),
                      shape: WidgetStatePropertyAll(BeveledRectangleBorder()),
                      backgroundColor: WidgetStatePropertyAll(Colors.black),
                    ),
                    child: Text(
                      'SignUp',
                      style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ));
                    },
                    style: ButtonStyle(
                      fixedSize: WidgetStatePropertyAll(
                        Size.fromWidth(
                            MediaQuery.of(context).size.width / 2 - 10),
                      ),
                      shape: WidgetStatePropertyAll(BeveledRectangleBorder()),
                      backgroundColor: WidgetStatePropertyAll(Colors.black),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
