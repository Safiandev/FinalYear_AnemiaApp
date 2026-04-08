// // import 'package:flutter/material.dart';
// // // 👇 In imports ko apne project structure ke mutabiq verify kar lein
// // import 'package:hemoglobe_ai/screens/tests/symptom_questionnaire_screen.dart';
// // import 'package:hemoglobe_ai/screens/find_clinics/find_clinics_screen.dart';
// // import 'package:hemoglobe_ai/diet_suggestions_screen.dart';

// // class ResultScreen extends StatelessWidget {
// //   const ResultScreen({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     const double hbLevel = 11.5;
// //     const String status = "Mild Anemia";
// //     const Color statusColor = Colors.orange;

// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FE),
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         centerTitle: true,
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back_ios_new,
// //               color: Colors.black, size: 20),
// //           onPressed: () => Navigator.pop(context),
// //         ),
// //         title: const Text(
// //           "Test Results",
// //           style: TextStyle(
// //               color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
// //         ),
// //         actions: [
// //           IconButton(
// //             onPressed: () {},
// //             icon: const Icon(Icons.share_outlined, color: Colors.black),
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         physics: const BouncingScrollPhysics(),
// //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // --- MAIN SCORE CARD ---
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.all(25),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(30),
// //                 boxShadow: [
// //                   BoxShadow(
// //                       color: Colors.blue.withOpacity(0.05),
// //                       blurRadius: 20,
// //                       offset: const Offset(0, 10)),
// //                 ],
// //               ),
// //               child: Column(
// //                 children: [
// //                   const Text("HEMOGLOBIN CONCENTRATION",
// //                       style: TextStyle(
// //                           color: Colors.grey,
// //                           fontWeight: FontWeight.bold,
// //                           letterSpacing: 1.2,
// //                           fontSize: 11)),
// //                   const SizedBox(height: 20),
// //                   Stack(
// //                     alignment: Alignment.center,
// //                     children: [
// //                       SizedBox(
// //                         height: 150,
// //                         width: 150,
// //                         child: CircularProgressIndicator(
// //                           value: hbLevel / 18,
// //                           strokeWidth: 12,
// //                           color: statusColor,
// //                           backgroundColor: Colors.grey.shade100,
// //                           strokeCap: StrokeCap.round,
// //                         ),
// //                       ),
// //                       Column(
// //                         children: [
// //                           Text("$hbLevel",
// //                               style: const TextStyle(
// //                                   fontSize: 42, fontWeight: FontWeight.bold)),
// //                           const Text("g/dL",
// //                               style:
// //                                   TextStyle(color: Colors.grey, fontSize: 14)),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Container(
// //                     padding:
// //                         const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
// //                     decoration: BoxDecoration(
// //                         color: statusColor.withOpacity(0.12),
// //                         borderRadius: BorderRadius.circular(30)),
// //                     child: Text(status.toUpperCase(),
// //                         style: const TextStyle(
// //                             color: statusColor,
// //                             fontWeight: FontWeight.w900,
// //                             fontSize: 13)),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 25),

// //             // --- RANGE COMPARISON SECTION (ADDED BACK) ---
// //             const Text("Range Comparison",
// //                 style: TextStyle(
// //                     fontSize: 17,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF1A1C1E))),
// //             const SizedBox(height: 12),
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: Colors.white,
// //                 borderRadius: BorderRadius.circular(24),
// //                 border: Border.all(color: Colors.grey.shade100),
// //               ),
// //               child: Column(
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       _buildRangeLabel("Low", "7-11", Colors.red),
// //                       _buildRangeLabel("Normal", "13-17", Colors.green),
// //                       _buildRangeLabel("High", "18+", Colors.blue),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 15),
// //                   ClipRRect(
// //                     borderRadius: BorderRadius.circular(10),
// //                     child: LinearProgressIndicator(
// //                       value: hbLevel / 18,
// //                       minHeight: 10,
// //                       color: statusColor,
// //                       backgroundColor: Colors.grey.shade100,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 10),
// //                   const Align(
// //                     alignment: Alignment.centerRight,
// //                     child: Text("Reference: WHO Standards",
// //                         style: TextStyle(
// //                             color: Colors.grey,
// //                             fontSize: 10,
// //                             fontStyle: FontStyle.italic)),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 25),

// //             const Text("Recommended Actions",
// //                 style: TextStyle(
// //                     fontSize: 17,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF1A1C1E))),
// //             const SizedBox(height: 12),

