import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. Ye import lazmi hai
import 'package:hemoglobe_ai/screens/onboarding/splash_screen.dart';

// Firebase options file (agar aapne flutterfire configure kiya hai)
// import 'firebase_options.dart';

void main() async {
  // 2. Flutter engine ko initialize karna
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Firebase initialize karna (ye sab se zaroori step hai)
  try {
    await Firebase.initializeApp(
        // options: DefaultFirebaseOptions.currentPlatform, // Agar firebase_options.dart hai to isay uncomment karein
        );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hemoglobe AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true, // Modern UI ke liye
      ),
      home: const SplashScreen(),
    );
  }
}
