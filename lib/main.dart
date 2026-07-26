import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 1. NotificationService ka import yahan add kar dein:
import 'package:hemoglobe_ai/services/notification_service.dart';
import 'package:hemoglobe_ai/screens/onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initNotification();
  // await NotificationService.init();

  try {
    await Firebase.initializeApp(
        // options: DefaultFirebaseOptions.currentPlatform, // Agar options file bani hui hai to uncomment kar lein
        );
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  // 4. App Launch (Sirf ek baar call hoga Firebase aur Notifications initialize hone ke baad)
  runApp(const MyApp());
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hemoglobe AI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      navigatorObservers: [routeObserver], // ✅ Ye add karein
      home: const SplashScreen(),
    );
  }
}
