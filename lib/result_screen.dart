import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hemoglobe_ai/user_provider.dart';
import 'package:hemoglobe_ai/screens/tests/symptom_questionnaire_screen.dart';
import 'package:hemoglobe_ai/screens/find_clinics/find_clinics_screen.dart';
import 'package:hemoglobe_ai/diet_suggestions_screen.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic>? predictionData;
  final File? imageFile;

  const ResultScreen({
    super.key,
    this.predictionData,
    this.imageFile,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late String status; // "Anemic" or "Non-Anemic"
  late double confidence; // 0-100
  late Color statusColor;

  String? currentReportId;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    // ✅ Model ke real classification output se data lena
    status = widget.predictionData?['result'] ?? 'Unknown';
    confidence = double.tryParse(
            widget.predictionData?['confidence']?.toString() ?? '0') ??
        0.0;

    statusColor = _getStatusColor(status);
    _quickSaveResult();
  }

  Color _getStatusColor(String currentStatus) {
    if (currentStatus == 'Non-Anemic') {
      return Colors.green;
    } else if (currentStatus == 'Anemic') {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  Future<void> _quickSaveResult() async {
    if (currentReportId != null || isSaving) return;

    final currentUserId = UserProvider.userId;
    if (currentUserId == null || currentUserId.isEmpty) {
      debugPrint("❌ Phase 1 Error: User Provider returned null/empty User ID.");
      return;
    }

    setState(() => isSaving = true);

    try {
      final reportDoc = FirebaseFirestore.instance.collection('reports').doc();
      final newId = reportDoc.id;

      await reportDoc.set({
        'reportId': newId,
        'userId': currentUserId,
        'statusLabel': status, // "Anemic" / "Non-Anemic"
        'confidence': confidence, // 0-100
        'timestamp': FieldValue.serverTimestamp(),
        'isCompleted': false,
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
                    color: Colors.blue.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "AI SCAN RESULT",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: (confidence / 100).clamp(0.0, 1.0),
                          strokeWidth: 12,
                          color: statusColor,
                          backgroundColor: Colors.grey.shade100,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "${confidence.toStringAsFixed(0)}%",
                            style: const TextStyle(
                                fontSize: 38, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Confidence",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- WHAT THIS MEANS ---
            const Text(
              "What This Means",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    status == 'Anemic'
                        ? Icons.warning_rounded
                        : Icons.check_circle_rounded,
                    color: statusColor,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      status == 'Anemic'
                          ? "Our AI model detected visual indicators consistent with anemia in your conjunctival scan with ${confidence.toStringAsFixed(0)}% confidence."
                          : "Our AI model did not detect visual indicators of anemia in your conjunctival scan (${confidence.toStringAsFixed(0)}% confidence).",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Recommended Actions",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
              ),
            ),
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
                      builder: (context) => const FindClinicsScreen()),
                );
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
                      userStatus: status,
                      confidence: confidence,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // --- SYMPTOMS TEST ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade500],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Need a more precise result?",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Combine your scan with a clinical symptoms questionnaire.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      if (currentReportId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SymptomQuestionnaireScreen(
                              reportId: currentReportId!,
                              initialStatus: status,
                              initialConfidence: confidence,
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isSaving
                                  ? "Saving scan result... please wait."
                                  : "Connection error. Retrying...",
                            ),
                          ),
                        );
                        if (!isSaving) _quickSaveResult();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue.shade800,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Start Detailed Test",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
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



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hemoglobe_ai/user_provider.dart';
// import 'package:hemoglobe_ai/screens/tests/symptom_questionnaire_screen.dart';
// import 'package:hemoglobe_ai/screens/find_clinics/find_clinics_screen.dart';
// import 'package:hemoglobe_ai/diet_suggestions_screen.dart';

// class ResultScreen extends StatefulWidget {
//   final Map<String, dynamic>? predictionData;
//   final File? imageFile;
//   final double hbLevel;
//   final String status;

//   const ResultScreen({
//     super.key,
//     this.predictionData,
//     this.imageFile,
//     this.hbLevel = 11.5,
//     this.status = "Mild Anemia",
//   });

//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }

// class _ResultScreenState extends State<ResultScreen> {
//   late double hbLevel;
//   late String status;
//   late Color statusColor;

//   String? currentReportId;
//   bool isSaving = false;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.predictionData != null) {
//       hbLevel = (widget.predictionData!['hbLevel'] ?? widget.hbLevel).toDouble();
//       status = widget.predictionData!['result'] ?? widget.status;
//     } else {
//       hbLevel = widget.hbLevel;
//       status = widget.status;
//     }

//     statusColor = _getStatusColor(status);
//     _quickSaveHbResult();
//   }

//   Color _getStatusColor(String currentStatus) {
//     final lower = currentStatus.toLowerCase();
//     if (lower.contains('normal')) {
//       return Colors.green;
//     } else if (lower.contains('severe')) {
//       return Colors.red;
//     } else {
//       return Colors.orange;
//     }
//   }

//   Future<void> _quickSaveHbResult() async {
//     if (currentReportId != null || isSaving) return;

//     final currentUserId = UserProvider.userId;
//     if (currentUserId == null || currentUserId.isEmpty) {
//       debugPrint("❌ Phase 1 Error: User Provider returned null/empty User ID.");
//       return;
//     }

//     setState(() => isSaving = true);

//     try {
//       final reportDoc = FirebaseFirestore.instance.collection('reports').doc();
//       final newId = reportDoc.id;

//       await reportDoc.set({
//         'reportId': newId,
//         'userId': currentUserId,
//         'hbValue': hbLevel,
//         'statusLabel': status,
//         'timestamp': FieldValue.serverTimestamp(),
//         'isCompleted': false,
//         'symptoms': [],
//       });

//       if (mounted) {
//         setState(() {
//           currentReportId = newId;
//           isSaving = false;
//         });
//       }

//       debugPrint("✅ Phase 1: Report Reserved & Saved with ID: $newId");
//     } catch (e) {
//       if (mounted) setState(() => isSaving = false);
//       debugPrint("❌ Error in Phase 1 Quick Save: $e");
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
//           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           "Test Results",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
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
//                     color: Colors.blue.withValues(alpha: 0.05),
//                     blurRadius: 20,
//                     offset: const Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     "HEMOGLOBIN CONCENTRATION",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.2,
//                       fontSize: 11,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       SizedBox(
//                         height: 150,
//                         width: 150,
//                         child: CircularProgressIndicator(
//                           value: (hbLevel / 18).clamp(0.0, 1.0),
//                           strokeWidth: 12,
//                           color: statusColor,
//                           backgroundColor: Colors.grey.shade100,
//                           strokeCap: StrokeCap.round,
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             "$hbLevel",
//                             style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
//                           ),
//                           const Text(
//                             "g/dL",
//                             style: TextStyle(color: Colors.grey, fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: statusColor.withValues(alpha: 0.12),
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Text(
//                       status.toUpperCase(),
//                       style: TextStyle(
//                         color: statusColor,
//                         fontWeight: FontWeight.w900,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             // --- RANGE COMPARISON ---
//             const Text(
//               "Range Comparison",
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1A1C1E),
//               ),
//             ),
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
//                       value: (hbLevel / 18).clamp(0.0, 1.0),
//                       minHeight: 10,
//                       color: statusColor,
//                       backgroundColor: Colors.grey.shade100,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   const Align(
//                     alignment: Alignment.centerRight,
//                     child: Text(
//                       "Reference: WHO Standards",
//                       style: TextStyle(
//                         color: Colors.grey,
//                         fontSize: 10,
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             const Text(
//               "Recommended Actions",
//               style: TextStyle(
//                 fontSize: 17,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1A1C1E),
//               ),
//             ),
//             const SizedBox(height: 12),

//             _buildActionCard(
//               icon: Icons.local_hospital_rounded,
//               title: "Consult a Doctor",
//               subtitle: "Connect with hematology experts nearby",
//               color: Colors.blue.shade700,
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const FindClinicsScreen()),
//                 );
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
//                       userStatus: status,
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
//                   colors: [Colors.blue.shade800, Colors.blue.shade500],
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Need a more precise result?",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Combine your scan with a clinical symptoms questionnaire.",
//                     style: TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                   const SizedBox(height: 15),
//                   ElevatedButton(
//                     onPressed: () {
//                       if (currentReportId != null) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => SymptomQuestionnaireScreen(
//                               reportId: currentReportId!,
//                               initialHb: hbLevel,
//                             ),
//                           ),
//                         );
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               isSaving
//                                   ? "Saving scan result... please wait."
//                                   : "Connection error. Retrying...",
//                             ),
//                           ),
//                         );
//                         if (!isSaving) _quickSaveHbResult();
//                       }
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: Colors.blue.shade800,
//                       minimumSize: const Size(double.infinity, 48),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text(
//                       "Start Detailed Test",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
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
//         Text(
//           title,
//           style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
//         ),
//         Text(range, style: const TextStyle(color: Colors.grey, fontSize: 11)),
//       ],
//     );
//   }

//   Widget _buildActionCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
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
//                 color: color.withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Icon(icon, color: color, size: 26),
//             ),
//             const SizedBox(width: 15),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                   ),
//                   Text(
//                     subtitle,
//                     style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
//                   ),
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

