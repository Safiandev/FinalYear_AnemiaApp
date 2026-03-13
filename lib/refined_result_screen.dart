import 'package:flutter/material.dart';
import 'report_preview_screen.dart';

class RefinedResultScreen extends StatelessWidget {
  const RefinedResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(title: const Text("Refined Results"), centerTitle: true),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                "https://images.unsplash.com/photo-1507238691740-187a5b1d37b8",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "REFINED HB ESTIMATE",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "10.2",
                  style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                ),

                SizedBox(width: 5),

                Text(
                  "g/dL",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Mild Anemia",
                style: TextStyle(color: Colors.orange),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Clinical Correlation",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "The system combined your eye scan and reported symptoms to refine the hemoglobin estimate. Fatigue and dizziness slightly increased the anemia likelihood.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("Fatigue Level"), Text("+0.2 g/dL impact")],
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text("Dizziness"), Text("+0.2 g/dL impact")],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.local_hospital),
                label: const Text("Consult a Doctor"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportPreviewScreen(),
                    ),
                  );
                },
                child: const Text("Download Detailed Report"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
