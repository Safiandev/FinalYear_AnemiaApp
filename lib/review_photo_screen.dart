import 'package:flutter/material.dart';
import 'ai_analysis_screen.dart';

class ReviewPhotoScreen extends StatelessWidget {
  const ReviewPhotoScreen({super.key});

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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Review Photo Quality',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      // -------- BODY --------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- IMAGE PREVIEW --------
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/eye_sample.jpg', // temporary image
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Capture: Today, 10:42 AM',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'QUALITY CHECKLIST',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),

            const SizedBox(height: 15),

            _qualityTile(
              icon: Icons.light_mode,
              title: 'Lighting',
              subtitle: 'Optimal brightness detected',
              iconColor: Colors.green,
            ),

            _qualityTile(
              icon: Icons.center_focus_strong,
              title: 'Focus',
              subtitle: 'Target area is sharp',
              iconColor: Colors.green,
            ),

            _qualityTile(
              icon: Icons.remove_red_eye,
              title: 'Clarity',
              subtitle: 'Slight Blur Detected',
              iconColor: Colors.orange,
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'For the most accurate result, we recommend retaking the photo in a brighter area to reduce blur.',
                style: TextStyle(color: Colors.orange),
              ),
            ),

            const SizedBox(height: 30),

            // -------- ANALYZE BUTTON --------
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AiAnalysisScreen()),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Analyze Anyway',
                style: TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 15),

            // -------- RETAKE BUTTON --------
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Retake Photo', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // -------- QUALITY TILE --------
  static Widget _qualityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.1),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: TextStyle(color: iconColor)),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: iconColor),
        ],
      ),
    );
  }
}
