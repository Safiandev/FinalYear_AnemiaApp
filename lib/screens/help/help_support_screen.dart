import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hemoglobe_ai/screens/reports/report_problem_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String emailPath) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailPath,
      queryParameters: {'subject': 'HemoGlobe AI Support Inquiry'},
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Direct Support Options
            const Text(
              "Contact Support",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildContactTile(
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "support@hemoglobe.ai",
              onTap: () => _sendEmail("support@hemoglobe.ai"),
            ),
            const SizedBox(height: 10),

            _buildContactTile(
              icon: Icons.phone_outlined,
              title: "Call Helpline",
              subtitle: "+92 300 123 4567",
              onTap: () => _makePhoneCall("+923001234567"),
            ),
            const SizedBox(height: 10),

            _buildContactTile(
              icon: Icons.bug_report_outlined,
              title: "Report a Problem",
              subtitle: "Found an issue or bug in the app?",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReportProblemScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Section 2: FAQs
            const Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildFaqTile(
              question: "How to update my profile details?",
              answer:
                  "Navigate to Profile > Edit Profile to update your name, age, gender, blood group, and other medical details.",
            ),
            const SizedBox(height: 10),

            _buildFaqTile(
              question: "How to reset my password?",
              answer:
                  "Go to Profile > Privacy & Data Security > Change Password to update your password securely.",
            ),
            const SizedBox(height: 10),

            _buildFaqTile(
              question: "How accurate are the Hemoglobin predictions?",
              answer:
                  "HemoGlobe AI estimates Hb levels based on visual scan analysis. These results serve as a screening guide and should be verified with a clinical CBC lab test.",
            ),
            const SizedBox(height: 10),

            _buildFaqTile(
              question: "What lighting conditions give the best scan?",
              answer:
                  "Capture photos in clear natural daylight or well-lit white indoor light, avoiding glare or dark shadows for accurate AI prediction.",
            ),

            const SizedBox(height: 40),

            // Section 3: Footer Version Info
            const Center(
              child: Text(
                "HemoGlobe AI v2.4.1",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                "Managed Healthcare Data Security",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Clean Contact Tile
  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.blueAccent.shade700, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }

  // Clean FAQ Tile
  Widget _buildFaqTile({
    required String question,
    required String answer,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
