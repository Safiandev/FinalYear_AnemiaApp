import 'dart:async';
import 'package:flutter/material.dart';
import 'refined_result_screen.dart';

class AiRefinementLoadingScreen extends StatefulWidget {
  const AiRefinementLoadingScreen({super.key});

  @override
  State<AiRefinementLoadingScreen> createState() =>
      _AiRefinementLoadingScreenState();
}

class _AiRefinementLoadingScreenState extends State<AiRefinementLoadingScreen> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    Timer.periodic(const Duration(milliseconds: 60), (timer) {
      setState(() {
        progress += 0.01;
      });

      if (progress >= 1) {
        timer.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RefinedResultScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int percent = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: const Text("AI Re-Analysis"), centerTitle: true),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 90, color: Colors.blue),

            const SizedBox(height: 30),

            Text(
              "$percent %",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Re-analyzing with symptoms",
              style: TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 30),

            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              "Combining image data with your symptoms for more accurate results.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
