import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/screens/profile/change_password_screen.dart';

class PrivacyDataSecurityScreen extends StatefulWidget {
  const PrivacyDataSecurityScreen({super.key});

  @override
  State<PrivacyDataSecurityScreen> createState() =>
      _PrivacyDataSecurityScreenState();
}

class _PrivacyDataSecurityScreenState extends State<PrivacyDataSecurityScreen> {
  bool twoFactorEnabled = false;
  bool suspiciousAlertEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Privacy & Data Security",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Account Security Section
            sectionTitle("Account Security"),

            // Change Password
            securityOption(
              icon: Icons.lock,
              title: "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            // Two-Factor Authentication
            securityOption(
              icon: Icons.fingerprint,
              title: "Two-Factor Authentication",
              trailing: Switch(
                value: twoFactorEnabled,
                onChanged: (val) {
                  setState(() {
                    twoFactorEnabled = val;
                  });
                },
              ),
            ),

            // Suspicious Login Alerts
            securityOption(
              icon: Icons.security,
              title: "Suspicious Login Alerts",
              trailing: Switch(
                value: suspiciousAlertEnabled,
                onChanged: (val) {
                  setState(() {
                    suspiciousAlertEnabled = val;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            // Data Management Section
            sectionTitle("Data Management"),

            // Export My Data
            securityOption(
              icon: Icons.download,
              title: "Export My Data",
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Your data has been exported successfully."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Delete My Account
            securityOption(
              icon: Icons.delete_forever,
              title: "Delete My Account",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Account"),
                    content: const Text(
                      "Are you sure you want to delete your account? This action cannot be undone.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Add delete account logic
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Account deleted successfully"),
                            ),
                          );
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            const Text(
              "HemaScan AI v2.4.1",
              style: TextStyle(color: Colors.grey),
            ),
            const Text(
              "Managed Healthcare Data Security",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION TITLE WIDGET
  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  // SECURITY OPTION TILE
  Widget securityOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
