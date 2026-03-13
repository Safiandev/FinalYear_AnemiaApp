import 'package:flutter/material.dart';
import 'symptom_questionnaire_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text("Results", style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.share, color: Colors.black),
          ),
        ],
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hemoglobin Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: const [
                  Text(
                    "HEMOGLOBIN LEVEL",
                    style: TextStyle(color: Colors.blueGrey, letterSpacing: 1),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "11.5 g/dL",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Chip(
                    label: Text(
                      "Mild Anemia",
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Range Comparison
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Range Comparison",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: 0.4,
                    color: Colors.orange,
                    backgroundColor: Colors.green,
                  ),

                  const SizedBox(height: 10),
                  const Text("Normal: 13.5 - 17.5"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Next Steps
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const ListTile(
                leading: Icon(Icons.local_hospital, color: Colors.blue),
                title: Text("Consult a Doctor"),
                subtitle: Text("Verify results with a clinical blood test."),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),

            const SizedBox(height: 15),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const ListTile(
                leading: Icon(Icons.eco, color: Colors.green),
                title: Text("Iron-Rich Diet"),
                subtitle: Text("Include spinach, red meat and lentils."),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),

            const SizedBox(height: 20),

            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset("assets/eye_sample.jpg"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SymptomQuestionnaireScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Start Professional Test",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
