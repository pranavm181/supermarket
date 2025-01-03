// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supermarket/User/about.dart';
import 'package:supermarket/User/contact.dart';
import 'package:supermarket/User/privacy.dart';
import 'package:supermarket/User/terms.dart';
import 'package:supermarket/authentication/welcomepage.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  List options = [
    'About Us',
    'Privacy Policy',
    'Terms and Conditions',
    'Contact Us',
  ];
  List optionsicon = [
    Icons.groups,
    Icons.policy,
    Icons.check_box,
    Icons.support_agent,
  ];
  List pages = [
    AboutUsPage(),
    Privacy(mdFilename: 'lib/assets/privacy.md'),
    Terms(mdFilename: 'lib/assets/terms.md'),
    HelpCenterPage(),
  ];
  String? userName = "";

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "Your Name";
        });
      } else {
        setState(() {
          userName = "Your Name";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Future signout() async {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          'Signout successfully',
          style: TextStyle(color: Colors.black),
        ),
        action: SnackBarAction(
            label: 'Cancel', textColor: Colors.black, onPressed: () {}),
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WelcomePage(),
        ),
      );
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setBool('islogged', false);
    }

    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [],
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.blue,
                      child: Text(
                        (userName != null && userName!.isNotEmpty)
                            ? userName![0].toUpperCase()
                            : "Y",
                        style: TextStyle(fontSize: 40, color: Colors.black),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      userName ?? "Your Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(color: Colors.black),
            ListView.builder(
              itemCount: options.length,
              shrinkWrap: true,
              itemBuilder: (context, index) => ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => pages[index] ?? Container(),
                    ),
                  );
                },
                leading: Icon(
                  optionsicon[index],
                  size: 25,
                  color: Colors.black,
                ),
                title: Text(
                  options[index],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                trailing: Icon(Icons.arrow_right),
              ),
            ),
            Divider(
              color: Colors.black45,
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.black,
              ),
              title: Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              trailing: Icon(
                Icons.logout,
                color: Colors.red[700],
              ),
              onTap: () => signout(),
            )
          ],
        ),
      ),
    );
  }
}
