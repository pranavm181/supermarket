// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:supermarket/User/account.dart';
//import 'package:supermarket/User/category.dart';
import 'package:supermarket/User/favourites.dart';

import 'package:supermarket/User/homepage.dart';
import 'package:supermarket/User/myorders.dart';

class BottomnavBar extends StatefulWidget {
  const BottomnavBar({super.key});

  @override
  State<BottomnavBar> createState() => _BottomnavBarState();
}

class _BottomnavBarState extends State<BottomnavBar> {
  int activeindex = 0;

  final List screens = [
    Homepage(),
    Favourites(),
    OrdersPage(),
    Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[activeindex],
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.blue,
        style: TabStyle.react,
        initialActiveIndex: activeindex,
        color: Colors.black,
        activeColor: Colors.black,
        elevation: 10,
        items: [
          TabItem(
            icon: Icons.home,
            title: 'Home',
          ),
          TabItem(icon: Icons.favorite, title: 'Wishlist'),
          TabItem(
            icon: Icons.shopping_cart,
            title: 'My Orders',
          ),
          TabItem(
            icon: Icons.account_circle,
            title: 'Account',
          ),
        ],
        onTap: (value) {
          setState(() {
            activeindex = value;
          });
        },
      ),
    );
  }
}
