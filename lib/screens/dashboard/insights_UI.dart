import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Aapke file paths ke hisaab se imports:
import 'package:hemoglobe_ai/main_navigation_screen.dart';
import 'package:hemoglobe_ai/screens/settings/reminders_screen.dart';
// AGAR reminders_screen kisi folder me hai (e.g. screens/reminders_screen.dart),
// to correct path yahan update kar lein.

class InsightsUI extends StatefulWidget {
  const InsightsUI({super.key});

  @override
  State<InsightsUI> createState() => _InsightsUIState();
}

class _InsightsUIState extends State<InsightsUI> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  String savedScanDate = "Not Set";

  @override
  void initState() {
    super.initState();
    _loadSavedScanDate();
  }

  // SharedPreferences se user ki set ki hui date read karna
  Future<void> _loadSavedScanDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedScanDate = prefs.getString('hemoglobinDate') ?? "Not Set";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: userId == null
          ? const Center(child: Text("User not logged in."))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('userId', isEqualTo: userId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(context);
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                // --- DATA CALCULATIONS ---
                Map<String, dynamic> latestData =
                    docs.first.data() as Map<String, dynamic>;
                double latestHb =
                    (latestData['hbValue'] as num?)?.toDouble() ?? 0.0;
                String statusLabel =
                    latestData['statusLabel'] ?? "Unknown Status";
                List<dynamic> symptoms = latestData['symptoms'] ?? [];

                // Average Hemoglobin
                double sumHb = 0;
                for (var doc in docs) {
                  sumHb +=
                      ((doc.data() as Map<String, dynamic>)['hbValue'] as num?)
                              ?.toDouble() ??
                          0.0;
                }
                double avgHb = docs.isNotEmpty ? sumHb / docs.length : 0.0;

                // Scan Consistency
                DateTime now = DateTime.now();
                int scansThisMonth = docs.where((doc) {
                  Timestamp? ts =
                      (doc.data() as Map<String, dynamic>)['timestamp'];
                  if (ts == null) return false;
                  DateTime d = ts.toDate();
                  return d.month == now.month && d.year == now.year;
                }).length;

                // Score Calculation
                int healthScore = _calculateScore(
                    latestHb: latestHb,
                    docs: docs,
                    scansThisMonth: scansThisMonth,
                    symptomCount: symptoms.length);

                Color scoreBgColor = healthScore >= 80
                    ? const Color(0xFF2E7D32)
                    : healthScore >= 60
                        ? const Color(0xFFE65100)
                        : const Color(0xFFC62828);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// --- HEALTH SCORE HEADER CARD ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: scoreBgColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: scoreBgColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Overall Health Score",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$healthScore / 100",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              healthScore >= 80
                                  ? "Optimal Health Status"
                                  : healthScore >= 60
                                      ? "Moderate Health Alert — Action Suggested"
                                      : "Critical Health Warning — Medical Review Advised",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// --- DYNAMIC REMINDER CARD ---
                      _buildReminderCard(context),

                      const SizedBox(height: 25),

                      /// --- HEALTH ANALYSIS SECTION ---
                      const Text(
                        "Health Analysis",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      insightCard(
                        icon: healthScore >= 80
                            ? Icons.check_circle
                            : healthScore >= 60
                                ? Icons.warning_amber
                                : Icons.dangerous,
                        color: scoreBgColor,
                        title: "Risk Level",
                        subtitle: "$statusLabel detected in recent scan.",
                      ),
                      const SizedBox(height: 12),

                      insightCard(
                        icon: Icons.monitor_heart,
                        color: Colors.red,
                        title: "Average Hemoglobin",
                        subtitle:
                            "Your overall average Hb level is ${avgHb.toStringAsFixed(1)} g/dL.",
                      ),
                      const SizedBox(height: 12),

                      insightCard(
                        icon: Icons.repeat,
                        color: Colors.green,
                        title: "Scan Consistency",
                        subtitle:
                            "You completed $scansThisMonth scan(s) this month.",
                      ),
                      const SizedBox(height: 12),

                      insightCard(
                        icon: Icons.bar_chart,
                        color: Colors.purple,
                        title: "Healthy Target Range",
                        subtitle:
                            "Recommended hemoglobin range is 12.0 – 16.5 g/dL.",
                      ),

                      const SizedBox(height: 25),

                      /// --- PERSONALIZED RECOMMENDATIONS ---
                      const Text(
                        "Recommendations & Tips",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      ..._buildRecommendations(
                          healthScore, statusLabel, symptoms),

                      /// --- EMERGENCY CTA FOR LOW SCORE ---
                      if (healthScore < 60) ...[
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Consulting hematologist/doctor recommended!"),
                              ),
                            );
                          },
                          icon: const Icon(Icons.local_hospital,
                              color: Colors.white),
                          label: const Text(
                            "Consult Doctor / Find Nearby Lab",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  int _calculateScore({
    required double latestHb,
    required List<QueryDocumentSnapshot> docs,
    required int scansThisMonth,
    required int symptomCount,
  }) {
    int score = 0;
    if (latestHb >= 12.0) {
      score += 45;
    } else if (latestHb >= 10.0) {
      score += 30;
    } else if (latestHb >= 8.0) {
      score += 15;
    } else {
      score += 5;
    }

    if (docs.length >= 2) {
      double prevHb =
          ((docs[1].data() as Map<String, dynamic>)['hbValue'] as num?)
                  ?.toDouble() ??
              0.0;
      if (latestHb > prevHb) {
        score += 25;
      } else if (latestHb == prevHb) {
        score += 18;
      } else {
        score += 8;
      }
    } else {
      score += 20;
    }

    if (scansThisMonth >= 3) {
      score += 20;
    } else if (scansThisMonth >= 1) {
      score += 12;
    } else {
      score += 5;
    }

    if (symptomCount == 0) {
      score += 10;
    } else if (symptomCount <= 2) {
      score += 5;
    } else {
      score += 2;
    }

    return score.clamp(0, 100);
  }

  /// --- DYNAMIC REMINDER CARD WIDGET ---
  Widget _buildReminderCard(BuildContext context) {
    if (savedScanDate != "Not Set") {
      try {
        List<String> parts = savedScanDate.split('-');
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        DateTime nextDate = DateTime(year, month, day);
        DateTime now = DateTime.now();
        DateTime today = DateTime(now.year, now.month, now.day);

        int daysLeft = nextDate.difference(today).inDays;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.shade200),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Icon(Icons.calendar_month, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Next Scheduled Scan",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      daysLeft > 0
                          ? "Due in $daysLeft day(s) ($savedScanDate)"
                          : daysLeft == 0
                              ? "Scan is due today!"
                              : "Scan date passed ($savedScanDate)",
                      style: TextStyle(
                          color: Colors.indigo.shade800, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.indigo),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RemindersScreen(),
                    ),
                  );
                  _loadSavedScanDate();
                },
              )
            ],
          ),
        );
      } catch (e) {
        // Fallback in case date format mismatch
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm_add, color: Colors.amber, size: 30),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No Scan Reminder Set",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Set a schedule to monitor your Hb consistently.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RemindersScreen(),
                ),
              );
              _loadSavedScanDate();
            },
            child: const Text("Set Now"),
          )
        ],
      ),
    );
  }

  /// --- DYNAMIC RECOMMENDATIONS ENGINE ---
  List<Widget> _buildRecommendations(
      int score, String statusLabel, List<dynamic> symptoms) {
    List<Widget> tips = [];

    if (score >= 80) {
      tips.add(const _RecommendationTileWidget(
        icon: Icons.eco,
        color: Colors.green,
        title: "Maintain Iron Intake",
        desc:
            "Your levels are healthy. Keep eating iron-rich greens, beans, and lean meats.",
      ));
      tips.add(const _RecommendationTileWidget(
        icon: Icons.repeat,
        color: Colors.blue,
        title: "Regular Checkup",
        desc:
            "Perform a re-scan every 30 days to ensure your Hb levels remain stable.",
      ));
    } else if (score >= 60) {
      tips.add(const _RecommendationTileWidget(
        icon: Icons.restaurant,
        color: Colors.orange,
        title: "Boost Dietary Iron & Vitamin C",
        desc:
            "Pair iron-rich foods (spinach, lentils) with Vitamin C (oranges, lemons) for optimal absorption.",
      ));
      tips.add(const _RecommendationTileWidget(
        icon: Icons.free_breakfast,
        color: Colors.brown,
        title: "Avoid Tea/Coffee with Meals",
        desc:
            "Tannins in tea and coffee block iron absorption. Drink them at least 1 hour after meals.",
      ));
    } else {
      tips.add(const _RecommendationTileWidget(
        icon: Icons.medical_services,
        color: Colors.red,
        title: "Medical Diagnostic Test",
        desc:
            "Your score indicates significant anemia risk. Schedule a lab CBC test as soon as possible.",
      ));
      tips.add(const _RecommendationTileWidget(
        icon: Icons.no_food,
        color: Colors.deepOrange,
        title: "Nutritional Support",
        desc:
            "Consult a clinical dietitian or doctor for iron supplements and a targeted recovery plan.",
      ));
    }

    return tips;
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No Scan Data Found",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Perform your first eyelid scan to view detailed health insights.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationTileWidget extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _RecommendationTileWidget({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
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
        BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8),
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

