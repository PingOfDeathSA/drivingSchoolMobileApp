import 'package:driving_school_mobile_app/navigator%20%20menu/nav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'authentication/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : BottomNavigationBarExample(
              useremail: FirebaseAuth.instance.currentUser!.email.toString(),
              username: FirebaseAuth.instance.currentUser?.displayName ?? '',
            ),
    );
  }
}
