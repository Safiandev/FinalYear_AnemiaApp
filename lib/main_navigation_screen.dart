import 'package:flutter/services.dart'; // SystemNavigator ke liye
import 'package:flutter/material.dart';
import 'package:hemoglobe_ai/user_provider.dart';
import 'package:hemoglobe_ai/screens/dashboard/dashboard_screen.dart';
import 'package:hemoglobe_ai/screens/reports/previous_reports_screen.dart';
import 'package:hemoglobe_ai/screens/scan/eyelid_capture_screen.dart';
import 'package:hemoglobe_ai/screens/profile/profile_screen.dart';
import 'package:hemoglobe_ai/screens/dashboard/insights_UI.dart';

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

    // ✅ App load hotay hi UserProvider ka data ensure karlo
    _loadUserData();

    screens = [
      const DashboardScreen(),
      PreviousReportsScreen(
        onBackToHome: () {
          setState(() {
            currentIndex = 0;
          });
        },
      ),
      const SizedBox(), // Placeholder for Scan button
      const InsightsUI(),
      const ProfileScreen(),
    ];
  }

  Future<void> _loadUserData() async {
    await UserProvider.initUserData();
    if (mounted) setState(() {});
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
    return PopScope(
      canPop: false, // Prevents back navigation to login screen
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;

        // Agar user kisi doosre tab par hai, to pehle Home tab par le aao
        if (currentIndex != 0) {
          setState(() {
            currentIndex = 0;
          });
        } else {
          // Agar pehle se Home tab par hai, to poori App close/minimize kar do
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        // ✅ FIX: IndexedStack state maintain rakhta hai, screens reset nahi hotin
        body: IndexedStack(
          index: currentIndex,
          children: screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "History"),
            BottomNavigationBarItem(
                icon: Icon(Icons.camera_alt), label: "Scan"),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights),
              label: "Insights",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/services.dart'; // SystemNavigator ke liye
// import 'package:flutter/material.dart';
// import 'package:hemoglobe_ai/screens/dashboard/dashboard_screen.dart';
// import 'package:hemoglobe_ai/screens/reports/previous_reports_screen.dart';
// import 'package:hemoglobe_ai/screens/scan/eyelid_capture_screen.dart';
// import 'package:hemoglobe_ai/screens/profile/profile_screen.dart';
// import 'package:hemoglobe_ai/screens/dashboard/insights_UI.dart';

// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int currentIndex = 0;

//   late List<Widget> screens;

//   @override
//   void initState() {
//     super.initState();

//     screens = [
//       const DashboardScreen(),
//       PreviousReportsScreen(
//         onBackToHome: () {
//           setState(() {
//             currentIndex = 0;
//           });
//         },
//       ),
//       const SizedBox(),
//       const InsightsUI(),
//       const ProfileScreen(),
//     ];
//   }

//   void onTabTapped(int index) {
//     if (index == 2) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => const EyelidCaptureScreen()),
//       );
//       return;
//     }

//     setState(() {
//       currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false, // Prevents back navigation to login screen
//       onPopInvokedWithResult: (bool didPop, dynamic result) {
//         if (didPop) return;

//         // Agar user kisi doosre tab par hai, to pehle Home tab par le aao
//         if (currentIndex != 0) {
//           setState(() {
//             currentIndex = 0;
//           });
//         } else {
//           // Agar pehle se Home tab par hai, to poori App close/minimize kar do
//           SystemNavigator.pop();
//         }
//       },
//       child: Scaffold(
//         body: screens[currentIndex],
//         bottomNavigationBar: BottomNavigationBar(
//           currentIndex: currentIndex,
//           type: BottomNavigationBarType.fixed,
//           selectedItemColor: Colors.blue,
//           unselectedItemColor: Colors.grey,
//           onTap: onTabTapped,
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.history), label: "History"),
//             BottomNavigationBarItem(
//                 icon: Icon(Icons.camera_alt), label: "Scan"),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.insights),
//               label: "Insights",
//             ),
//             BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//           ],
//         ),
//       ),
//     );
//   }
// }