// //             _buildActionCard(
// //               icon: Icons.local_hospital_rounded,
// //               title: "Consult a Doctor",
// //               subtitle: "Connect with hematology experts nearby",
// //               color: Colors.blue.shade700,
// //               onTap: () {
// //                 Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                         builder: (context) => const FindClinicsScreen()));
// //               },
// //             ),

// //             const SizedBox(height: 12),

// //             _buildActionCard(
// //               icon: Icons.fastfood_rounded,
// //               title: "Iron-Rich Diet Plan",
// //               subtitle: "Explore foods that boost hemoglobin",
// //               color: Colors.green.shade600,
// //               onTap: () {
// //                 Navigator.push(
// //                   context,
// //                   MaterialPageRoute(
// //                     builder: (context) => const DietSuggestionsScreen(
// //                       hbLevel: 9.5, // Aapka dynamic variable yahan aayega
// //                       userStatus:
// //                           'Low', // 'Low', 'Normal' ya 'High' logic ke mutabiq
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),

// //             const SizedBox(height: 25),

// //             // --- SYMPTOMS TEST ---
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                     colors: [Colors.blue.shade800, Colors.blue.shade500]),
// //                 borderRadius: BorderRadius.circular(24),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text("Need a more precise result?",
// //                       style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 15)),
// //                   const SizedBox(height: 8),
// //                   const Text(
// //                       "Combine your scan with a clinical symptoms questionnaire.",
// //                       style: TextStyle(color: Colors.white70, fontSize: 12)),
// //                   const SizedBox(height: 15),
// //                   ElevatedButton(
// //                     onPressed: () {
// //                       Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                               builder: (context) =>
// //                                   const SymptomQuestionnaireScreen()));
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.white,
// //                       foregroundColor: Colors.blue.shade800,
// //                       minimumSize: const Size(double.infinity, 48),
// //                       shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12)),
// //                     ),
// //                     child: const Text("Start Detailed Test",
// //                         style: TextStyle(fontWeight: FontWeight.bold)),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 30),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // --- HELPER WIDGETS ---
// //   Widget _buildRangeLabel(String title, String range, Color color) {
// //     return Column(
// //       children: [
// //         Text(title,
// //             style: TextStyle(
// //                 color: color, fontWeight: FontWeight.bold, fontSize: 12)),
// //         Text(range, style: const TextStyle(color: Colors.grey, fontSize: 11)),
// //       ],
// //     );
// //   }

// //   Widget _buildActionCard(
// //       {required IconData icon,
// //       required String title,
// //       required String subtitle,
// //       required Color color,
// //       required VoidCallback onTap}) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.all(16),
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           borderRadius: BorderRadius.circular(20),
// //           border: Border.all(color: Colors.grey.shade100),
// //         ),
// //         child: Row(
// //           children: [
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                   color: color.withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(15)),
// //               child: Icon(icon, color: color, size: 26),
// //             ),
// //             const SizedBox(width: 15),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(title,
// //                       style: const TextStyle(
// //                           fontWeight: FontWeight.bold, fontSize: 15)),
// //                   Text(subtitle,
// //                       style:
// //                           TextStyle(color: Colors.grey.shade600, fontSize: 12)),
// //                 ],
// //               ),
// //             ),
// //             const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // 👈 Added Firestore
// import 'package:hemoglobe_ai/user_provider.dart'; // 👈 Added Provider
// import 'package:hemoglobe_ai/screens/tests/symptom_questionnaire_screen.dart';
// import 'package:hemoglobe_ai/screens/find_clinics/find_clinics_screen.dart';
// import 'package:hemoglobe_ai/diet_suggestions_screen.dart';

// class ResultScreen extends StatefulWidget {
//   const ResultScreen({super.key});

//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen> {
//   // Constants for display
//   final double hbLevel = 11.5;
//   final String status = "Mild Anemia";
//   final Color statusColor = Colors.orange;

//   @override
//   void initState() {
//     super.initState();
//     // ✅ Phase 1: Quick Save triggered as soon as screen loads
//     _quickSaveHbResult();
//   }

//   // 1. Aik variable class level par ya yahan define kar len
//   String? currentReportId;

//   // Logic to save the initial result to Firestore (Updated)
//   Future<void> _quickSaveHbResult() async {
//     try {
//       // ✅ Nayi unique ID pehle hi generate kar li
//       currentReportId =
//           FirebaseFirestore.instance.collection('reports').doc().id;

