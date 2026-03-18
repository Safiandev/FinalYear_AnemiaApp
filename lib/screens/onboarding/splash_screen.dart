import 'package:flutter/material.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (progress < 1) {
        setState(() {
          progress += 0.02;
        });

        startLoading();
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int percentage = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 120),

            // LOGO
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.remove_red_eye,
                size: 50,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Anemia Detection',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Using Eyelid Image',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const Spacer(),

            // TEXT + PERCENTAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'INITIALIZING AI',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // PROGRESS BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                color: Colors.blue,
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'AI-Powered Healthcare Diagnostics',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
