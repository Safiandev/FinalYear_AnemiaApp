import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/screens/scan/eyelid_capture_screen.dart';

class HowToCaptureScreen extends StatelessWidget {
  const HowToCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // -------- APP BAR --------
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'How to Capture',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      // -------- BODY --------
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- IMAGE --------
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/eyelid_guide.png', // image add karni hogi
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // -------- TITLE --------
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Step-by-Step Guide',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Text(
                'Follow these steps for an accurate reading.',
                style: TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 20),

            // -------- STEPS --------
            _buildStep(
              number: '1',
              title: 'Pull down lower eyelid',
              description:
                  'Gently use one finger to reveal the inner red/pink conjunctiva area.',
            ),

            _buildStep(
              number: '2',
              title: 'Ensure bright, even lighting',
              description:
                  'Face a window or a well-lit area. Avoid harsh direct sun or dark shadows.',
            ),

            _buildStep(
              number: '3',
              title: 'Keep phone steady',
              description:
                  'Hold your phone about 6 inches away. The app will capture automatically when in focus.',
            ),

            const SizedBox(height: 30),

            // -------- START CAPTURE BUTTON --------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EyelidCaptureScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text(
                  'Start Capture',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // -------- STEP WIDGET --------
  static Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blue,
            child: Text(number, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
