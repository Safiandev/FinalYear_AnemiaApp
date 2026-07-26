import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemoglobe_ai/user_provider.dart';
import 'package:hemoglobe_ai/how_to_capture_screen.dart';
import 'package:hemoglobe_ai/diet_suggestions_screen.dart';
import 'package:hemoglobe_ai/screens/reports/previous_reports_screen.dart';
import 'package:hemoglobe_ai/screens/settings/reminders_screen.dart';
import 'package:hemoglobe_ai/screens/find_clinics/find_clinics_screen.dart';
import 'package:hemoglobe_ai/screens/profile/profile_screen.dart';
import 'package:hemoglobe_ai/screens/notification_history_screen.dart';
import 'package:hemoglobe_ai/main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with RouteAware {
  bool _isLoading = true;
  bool _hasUnreadNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _checkUnreadStatus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Route observer ke sath is screen ko subscribe karein
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // ✅ Ye method automatically call hota hai jab bhi koi screen (Profile Screen waghera)
  // se wapas is Dashboard par aaya jaye — chahe kisi bhi button/tarike se gaya ho
  @override
  void didPopNext() {
    super.didPopNext();
    setState(() {
      // UserProvider.userPhotoBase64 ab dobara read hoga, naya avatar dikhega
    });
  }

  Future<void> _checkUnreadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedData = prefs.getString('app_notification_history');
    if (storedData != null && storedData.isNotEmpty) {
      try {
        List<dynamic> jsonList = jsonDecode(storedData);
        bool unreadExists = jsonList.any((item) => item['isRead'] == false);
        if (mounted) {
          setState(() {
            _hasUnreadNotifications = unreadExists;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _hasUnreadNotifications = false);
      }
    } else {
      if (mounted) setState(() => _hasUnreadNotifications = false);
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Always pass forceRefresh: true so app kill hone par bhi Firestore se profile image reload ho sakay
      await UserProvider.initUserData(forceRefresh: true);
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Safe Helper to extract numeric Hb Value from Firestore document map
  double _extractHbValue(Map<String, dynamic> data) {
    var raw = data['hbValue'] ??
        data['hb_level'] ??
        data['hb'] ??
        data['hemoglobin'] ??
        data['result'];

    if (raw == null) return 0.0;
    return double.tryParse(raw.toString().replaceAll(RegExp(r'[^0-9.]'), '')) ??
        0.0;
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEE, MMM d').format(DateTime.now());
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
             GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                // ✅ ValueListenableBuilder khud-bakhud rebuild hoga jab bhi
                // photoNotifier update ho — chahe IndexedStack ho, push/pop ho, kuch bhi ho
                child: ValueListenableBuilder<String?>(
                  valueListenable: UserProvider.photoNotifier,
                  builder: (context, photoBase64, child) {
                    return CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      backgroundImage: (photoBase64 != null &&
                              photoBase64.trim().isNotEmpty)
                          ? MemoryImage(base64Decode(photoBase64))
                          : null,
                      child: (photoBase64 == null || photoBase64.trim().isEmpty)
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              _isLoading
                  ? const SizedBox(
                      height: 15,
                      width: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${UserProvider.userName ?? "User"}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon:
                      const Icon(Icons.notifications_none, color: Colors.black),
                  tooltip: "Notifications Center",
                  onPressed: () async {
                    // Notification Screen par jana
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotificationHistoryScreen(),
                      ),
                    ).then((_) {
                      _checkUnreadStatus();
                    });
                    // Wapis aane par check karna ke abhi bhi unread hain ya nahi
                  },
                ),
                // 💡 ONLY Show Red Dot if _hasUnreadNotifications is TRUE
                if (_hasUnreadNotifications)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI SCAN CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'AI POWERED',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Icon(Icons.camera_alt, color: Colors.white, size: 40),
                  const SizedBox(height: 15),
                  const Text(
                    'Start New Test',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Scan your eyelid for instant anemia detection using our medical AI.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HowToCaptureScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Scan Now',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Medical Suite',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                FeatureCard(
                  icon: Icons.description,
                  title: 'Previous Reports',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PreviousReportsScreen()),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.apple,
                  title: 'Diet Suggestions',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DietSuggestionsScreen()),
                    );
                  },
                ),
                FeatureCard(
                  icon: Icons.alarm,
                  title: 'Reminders',
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RemindersScreen()),
                    ).then((_) {
                      _checkUnreadStatus();
                    });
                  },
                ),
                FeatureCard(
                  icon: Icons.location_on,
                  title: 'Find Clinics',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FindClinicsScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 25),

            // HEALTH TRENDS SECTION
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Health Trends',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreviousReportsScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // STREAM MATCHING FIRESTORE INDEX (ROOT 'reports' COLLECTION)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('userId', isEqualTo: currentUserId)
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  debugPrint("Firestore Stream Error: ${snapshot.error}");
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyTrendCard();
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                List<Map<String, dynamic>> reports = docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList();

                final bool hasReports = reports.isNotEmpty;
                final bool hasMultipleReports = reports.length > 1;

                double latestLevel = 0.0;
                double previousLevel = 0.0;

                if (hasReports) {
                  latestLevel = _extractHbValue(reports.last);
                }

                if (hasMultipleReports) {
                  previousLevel = _extractHbValue(reports[reports.length - 2]);
                }

                double difference = latestLevel - previousLevel;
                bool isImproved = difference >= 0;

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hemoglobin Level',
                                style:
                                    TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    latestLevel > 0
                                        ? latestLevel.toStringAsFixed(1)
                                        : "0.0",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    ' g/dL',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (hasMultipleReports)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isImproved
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isImproved
                                                ? Icons.arrow_upward
                                                : Icons.arrow_downward,
                                            size: 12,
                                            color: isImproved
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${isImproved ? '+' : ''}${difference.toStringAsFixed(1)}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isImproved
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Latest Scan',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // LINE CHART (fl_chart)
                      SizedBox(
                        height: 90,
                        child: LineChart(
                          LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            lineTouchData: const LineTouchData(enabled: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: reports.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  double val = _extractHbValue(entry.value);
                                  return FlSpot(index.toDouble(), val);
                                }).toList(),
                                isCurved: true,
                                color: Colors.blue,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: reports.length < 6,
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.blue.withOpacity(0.15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        hasMultipleReports
                            ? 'Based on your last ${reports.length} scans.'
                            : 'First test recorded. Perform another scan to view trends.',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTrendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          const Text(
            'No Health Data Available',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Perform your first AI scan test to track your hemoglobin trends here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:hemoglobe_ai/user_provider.dart';
// import 'package:hemoglobe_ai/how_to_capture_screen.dart';
// import 'package:hemoglobe_ai/diet_suggestions_screen.dart';
// import 'package:hemoglobe_ai/screens/reports/previous_reports_screen.dart';
// import 'package:hemoglobe_ai/screens/settings/reminders_screen.dart';
// import 'package:hemoglobe_ai/screens/find_clinics/find_clinics_screen.dart';
// import 'package:hemoglobe_ai/screens/profile/profile_screen.dart';
// import 'package:fl_chart/fl_chart.dart';

// class DashboardScreen extends StatefulWidget {
//   const DashboardScreen({super.key});

//   @override
//   State<DashboardScreen> createState() => _DashboardScreenState();
// }

// Widget _buildEmptyTrendCard() {
//   return Container(
//     width: double.infinity,
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       border: Border.all(color: Colors.grey.shade200),
//     ),
//     child: Column(
//       children: [
//         Icon(
//           Icons.show_chart_rounded,
//           size: 40,
//           color: Colors.grey.shade400,
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'No Health Data Available',
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//             color: Colors.black70,
//           ),
//         ),
//         const SizedBox(height: 4),
//         const Text(
//           'Perform your first AI scan test to track your hemoglobin trends here.',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//       ],
//     ),
//   );
// }

// class _DashboardScreenState extends State<DashboardScreen> {
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadInitialData();
//   }

//   // ✅ Fix: Data fetch karne ke baad UI refresh karna zaroori hai
//   Future<void> _loadInitialData() async {
//     try {
//       // Sirf tabhi fetch karein agar pehle se loaded na ho
//       if (!UserProvider.isDataLoaded) {
//         await UserProvider.initUserData();
//       }
//     } catch (e) {
//       debugPrint("Error loading dashboard data: $e");
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     String formattedDate = DateFormat('EEE, MMM d').format(DateTime.now());

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         automaticallyImplyLeading: false,
//         titleSpacing: 0,
//         title: Padding(
//           padding: const EdgeInsets.only(left: 16),
//           child: Row(
//             children: [
//               // ✅ AB AISA KAR DEIN:
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ProfileScreen(),
//                     ),
//                   );
//                 },
//                 child: const CircleAvatar(
//                   radius: 18,
//                   backgroundColor: Colors.blue,
//                   child: Icon(Icons.person, color: Colors.white),
//                 ),
//               ),
//               const SizedBox(width: 10),

//               // ✅ Fixed Name Logic
//               _isLoading
//                   ? const SizedBox(
//                       height: 15,
//                       width: 15,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.blue,
//                       ),
//                     )
//                   : Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Hello, ${UserProvider.userName ?? "User"}',
//                           style: const TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Text(
//                           formattedDate,
//                           style:
//                               const TextStyle(fontSize: 12, color: Colors.grey),
//                         ),
//                       ],
//                     ),
//             ],
//           ),
//         ),
//         actions: const [
//           Padding(
//             padding: EdgeInsets.only(right: 16),
//             child: Icon(Icons.notifications_none, color: Colors.black),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // AI POWERED CARD
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Align(
//                     alignment: Alignment.topRight,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 4),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         'AI POWERED',
//                         style: TextStyle(color: Colors.white, fontSize: 10),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Icon(Icons.camera_alt, color: Colors.white, size: 40),
//                   const SizedBox(height: 15),
//                   const Text(
//                     'Start New Test',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     'Scan your eyelid for instant anemia detection using our medical AI.',
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 20),
//                   SizedBox(
//                     width: double.infinity,
//                     height: 45,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const HowToCaptureScreen(),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.blue,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                       ),
//                       child: const Text(
//                         'Scan Now',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             const Text(
//               'Medical Suite',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 15),

//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               crossAxisSpacing: 12,
//               mainAxisSpacing: 12,
//               children: [
//                 FeatureCard(
//                   icon: Icons.description,
//                   title: 'Previous Reports',
//                   color: Colors.blue,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const PreviousReportsScreen()),
//                     );
//                   },
//                 ),
//                 FeatureCard(
//                   icon: Icons.apple,
//                   title: 'Diet Suggestions',
//                   color: Colors.green,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const DietSuggestionsScreen()),
//                     );
//                   },
//                 ),
//                 FeatureCard(
//                   icon: Icons.alarm,
//                   title: 'Reminders',
//                   color: Colors.teal,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const RemindersScreen()),
//                     );
//                   },
//                 ),
//                 FeatureCard(
//                   icon: Icons.location_on,
//                   title: 'Find Clinics',
//                   color: Colors.orange,
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const FindClinicsScreen()),
//                     );
//                   },
//                 ),
//               ],
//             ),

//             const SizedBox(height: 25),

//           // ==================== HEALTH TRENDS SECTION ====================

// // 1. Extract completed reports from UserProvider
// final reports = UserProvider.userReports;
// final bool hasReports = reports.isNotEmpty;
// final bool hasMultipleReports = reports.length > 1;

// // 2. Safely parse Latest & Previous Hb Values
// double latestLevel = 0.0;
// double previousLevel = 0.0;

// if (hasReports) {
//   latestLevel = double.tryParse(reports.last['hbValue']?.toString() ?? "0") ?? 0.0;
// }

// if (hasMultipleReports) {
//   previousLevel = double.tryParse(reports[reports.length - 2]['hbValue']?.toString() ?? "0") ?? 0.0;
// }

// // 3. Difference calculation
// double difference = latestLevel - previousLevel;
// bool isImproved = difference >= 0;

// return Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     // Header Row with Title & Details Button
//     Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Text(
//           'Health Trends',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const PreviousReportsScreen(),
//               ),
//             );
//           },
//           child: const Text(
//             'Details',
//             style: TextStyle(
//               color: Colors.blue,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ],
//     ),
//     const SizedBox(height: 15),

//     // Conditional Rendering based on reports availability
//     !hasReports
//         ? _buildEmptyTrendCard() // Empty state for new users
//         : Container(             // Dynamic trend card for active users
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.08),
//                   blurRadius: 15,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Top Stats Row
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Hemoglobin Level',
//                           style: TextStyle(fontSize: 13, color: Colors.grey),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Text(
//                               latestLevel.toStringAsFixed(1),
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const Text(
//                               ' g/dL',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(width: 8),

//                             // Dynamic Trend Badge (Shows only if >= 2 tests exist)
//                             if (hasMultipleReports)
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 3),
//                                 decoration: BoxDecoration(
//                                   color: isImproved
//                                       ? Colors.green.shade50
//                                       : Colors.red.shade50,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(
//                                       isImproved
//                                           ? Icons.arrow_upward
//                                           : Icons.arrow_downward,
//                                       size: 12,
//                                       color: isImproved
//                                           ? Colors.green
//                                           : Colors.red,
//                                     ),
//                                     const SizedBox(width: 2),
//                                     Text(
//                                       '${isImproved ? '+' : ''}${difference.toStringAsFixed(1)}',
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         color: isImproved
//                                             ? Colors.green
//                                             : Colors.red,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 10, vertical: 5),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: const Text(
//                         'Latest Scan',
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: Colors.blue,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // Dynamic Sparkline Graph
//                 SizedBox(
//                   height: 80,
//                   child: LineChart(
//                     LineChartData(
//                       gridData: const FlGridData(show: false),
//                       titlesData: const FlTitlesData(show: false),
//                       borderData: FlBorderData(show: false),
//                       lineTouchData: const LineTouchData(enabled: false),
//                       lineBarsData: [
//                         LineChartBarData(
//                           // 🔄 Mapping userReports to FlSpot dynamically
//                           spots: reports.asMap().entries.map((entry) {
//                             int index = entry.key;
//                             var report = entry.value;
//                             double val = double.tryParse(
//                                     report['hbValue']?.toString() ?? "0") ??
//                                 0.0;
//                             return FlSpot(index.toDouble(), val);
//                           }).toList(),
//                           isCurved: true,
//                           color: Colors.blue,
//                           barWidth: 3,
//                           isStrokeCapRound: true,
//                           dotData: FlDotData(
//                             show: reports.length == 1, // Single dot for first test
//                           ),
//                           belowBarData: BarAreaData(
//                             show: true,
//                             gradient: LinearGradient(
//                               colors: [
//                                 Colors.blue.withOpacity(0.25),
//                                 Colors.blue.withOpacity(0.0),
//                               ],
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 Text(
//                   hasMultipleReports
//                       ? 'Based on your last ${reports.length} scans.'
//                       : 'First test recorded. Perform another scan to view trends.',
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//       ),
//   ],
// );
//           ],
//         ),
//       ),
//     );
//   }
// }

// // FeatureCard class same rahegi...
// class FeatureCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final Color color;
//   final VoidCallback onTap;

//   const FeatureCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.color,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               backgroundColor: color.withOpacity(0.1),
//               child: Icon(icon, color: color),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