//       // ✅ .add ki jagah .doc(currentReportId).set use kiya
//       await FirebaseFirestore.instance
//           .collection('reports')
//           .doc(currentReportId)
//           .set({
//         'reportId': currentReportId, // ID save karna zaroori hai update ke liye
//         'userId': UserProvider.userId,
//         'hbValue': hbLevel,
//         'statusLabel': status,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isCompleted': false, // Spelling match kar li humne 'isCompleted'
//         'symptoms': [],
//       });

//       print("✅ Phase 1: Quick Report Saved with ID: $currentReportId");
//     } catch (e) {
//       print("❌ Error in Phase 1 Quick Save: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FE),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new,
//               color: Colors.black, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Test Results",
//           style: TextStyle(
//               color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {},
//             icon: const Icon(Icons.share_outlined, color: Colors.black),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- MAIN SCORE CARD ---
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(25),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.blue.withOpacity(0.05),
//                       blurRadius: 20,
//                       offset: const Offset(0, 10)),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text("HEMOGLOBIN CONCENTRATION",
//                       style: TextStyle(
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                           letterSpacing: 1.2,
//                           fontSize: 11)),
//                   const SizedBox(height: 20),
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       SizedBox(
//                         height: 150,
//                         width: 150,
//                         child: CircularProgressIndicator(
//                           value: hbLevel / 18,
//                           strokeWidth: 12,
//                           color: statusColor,
//                           backgroundColor: Colors.grey.shade100,
//                           strokeCap: StrokeCap.round,
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           Text("$hbLevel",
//                               style: const TextStyle(
//                                   fontSize: 42, fontWeight: FontWeight.bold)),
//                           const Text("g/dL",
//                               style:
//                                   TextStyle(color: Colors.grey, fontSize: 14)),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                     decoration: BoxDecoration(
//                         color: statusColor.withOpacity(0.12),
//                         borderRadius: BorderRadius.circular(30)),
//                     child: Text(status.toUpperCase(),
//                         style: TextStyle(
//                             color: statusColor,
//                             fontWeight: FontWeight.w900,
//                             fontSize: 13)),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             // --- RANGE COMPARISON SECTION ---
//             const Text("Range Comparison",
//                 style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1C1E))),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(color: Colors.grey.shade100),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       _buildRangeLabel("Low", "7-11", Colors.red),
//                       _buildRangeLabel("Normal", "13-17", Colors.green),
//                       _buildRangeLabel("High", "18+", Colors.blue),
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: LinearProgressIndicator(
//                       value: hbLevel / 18,
//                       minHeight: 10,
//                       color: statusColor,
//                       backgroundColor: Colors.grey.shade100,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Align(
//                     alignment: Alignment.centerRight,
//                     child: Text("Reference: WHO Standards",
//                         style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 10,
//                             fontStyle: FontStyle.italic)),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             const Text("Recommended Actions",
//                 style: TextStyle(
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1A1C1E))),
//             const SizedBox(height: 12),

//             _buildActionCard(
//               icon: Icons.local_hospital_rounded,
//               title: "Consult a Doctor",
//               subtitle: "Connect with hematology experts nearby",
//               color: Colors.blue.shade700,
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const FindClinicsScreen()));
//               },
//             ),

//             const SizedBox(height: 12),

//             _buildActionCard(
//               icon: Icons.fastfood_rounded,
//               title: "Iron-Rich Diet Plan",
//               subtitle: "Explore foods that boost hemoglobin",
//               color: Colors.green.shade600,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => DietSuggestionsScreen(
//                       hbLevel: hbLevel,
//                       userStatus: 'Low',
//                     ),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 25),

