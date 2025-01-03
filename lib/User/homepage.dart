// ignore_for_file: prefer_const_constructors

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supermarket/User/cart.dart';
import 'package:supermarket/User/productlist.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<String> categories = <String>[
    'Fruits & Vegetables',
    'Drinks',
    'Snacks',
    'Household',
    'Stationary',
    'Diary',
  ];

  final List<String> categoryImages = <String>[
    'lib/Images/fruits.png',
    'lib/Images/Drinks.png',
    'lib/Images/snacks.png',
    'lib/Images/household.png',
    'lib/Images/stationery.png',
    'lib/Images/diary.png',
  ];

  Map<String, String> categoryImageMap = {};

  @override
  void initState() {
    super.initState();

    categoryImageMap = Map.fromIterables(
      List<String>.from(categories),
      List<String>.from(categoryImages),
    );
  }

  Future<Map<String, dynamic>?> fetchOfferOfTheDay() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('offersOfTheDay')
          .where('validUpto', isGreaterThanOrEqualTo: Timestamp.now())
          .orderBy('validUpto', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }
    } catch (e) {
      log("Error fetching offer of the day: $e");
    }
    return null;
  }

  Future<void> updateProductPricesBasedOnOffer(
      String category, double discount) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final originalPrice = data['price'] as double;

        final discountedPrice = originalPrice * ((100 - discount) / 100);

        await FirebaseFirestore.instance
            .collection('products')
            .doc(doc.id)
            .update({'discountedPrice': discountedPrice});

        log('Updated product ${data['name']} price to $discountedPrice');
      }
    } catch (e) {
      log("Error updating product prices: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        title: Text(
          'SuperMart',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CartPage()),
              );
            },
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
              size: 25,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: fetchOfferOfTheDay(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return Card(
                      color: Colors.blue,
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No offer of the day available.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  }

                  final offer = snapshot.data!;
                  final category = offer['category'];
                  final discount = offer['discount'].toDouble();
                  final image =
                      categoryImageMap[category] ?? 'lib/Images/default.png';

                  updateProductPricesBasedOnOffer(category, discount);

                  return Card(
                    color: Colors.blueAccent,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.asset(
                            image,
                            height: 80,
                            width: 80,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Offer of the Day',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Get $discount% off on $category!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 15),
              Text(
                'Shop With Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              GridView.builder(
                itemCount: categories.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductListingPage(
                          categoryName: categories[index],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.black87,
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(categoryImages[index]),
                          ),
                        ),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.lightBlue[200],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
