import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/main_navigation_screen.dart';

class InsightsUI extends StatelessWidget {
  const InsightsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        /// Back button -> Main Navigation (Home tab)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(),
              ),
            );
          },
        ),

        title: const Text(
          "Health Insights",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Health Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Text(
                    "Health Score",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "72 / 100",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Based on Hb level, scan frequency and improvement",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Health Analysis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            insightCard(
              icon: Icons.warning,
              color: Colors.orange,
              title: "Risk Level",
              subtitle: "Mild Risk detected from your recent scan.",
            ),

            const SizedBox(height: 12),

            insightCard(
              icon: Icons.monitor_heart,
              color: Colors.red,
              title: "Average Hemoglobin",
              subtitle: "Your average Hb level is 12.4 g/dL.",
            ),

            const SizedBox(height: 12),

            insightCard(
              icon: Icons.repeat,
              color: Colors.green,
              title: "Scan Consistency",
              subtitle: "You completed 5 scans this month.",
            ),

            const SizedBox(height: 12),

            insightCard(
              icon: Icons.bar_chart,
              color: Colors.purple,
              title: "Healthy Range",
              subtitle: "Recommended hemoglobin range is 13 – 17 g/dL.",
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Tip: Eating iron-rich foods like spinach, beans and red meat can help improve hemoglobin levels.",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget insightCard({
  required IconData icon,
  required Color color,
  required String title,
  required String subtitle,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
