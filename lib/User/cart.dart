// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supermarket/User/address.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double calculateTotal(List<DocumentSnapshot> cartItems) {
    double total = 0;
    for (var item in cartItems) {
      if (item.data() != null) {
        final price = item['price'] ?? 0;
        final quantity = item['quantity'] ?? 0;
        total += price * quantity;
      } else {
        log('Invalid cart item: ${item.id}');
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Cart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Cart')
            .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            log('Error: ${snapshot.error}');
            return Center(child: Text('Something went wrong!'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Your cart is empty!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          final cartItems = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    final productName = cartItem['name'];
                    final price = cartItem['price'];
                    final image = cartItem['image'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      color: Colors.black,
                      child: ListTile(
                        leading: SizedBox(
                          height: 60,
                          width: 60,
                          child: Image.network(
                            image,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        title: Text(
                          productName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ₹$price',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              'Quantity: ${cartItem['quantity']}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.remove,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                int currentQuantity = cartItem['quantity'];
                                if (currentQuantity > 1) {
                                  await FirebaseFirestore.instance
                                      .collection('Cart')
                                      .doc(cartItem.id)
                                      .update(
                                          {'quantity': currentQuantity - 1});
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('Cart')
                                      .doc(cartItem.id)
                                      .delete();
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add,
                                color: Colors.blue,
                              ),
                              onPressed: () async {
                                int currentQuantity = cartItem['quantity'];
                                int stock = cartItem['stock'];
                                if (currentQuantity < stock) {
                                  await FirebaseFirestore.instance
                                      .collection('Cart')
                                      .doc(cartItem.id)
                                      .update(
                                          {'quantity': currentQuantity + 1});
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('Cart')
                                    .doc(cartItem.id)
                                    .delete();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total: ₹${calculateTotal(cartItems).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (cartItems.isNotEmpty) {
                              double totalAmount = calculateTotal(cartItems);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddressPage(
                                    cartItems: cartItems.map((e) {
                                      return {
                                        'productId': e['productId'],
                                        'productName': e['name'],
                                        'price': e['price'],
                                        'quantity': e['quantity'],
                                        'image': e['image'],
                                      };
                                    }).toList(),
                                    totalAmount: totalAmount,
                                  ),
                                ),
                              );

                              for (var cartItem in cartItems) {
                                await FirebaseFirestore.instance
                                    .collection('Cart')
                                    .doc(cartItem.id)
                                    .delete();
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Cart is empty!'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text(
                            'Checkout',
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