//             // --- SYMPTOMS TEST ---
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                     colors: [Colors.blue.shade800, Colors.blue.shade500]),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text("Need a more precise result?",
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15)),
//                   const SizedBox(height: 8),
//                   const Text(
//                       "Combine your scan with a clinical symptoms questionnaire.",
//                       style: TextStyle(color: Colors.white70, fontSize: 12)),
//                   const SizedBox(height: 15),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => SymptomQuestionnaireScreen(
//                                     reportId: currentReportId,
//                                     initialHb: hbLevel,
//                                   )));
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.blue.shade800,
//                       minimumSize: const Size(double.infinity, 48),
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: const Text("Start Detailed Test",
//                         style: TextStyle(fontWeight: FontWeight.bold)),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRangeLabel(String title, String range, Color color) {
//     return Column(
//       children: [
//         Text(title,
//             style: TextStyle(
//                 color: color, fontWeight: FontWeight.bold, fontSize: 12)),
//         Text(range, style: const TextStyle(color: Colors.grey, fontSize: 11)),
//       ],
//     );
//   }

//   Widget _buildActionCard(
//       {required IconData icon,
//       required String title,
//       required String subtitle,
//       required Color color,
//       required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: Colors.grey.shade100),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15)),
//               child: Icon(icon, color: color, size: 26),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 15)),
//                   Text(subtitle,
//                       style:
//                           TextStyle(color: Colors.grey.shade600, fontSize: 12)),
//                 ],
//               ),
//             ),
//             const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hemoglobe_ai/user_provider.dart';
import 'package:hemoglobe_ai/screens/tests/symptom_questionnaire_screen.dart';
import 'package:hemoglobe_ai/screens/find_clinics/find_clinics_screen.dart';
import 'package:hemoglobe_ai/diet_suggestions_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Display constants
  final double hbLevel = 11.5;
  final String status = "Mild Anemia";
  final Color statusColor = Colors.orange;

  // ✅ Variable to hold the report ID across screens
  String? currentReportId;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // ✅ Phase 1: Screen khulte hi report save hogi, lekin sirf ek baar
    _quickSaveHbResult();
  }

  Future<void> _quickSaveHbResult() async {
    // 🛑 GUARD: Agar ID pehle se hai ya save ho raha hai, toh bilkul naya mat banao
    if (currentReportId != null || isSaving) return;

    setState(() => isSaving = true);

    try {
      // ✅ Step 1: Nayi unique ID generate karo
      final reportDoc = FirebaseFirestore.instance.collection('reports').doc();
      final newId = reportDoc.id;

      // ✅ Step 2: Use .set() with generated ID
      await reportDoc.set({
        'reportId': newId,
        'userId': UserProvider.userId,
        'hbValue': hbLevel,
        'statusLabel': status,
        'timestamp': FieldValue.serverTimestamp(),
        'isCompleted': false, // Initial state: incomplete
        'symptoms': [],
      });

      if (mounted) {
        setState(() {
          currentReportId = newId;
          isSaving = false;
        });
      }

      debugPrint("✅ Phase 1: Report Reserved & Saved with ID: $newId");
    } catch (e) {
      if (mounted) setState(() => isSaving = false);
      debugPrint("❌ Error in Phase 1 Quick Save: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Test Results",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MAIN SCORE CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  const Text("HEMOGLOBIN CONCENTRATION",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 11)),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: hbLevel / 18,
                          strokeWidth: 12,
                          color: statusColor,
                          backgroundColor: Colors.grey.shade100,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        children: [
                          Text("$hbLevel",
                              style: const TextStyle(
                                  fontSize: 42, fontWeight: FontWeight.bold)),
                          const Text("g/dL",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(30)),
                    child: Text(status.toUpperCase(),
                        style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- RANGE COMPARISON ---
            const Text("Range Comparison",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRangeLabel("Low", "7-11", Colors.red),
                      _buildRangeLabel("Normal", "13-17", Colors.green),
                      _buildRangeLabel("High", "18+", Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: hbLevel / 18,
                      minHeight: 10,
                      color: statusColor,
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text("Reference: WHO Standards",
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text("Recommended Actions",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E))),
            const SizedBox(height: 12),

            _buildActionCard(
              icon: Icons.local_hospital_rounded,
              title: "Consult a Doctor",
              subtitle: "Connect with hematology experts nearby",
              color: Colors.blue.shade700,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FindClinicsScreen()));
              },
            ),

            const SizedBox(height: 12),

            _buildActionCard(
              icon: Icons.fastfood_rounded,
              title: "Iron-Rich Diet Plan",
              subtitle: "Explore foods that boost hemoglobin",
              color: Colors.green.shade600,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DietSuggestionsScreen(
                            hbLevel: hbLevel, userStatus: 'Low')));
              },
            ),

            const SizedBox(height: 25),

            // --- SYMPTOMS TEST ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade500]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Need a more precise result?",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 8),
                  const Text(
                      "Combine your scan with a clinical symptoms questionnaire.",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // ✅ CRITICAL FIX: Sirf tab navigate karo jab reportId
                      // available ho. Agar saving chal rahi hai toh wait karo.
                      if (currentReportId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SymptomQuestionnaireScreen(
                              reportId: currentReportId!,
                              initialHb: hbLevel,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(isSaving
                                ? "Saving scan result... please wait."
                                : "Connection error. Retrying...")));
                        if (!isSaving) _quickSaveHbResult();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Start Detailed Test",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRangeLabel(String title, String range, Color color) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(range, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildActionCard(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15)),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
