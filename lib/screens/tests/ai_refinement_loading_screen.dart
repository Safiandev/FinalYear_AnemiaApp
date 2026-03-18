import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/screens/tests/refined_result_screen.dart';

class AiRefinementLoadingScreen extends StatefulWidget {
  final double refinedHb; // <-- Receiver for the calculated result
  final List<String> selectedSymptoms;
  const AiRefinementLoadingScreen(
      {super.key, required this.refinedHb, required this.selectedSymptoms});

  @override
  State<AiRefinementLoadingScreen> createState() =>
      _AiRefinementLoadingScreenState();
}

class _AiRefinementLoadingScreenState extends State<AiRefinementLoadingScreen> {
  double progress = 0;
  String loadingText = "Analyzing symptoms...";

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    // Timer to update progress and texts for a realistic AI feel
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          progress += 0.01;

          // Changing text based on progress for better UX
          if (progress > 0.3) loadingText = "Merging eye-scan data...";
          if (progress > 0.6) loadingText = "Applying ML refinement...";
          if (progress > 0.8) loadingText = "Finalizing results...";
        });
      }

      if (progress >= 1) {
        timer.cancel();

        // FIXED NAVIGATION: Passing both HB value and Symptoms List
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RefinedResultScreen(
              finalHb: widget.refinedHb,
              // Yahan check karein ke loading screen ke widget mein symptoms ki list ka kya naam hai
              // Agar widget.selectedSymptoms hai to wahi use karein
              userSymptoms: widget.selectedSymptoms,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int percent = (progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AI Re-Analysis",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back during analysis
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // STEP indicator
            const Text(
              "STEP 4 OF 4",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Icon with soft animation feel
            const Icon(Icons.psychology_outlined,
                size: 100, color: Colors.blue),
            const SizedBox(height: 30),

            // Percentage display
            Text(
              "$percent%",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),

            // Dynamic loading text
            Text(
              loadingText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),

            // Modern progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 30),

            // Subtitle info
            const Text(
              "Combining your clinical symptoms with visual image data for a precision-refined Hemoglobin estimate.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
