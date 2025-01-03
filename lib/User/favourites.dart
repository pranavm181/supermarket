// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supermarket/User/productlist.dart';

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  List<Map<String, dynamic>> wishlistItems = [];

  @override
  void initState() {
    super.initState();
    fetchWishlist();
  }

  Future<void> fetchWishlist() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please log in to view your wishlist'),
          ),
        );
        return;
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('wishlist')
          .where('email', isEqualTo: user.email)
          .get();

      setState(() {
        wishlistItems = querySnapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'docId': doc.id,
            'id': data['productId'],
            'name': data['productName'],
            'price': data['price'],
            'image': data['image'],
            'category': data['category'],
          };
        }).toList();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  void delete(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to manage your wishlist')),
      );
      return;
    }

    final wishlistCollection =
        FirebaseFirestore.instance.collection('wishlist');

    try {
      await wishlistCollection.doc(product['docId']).delete();
      log('Item removed from wishlist');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Item removed from wishlist.',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );

      setState(() {
        wishlistItems.remove(product);
      });
    } catch (e) {
      log("Error deleting item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Your Wishlist',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: wishlistItems.isEmpty
          ? Center(
              child: Text(
                'Your wishlist is empty.',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: wishlistItems.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListingPage(
                              categoryName: wishlistItems[index]['category'],
                              productId: wishlistItems[index]['id'],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        tileColor: Colors.blue,
                        title: Text(
                          wishlistItems[index]['name'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '₹ ${wishlistItems[index]['price'].toString()}',
                          style: TextStyle(fontSize: 18, color: Colors.purple),
                        ),
                        leading: SizedBox(
                          height: 60,
                          width: 60,
                          child: Image.network(
                            wishlistItems[index]['image'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.image, color: Colors.grey);
                            },
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              delete(wishlistItems[index]);
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
