// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:supermarket/User/payment.dart';

class AddressPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const AddressPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController pincode = TextEditingController();
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
          name.text = userDoc['name'] ?? '';
        });
      }
    }
  }

  void fetchAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location services are disabled.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied.')),
          );
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        setState(() {
          address.text = placemark.street ?? '';
          city.text = placemark.locality ?? '';
          pincode.text = placemark.postalCode ?? '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Address fetched successfully!')),
        );
      }
    } catch (e) {
      log('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch address: $e')),
      );
    }
  }

  InputDecoration _inputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 2, color: Colors.black),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.lightBlue[200],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      padding: EdgeInsets.all(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[200],
      appBar: AppBar(
        title: Text('Address Collection'),
        forceMaterialTransparency: true,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Your Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: name,
                        decoration: _inputDecoration('Name'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: phone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [LengthLimitingTextInputFormatter(10)],
                        decoration: _inputDecoration('Phone Number'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          } else if (value.length != 10) {
                            return 'Phone number must be 10 digits';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: pincode,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6)
                              ],
                              decoration: _inputDecoration('Pin Code'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your pin code';
                                } else if (value.length != 6) {
                                  return 'Pin code must be 6 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton.icon(
                              onPressed: fetchAddress,
                              icon: Icon(Icons.location_on,
                                  color: Colors.lightBlue),
                              label: Text('Use Location',
                                  style: TextStyle(color: Colors.lightBlue)),
                              style: _buttonStyle(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: address,
                        decoration: _inputDecoration('Address'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your address' : null,
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: city,
                        decoration: _inputDecoration('City'),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your city' : null,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentsPage(
                              cartItems: widget.cartItems,
                              totalAmount: widget.totalAmount,
                              address: {
                                'name': name.text,
                                'phone': phone.text,
                                'address': address.text,
                                'city': city.text,
                                'pincode': pincode.text,
                              },
                            ),
                          ),
                        );
                      }
                    },
                    style: _buttonStyle(),
                    child: Text('Proceed',
                        style:
                            TextStyle(color: Colors.lightBlue, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
