import 'package:flutter/material.dart';
import 'review_photo_screen.dart';

class EyelidCaptureScreen extends StatelessWidget {
  const EyelidCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // -------- FAKE CAMERA BACKGROUND --------
          Positioned.fill(
            child: Image.asset(
              'assets/camera_bg.jpg', // temporary image
              fit: BoxFit.cover,
            ),
          ),

          // -------- TOP BAR --------
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Eyelid Capture',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.help_outline, color: Colors.white),
                ],
              ),
            ),
          ),

          // -------- CENTER OVERLAY --------
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Move closer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Looking for better light',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // -------- SCAN FRAME --------
                Container(
                  width: 260,
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),

                const SizedBox(height: 20),

                // -------- READY BUTTON --------
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'READY TO CAPTURE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // -------- BOTTOM CONTROLS --------
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'AI Scanning...',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Quality Score: 88%'),
                    ],
                  ),

                  const SizedBox(height: 8),

                  LinearProgressIndicator(
                    value: 0.88,
                    color: Colors.blue,
                    backgroundColor: Colors.grey.shade300,
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: const [
                          Icon(Icons.image, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('Gallery'),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          // 👇 fake photo capture ke baad next screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReviewPhotoScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blue, width: 4),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.blue,
                            ),
                          ),
                        ),
                      ),

                      Column(
                        children: const [
                          Icon(Icons.flash_on, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('Flash'),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Gently pull down your lower eyelid to reveal the inner red surface.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
