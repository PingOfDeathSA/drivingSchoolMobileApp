import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../navigator  menu/nav.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Save the user profile to Firestore
  Future<void> saveProfile() async {
    try {
      // Get the Firestore collection
      final usersCollection =
          FirebaseFirestore.instance.collection('learnersProfile');

      // Create a user document with the UID as the document ID
      await usersCollection.doc(widget.user.uid).set({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': widget.user.email,
        'uid': widget.user.uid,
      });

      // After saving, navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationBarExample()),
      );
    } catch (e) {
      print("Error saving profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveProfile();
                  }
                },
                child: Text("Save Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
