// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:supermarket/User/navbar.dart';
import 'package:supermarket/authentication/welcomepage.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getloggedData().whenComplete(() {
      if (finalData == true) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => BottomnavBar()));
      } else {
        Future.delayed(Duration(seconds: 4), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => WelcomePage()));
        });
      }
    });
  }

  bool? finalData;
  Future getloggedData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getData = preferences.getBool('islogged');
    setState(() {
      finalData = getData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('lib/Images/logo.png'),
              height: 150,
              width: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Everyday Shopping, Made Effortless!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
