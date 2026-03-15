// File: profile_screen.dart

import 'package:flutter/material.dart';
import 'medical_history_screen.dart';
import 'personal_info_screen.dart';
import 'privacy_data_screen.dart';
import 'notification_preferences_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart'; // Make sure this exists

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // -------- APP BAR --------
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),

      // -------- BODY --------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // PROFILE IMAGE
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    "https://i.pravatar.cc/150?img=5",
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Text(
              "Safian",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              "safian@gmail.com",
              style: TextStyle(color: Colors.blueGrey),
            ),
            const SizedBox(height: 30),

            // -------- ACCOUNT & HEALTH --------
            sectionTitle("Account & Health"),
            profileTile(Icons.person, "Personal Information", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PersonalInfoScreen(),
                ),
              );
            }),
            profileTile(Icons.description, "Medical History", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalHistoryScreen(),
                ),
              );
            }),

            const SizedBox(height: 20),

            // -------- SECURITY & PREFERENCES --------
            sectionTitle("Security & Preferences"),
            profileTile(Icons.shield, "Privacy & Data Security", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyDataSecurityScreen(),
                ),
              );
            }),
            profileTile(Icons.notifications, "Notification Preferences", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationPreferencesScreen(),
                ),
              );
            }),

            const SizedBox(height: 20),

            // -------- HELP --------
            sectionTitle("Help"),
            profileTile(Icons.help, "Help & Support", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            }),

            const SizedBox(height: 30),

            // -------- LOGOUT BUTTON --------
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Do you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -------- APP INFO --------
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

  // -------- SECTION TITLE --------
  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  // -------- PROFILE TILE --------
  Widget profileTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