// import 'package:flutter/material.dart';
// import 'package:hemoglobe_ai/main_navigation_screen.dart';

// class InsightsUI extends StatelessWidget {
//   const InsightsUI({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,

//         /// Back button -> Main Navigation (Home tab)
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => const MainNavigationScreen(),
//               ),
//             );
//           },
//         ),

//         title: const Text(
//           "Health Insights",
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Health Score
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Column(
//                 children: [
//                   Text(
//                     "Health Score",
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                   SizedBox(height: 10),
//                   Text(
//                     "72 / 100",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 6),
//                   Text(
//                     "Based on Hb level, scan frequency and improvement",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             const Text(
//               "Health Analysis",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),

//             const SizedBox(height: 15),

//             insightCard(
//               icon: Icons.warning,
//               color: Colors.orange,
//               title: "Risk Level",
//               subtitle: "Mild Risk detected from your recent scan.",
//             ),

//             const SizedBox(height: 12),

//             insightCard(
//               icon: Icons.monitor_heart,
//               color: Colors.red,
//               title: "Average Hemoglobin",
//               subtitle: "Your average Hb level is 12.4 g/dL.",
//             ),

//             const SizedBox(height: 12),

//             insightCard(
//               icon: Icons.repeat,
//               color: Colors.green,
//               title: "Scan Consistency",
//               subtitle: "You completed 5 scans this month.",
//             ),

//             const SizedBox(height: 12),

//             insightCard(
//               icon: Icons.bar_chart,
//               color: Colors.purple,
//               title: "Healthy Range",
//               subtitle: "Recommended hemoglobin range is 13 – 17 g/dL.",
//             ),

//             const SizedBox(height: 25),

//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.lightbulb, color: Colors.blue),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       "Tip: Eating iron-rich foods like spinach, beans and red meat can help improve hemoglobin levels.",
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// Widget insightCard({
//   required IconData icon,
//   required Color color,
//   required String title,
//   required String subtitle,
// }) {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       boxShadow: [
//         BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
//       ],
//     ),
//     child: Row(
//       children: [
//         CircleAvatar(
//           backgroundColor: color.withOpacity(0.1),
//           child: Icon(icon, color: color),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               Text(
//                 subtitle,
//                 style: const TextStyle(color: Colors.grey, fontSize: 13),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
