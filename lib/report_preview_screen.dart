import 'package:flutter/material.dart';

class ReportPreviewScreen extends StatelessWidget {
  const ReportPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Report Preview"),
        centerTitle: true,
        actions: const [Icon(Icons.share)],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),

              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.health_and_safety, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "HemoScan AI",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        "MEDICAL REPORT",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.person, size: 40),
                      ),

                      const SizedBox(width: 15),

                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jane Doe",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text("ID: #8821 | Age: 28"),

                          Text("Date: Oct 24, 2023"),
                        ],
                      ),
                    ],
                  ),

                  const Divider(height: 30),

                  const Text(
                    "TEST SUMMARY",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    "10.8 g/dL",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),

                  const Text(
                    "Estimated Hemoglobin Level",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "MODERATE ANEMIA",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// SYMPTOM ANALYSIS
            const Text(
              "SYMPTOM ANALYSIS",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),

            const SizedBox(height: 15),

            symptomTile("Persistent Fatigue"),
            symptomTile("Pale Inner Eyelids"),
            symptomTile("Shortness of Breath"),

            const SizedBox(height: 30),

            /// RECOMMENDATIONS
            const Text(
              "RECOMMENDATIONS",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),

            const SizedBox(height: 15),

            recommendationTile(
              Icons.restaurant,
              "Iron-Rich Diet",
              "Increase intake of spinach, red meat, lentils, and fortified cereals.",
            ),

            const SizedBox(height: 15),

            recommendationTile(
              Icons.local_hospital,
              "Clinical Confirmation",
              "Please consult a physician for a complete blood count (CBC).",
            ),

            const SizedBox(height: 40),

            /// DOWNLOAD BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text("Download PDF Report"),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text("Share with Doctor"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SYMPTOM TILE
  Widget symptomTile(String text) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: Text(text),
      ),
    );
  }

  /// RECOMMENDATION TILE
  Widget recommendationTile(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
    );
  }
}
