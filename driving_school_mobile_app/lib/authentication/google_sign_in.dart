import 'package:driving_school_mobile_app/authentication/profile_screen.dart';
import 'package:driving_school_mobile_app/colors.dart';
import 'package:driving_school_mobile_app/navigator%20%20menu/nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  // Check if the user is in the learnersProfile collection
  Future<void> checkUserProfile(User user, BuildContext context) async {
    try {
      // Get a reference to the Firestore collection
      final usersCollection =
          FirebaseFirestore.instance.collection('learnersProfile');

      // Check if the user exists by querying the collection
      final userDoc = await usersCollection.doc(user.uid).get();

      if (userDoc.exists) {
        // If the user exists, route to BottomNavigationBarExample
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationBarExample(
            useremail : user.email.toString(),
            username : userDoc.get('name'), // Passing the user's name to the home screen
            
          )),
        );
      } else {
        // If the user doesn't exist, route to the Profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ProfilePage(user: user)), // Passing the user to profile page
        );
      }
    } catch (e) {
      print("Error checking user profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login with Google"),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                User? user = await _authService.signInWithGoogle();
                if (user != null) {
                  print("Signed in: ${user.displayName}");
                  // Check if the user is in the learnersProfile collection
                  await checkUserProfile(user, context);
                } else {
                  print("Failed to sign in");
                }
              },
              child: Text(
                "Sign in with Google",
                style: TextStyle(fontSize: 20, color: customblack),
              ),
            ),
            SizedBox(width: 10),
            Image.asset('assets/google.png', width: 30, height: 30),
          ],
        ),
      ),
    );
  }
}
