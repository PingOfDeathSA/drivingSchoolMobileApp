import 'package:driving_school_mobile_app/navigator%20%20menu/nav.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options from the XML
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCeet5bcvL6r2LP75AUzWRaKfS0EljWGrA", // google_api_key
      appId: "1:127813002960:android:e3595c6cd1a92197eba0d5", // google_app_id
      messagingSenderId: "127813002960", // gcm_defaultSenderId
      projectId: "jose-35ba3", // project_id
      authDomain:
          "jose-35ba3.firebaseapp.com", // You can find this in Firebase console
      databaseURL:
          "YOUR_DATABASE_URL", // firebase_database_url (replace with actual value)
      storageBucket:
          "jose-35ba3.appspot.com", // You can find this in Firebase console
      measurementId: "G-MEASUREMENT_ID", // Optional, found in Firebase console
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}
