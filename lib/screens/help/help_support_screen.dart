import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/screens/reports/report_problem_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQs Section
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const ExpansionTile(
              title: Text("How to update my profile?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Go to the Profile section and click on the edit icon to update your information.",
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text("How do I reset my password?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "You can reset your password via the 'Privacy & Data Security' section under Profile.",
                  ),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text("How to contact support?"),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Use the contact options below to get in touch with our support team.",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Contact Support Section
            const Text(
              "Contact Support",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text("Email Support"),
              subtitle: const Text("support@hemascan.com"),
              onTap: () {
                // TODO: Open email app or copy email
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text("Call Support"),
              subtitle: const Text("+1 800 123 4567"),
              onTap: () {
                // TODO: Open dialer with phone number
              },
            ),

            const SizedBox(height: 30),

            // Report an Issue Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportProblemScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.report_problem),
                label: const Text("Report a Problem"),
              ),
            ),

            const SizedBox(height: 30),

            // App version info
            const Center(
              child: Text(
                "HemaScan AI v2.4.1",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const Center(
              child: Text(
                "Managed Healthcare Data Security",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
