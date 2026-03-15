import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'previous_reports_screen.dart';
import 'eyelid_capture_screen.dart';
import 'profile_screen.dart';
import 'insights_UI.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  late List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // screens = [
    //   const DashboardScreen(),
    //   PreviousReportsScreen(
    //     onBackToHome: () {
    //       setState(() {
    //         currentIndex = 0; // Back arrow se home tab par switch karna
    //       });
    //     },
    //   ),
    //   const SizedBox(),
    //   Center(
    //     child: TextButton(
    //       onPressed: () {
    //         setState(() {
    //           currentIndex = 0;
    //         });
    //       },
    //       child: const Text("Insights Screen (Coming Soon)"),
    //     ),
    //   ),
    //   Center(
    //     child: TextButton(
    //       onPressed: () {
    //         setState(() {
    //           currentIndex = 0;
    //         });
    //       },
    //       child: const ProfileScreen(),
    //     ),
    //   ),
    // ];

    screens = [
      const DashboardScreen(),

      PreviousReportsScreen(
        onBackToHome: () {
          setState(() {
            currentIndex = 0;
          });
        },
      ),

      const SizedBox(),

      const InsightsUI(),

      const ProfileScreen(),
    ];
  }

  void onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EyelidCaptureScreen()),
      );
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Scan"),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: "Insights",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
