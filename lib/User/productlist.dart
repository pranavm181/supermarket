// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:supermarket/User/cart.dart';

class ProductListingPage extends StatefulWidget {
  final String categoryName;
  final String? productId;

  const ProductListingPage({
    super.key,
    required this.categoryName,
    this.productId,
  });

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  late Future<List<Map<String, dynamic>>> productsFuture;
  Map<String, bool> wishlistStatus = {};
  Map<String, bool> cartStatus = {};
  Map<String, dynamic>? selectedProduct;
  @override
  void initState() {
    super.initState();

    if (widget.productId != null) {
      productsFuture = Future.value([]);
      fetchProductById(widget.productId!);
    } else {
      productsFuture = fetchProductsByCategory(widget.categoryName);
      productsFuture.then((products) {
        for (var product in products) {
          checkWishlistStatus(product['id']);
          isInCart(product['id']).then((isInCart) {
            setState(() {
              cartStatus[product['id']] = isInCart;
            });
          });
        }
      });
    }
  }

  Future<void> fetchProductById(String productId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;

        setState(() {
          selectedProduct = {
            'id': docSnapshot.id,
            'name': data['name'],
            'price': data['discountedPrice'] ?? data['price'],
            'originalPrice': data['price'],
            'stock': data['stock'],
            'category': data['category'],
            'image': data['image'],
          };
        });

        checkWishlistStatus(productId);
        isInCart(productId).then((isInCart) {
          setState(() {
            cartStatus[productId] = isInCart;
          });
        });
      } else {
        setState(() {
          selectedProduct = null;
        });
      }
    } catch (e) {
      log("Error fetching product by ID: $e");
      setState(() {
        selectedProduct = null;
      });
    }
  }

  Future<void> checkWishlistStatus(String productId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('wishlist')
          .where('email', isEqualTo: user.email)
          .where('productId', isEqualTo: productId)
          .get();

      setState(() {
        wishlistStatus[productId] = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      log("Error checking wishlist status: $e");
    }
  }

  Future<void> wishlist(Map<String, dynamic> product) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('wishlist')
          .where('email', isEqualTo: user.email)
          .where('productId', isEqualTo: product['id'])
          .get();

      if (querySnapshot.docs.isEmpty) {
        await FirebaseFirestore.instance.collection('wishlist').add({
          'email': user.email,
          'productId': product['id'],
          'productName': product['name'],
          'price': product['price'],
          'image': product['image'],
          'category': product['category'],
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          wishlistStatus[product['id']] = true;
        });
      }
    } catch (e) {
      log("Error adding to wishlist: $e");
    }
  }

  Future<bool> isInCart(String productId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final querySnapshot = await FirebaseFirestore.instance
          .collection('Cart')
          .where('email', isEqualTo: user.email)
          .where('productId', isEqualTo: productId)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      log("Error checking cart: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchProductsByCategory(
      String category) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'id': doc.id,
          'name': data['name'],
          'price': data['discountedPrice'] ?? data['price'],
          'image': data['image'],
          'stock': data['stock'],
          'category': data['category'],
        };
      }).toList();
    } catch (e) {
      log("Error fetching products by category: $e");
      return [];
    }
  }

  void addToCart(Map<String, dynamic> product, int quantity) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('Cart').add({
        'email': user.email,
        'productId': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'category': product['category'],
        'stock': product['stock'],
        'quantity': quantity,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        cartStatus[product['id']] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            '${product['name']} has been added to your cart.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } catch (e) {
      log("Error adding to cart: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Failed to add ${product['name']} to cart. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          widget.productId != null
              ? (selectedProduct?['name'] ?? 'Product Details')
              : '${widget.categoryName} Products',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: widget.productId != null
          ? (selectedProduct != null
              ? productDetailView(selectedProduct!)
              : Center(
                  child: Text(
                    selectedProduct == null
                        ? 'Product not found.'
                        : 'Loading product details...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ))
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error loading products"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "No products found in this category",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }

                final products = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return productCard(products[index]);
                  },
                );
              },
            ),
    );
  }

  Widget productDetailView(Map<String, dynamic> product) {
    final isInCart = cartStatus[product['id']] ?? false;

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.4,
        child: Card(
          color: Colors.black,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product['image'],
                        height: MediaQuery.of(context).size.height * 0.22,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image,
                            size: MediaQuery.of(context).size.height * 0.20,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  product['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(
                  '₹${product['price'].toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                  ),
                ),
                Spacer(),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.05,
                    maxHeight: MediaQuery.of(context).size.height * 0.065,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isInCart) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartPage()));
                      } else {
                        addToCart(product, 1);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInCart ? Colors.green : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      isInCart ? 'Go to Cart' : 'Add to Cart',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.035,
                        color: Colors.white,
                      ),
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

  Widget productCard(Map<String, dynamic> product) {
    final isWishlist = wishlistStatus[product['id']] ?? false;
    final isInCart = cartStatus[product['id']] ?? false;

    return Card(
      color: Colors.black,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product['image'],
                    height: MediaQuery.of(context).size.height * 0.13,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () async {
                      if (isWishlist) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.orange,
                            content: Text(
                              '${product['name']} is already in your wishlist.',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      } else {
                        await wishlist(product);
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.favorite,
                        color: isWishlist ? Colors.redAccent : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Flexible(
              child: Text(
                product['name'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(height: 4),
            Flexible(
              child: Text(
                '₹${product['price'].toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.05,
                maxHeight: MediaQuery.of(context).size.height * 0.065,
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (isInCart) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CartPage()));
                  } else {
                    addToCart(product, 1);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? Colors.green : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isInCart ? 'Go to Cart' : 'Add to Cart',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
