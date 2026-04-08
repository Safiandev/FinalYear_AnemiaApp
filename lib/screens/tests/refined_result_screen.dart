// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hemoglobe_ai/screens/reports/report_preview_screen.dart';

// class RefinedResultScreen extends StatefulWidget {
//   final double finalHb;
//   final List<String> userSymptoms;
//   final String reportId;

//   const RefinedResultScreen({
//     super.key,
//     required this.finalHb,
//     required this.userSymptoms,
//     required this.reportId,
//   });

//   @override
//   State<RefinedResultScreen> createState() => _RefinedResultScreenState();
// }

// class _RefinedResultScreenState extends State<RefinedResultScreen> {
//   bool _safetyUpdateDone = false;

//   @override
//   void initState() {
//     super.initState();
//     // ✅ SAFETY NET: Agar ai_refinement_loading_screen update karne mein
//     // fail ho gaya ho toh yahan last-resort update hogi.
//     // Naya document KABHI nahi banega — sirf existing update hoga.
//     _ensureReportIsComplete();
//   }

//   Future<void> _ensureReportIsComplete() async {
//     if (_safetyUpdateDone || widget.reportId.isEmpty) return;

//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('reports')
//           .doc(widget.reportId)
//           .get();

//       if (!doc.exists) {
//         debugPrint("⚠️ Safety Check: Document does not exist — skipping.");
//         return;
//       }

//       final alreadyComplete = doc.data()?['isCompleted'] == true;

//       if (alreadyComplete) {
//         // ✅ Loading screen ne pehle hi kar diya — kuch nahi karna
//         debugPrint("✅ Safety Check: Already complete. No action needed.");
//         _safetyUpdateDone = true;
//         return;
//       }

//       // ✅ Sirf .update() — koi naya doc nahi banega
//       await FirebaseFirestore.instance
//           .collection('reports')
//           .doc(widget.reportId)
//           .update({
//         'isCompleted': true,
//         'lastUpdated': FieldValue.serverTimestamp(),
//       });

//       _safetyUpdateDone = true;
//       debugPrint(
//           "✅ Safety Net Fired: Report marked complete — ${widget.reportId}");
//     } catch (e) {
//       debugPrint("❌ Safety Net Error: $e");
//     }
//   }

//   // ✅ Explicitly typed Map to prevent 'dynamic' object errors in UI
//   Map<String, dynamic> getStatus() {
//     if (widget.finalHb < 8.0) {
//       return {
//         'label': 'Severe Anemia',
//         'color': const Color(0xFFE53935),
//         'icon': Icons.warning_amber_rounded,
//         'bg': const Color(0xFFFFEBEE),
//       };
//     } else if (widget.finalHb < 12.0) {
//       return {
//         'label': 'Mild Anemia',
//         'color': const Color(0xFFFB8C00),
//         'icon': Icons.info_outline_rounded,
//         'bg': const Color(0xFFFFF3E0),
//       };
//     } else {
//       return {
//         'label': 'Normal Range',
//         'color': const Color(0xFF43A047),
//         'icon': Icons.check_circle_outline_rounded,
//         'bg': const Color(0xFFE8F5E9),
//       };
//     }
//   }

//   void _showAiDoctorConsultation(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
//         ),
//         padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//             top: 20,
//             left: 30,
//             right: 30),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//                 child: Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(10)))),
//             const SizedBox(height: 25),
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: Colors.blue.shade50,
//                   child: const Icon(Icons.psychology, color: Colors.blueAccent),
//                 ),
//                 const SizedBox(width: 15),
//                 const Text("AI Health Advisor",
//                     style:
//                         TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Your Hemoglobin is ${widget.finalHb} g/dL. Based on your symptoms: ${widget.userSymptoms.join(', ')}, I recommend focusing on iron-rich nutrition.",
//               style: TextStyle(
//                   color: Colors.grey.shade800, fontSize: 15, height: 1.6),
//             ),
//             const SizedBox(height: 25),
//             TextField(
//               decoration: InputDecoration(
//                 hintText: "Ask AI about diet...",
//                 prefixIcon: const Icon(Icons.chat_bubble_outline, size: 20),
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide.none),
//               ),
//             ),
//             const SizedBox(height: 15),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final status = getStatus();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FBFF),
//       appBar: AppBar(
//         title: const Text("Refined Result",
//             style: TextStyle(
//                 color: Color(0xFF2D3142), fontWeight: FontWeight.w800)),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded,
//               color: Colors.black, size: 18),
//           onPressed: () =>
//               Navigator.of(context).popUntil((route) => route.isFirst),
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             // --- MAIN SCORE CARD ---
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 45),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(40),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.blue.withOpacity(0.04),
//                       blurRadius: 30,
//                       offset: const Offset(0, 15))
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       SizedBox(
//                         height: 180,
//                         width: 180,
//                         child: CircularProgressIndicator(
//                           value: (widget.finalHb / 18).clamp(0.0, 1.0),
//                           strokeWidth: 15,
//                           backgroundColor: Colors.grey.shade100,
//                           color: status['color'] as Color,
//                           strokeCap: StrokeCap.round,
//                         ),
//                       ),
//                       Column(
//                         children: [
//                           Text("${widget.finalHb}",
//                               style: const TextStyle(
//                                   fontSize: 56,
//                                   fontWeight: FontWeight.w900,
//                                   color: Color(0xFF2D3142))),
//                           const Text("g/dL",
//                               style: TextStyle(
//                                   color: Colors.grey,
//                                   fontWeight: FontWeight.bold)),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 35),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 25, vertical: 12),
//                     decoration: BoxDecoration(
//                       color: status['bg'] as Color,
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(status['icon'] as IconData,
//                             color: status['color'] as Color, size: 20),
//                         const SizedBox(width: 10),
//                         Text(status['label'] as String,
//                             style: TextStyle(
//                                 color: status['color'] as Color,
//                                 fontWeight: FontWeight.w900,
//                                 fontSize: 17)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),

//             // --- INSIGHT TILES ---
//             _buildInsightTile(
//                 "Visual Scan",
//                 "AI Logic",
//                 "Analyzed pallor in eye pixels.",
//                 Icons.visibility,
//                 Colors.blue),
//             _buildInsightTile(
//                 "Symptoms",
//                 "${widget.userSymptoms.length} Merged",
//                 "Analyzed: ${widget.userSymptoms.join(', ')}",
//                 Icons.analytics,
//                 Colors.orange),

//             const SizedBox(height: 30),

//             // --- CONSULT AI BUTTON ---
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3B82F6),
//                 minimumSize: const Size(double.infinity, 65),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(22)),
//               ),
//               onPressed: () => _showAiDoctorConsultation(context),
//               child: const Text("Consult AI Advisor",
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16)),
//             ),

//             const SizedBox(height: 15),

//             // --- EXPORT PDF BUTTON ---
//             OutlinedButton(
//               style: OutlinedButton.styleFrom(
//                 minimumSize: const Size(double.infinity, 65),
//                 side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(22)),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ReportPreviewScreen(
//                       finalHb: widget.finalHb,
//                       selectedSymptoms: widget.userSymptoms,
//                     ),
//                   ),
//                 );
//               },
//               child: const Text("Export PDF",
//                   style: TextStyle(
//                       color: Color(0xFF475569), fontWeight: FontWeight.bold)),
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInsightTile(
//       String title, String tag, String content, IconData icon, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(25),
//           border: Border.all(color: Colors.grey.shade100)),
//       child: ExpansionTile(
//         leading: Icon(icon, color: color),
//         title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Text(tag, style: TextStyle(color: color, fontSize: 12)),
//         children: [
//           Padding(padding: const EdgeInsets.all(20), child: Text(content))
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hemoglobe_ai/screens/reports/report_preview_screen.dart';
import 'package:hemoglobe_ai/main_navigation_screen.dart';

class RefinedResultScreen extends StatefulWidget {
  final double finalHb;
  final List<String> userSymptoms;
  final String reportId;

  const RefinedResultScreen({
    super.key,
    required this.finalHb,
    required this.userSymptoms,
    required this.reportId,
  });

  @override
  State<RefinedResultScreen> createState() => _RefinedResultScreenState();
}

class _RefinedResultScreenState extends State<RefinedResultScreen> {
  bool _safetyUpdateDone = false;

  @override
  void initState() {
    super.initState();
    // ✅ Firestore update logic
    _ensureReportIsComplete();
  }

  Future<void> _ensureReportIsComplete() async {
    if (_safetyUpdateDone || widget.reportId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .get();
      if (!doc.exists) return;

      if (doc.data()?['isCompleted'] == true) {
        _safetyUpdateDone = true;
        return;
      }

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .update({
        'isCompleted': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      _safetyUpdateDone = true;
    } catch (e) {
      debugPrint("❌ Firestore Error: $e");
    }
  }

  Map<String, dynamic> getStatus() {
    if (widget.finalHb < 8.0) {
      return {
        'label': 'SEVERE ANEMIA',
        'color': const Color(0xFFD32F2F),
        'bg': const Color(0xFFFFEBEE)
      };
    } else if (widget.finalHb < 12.0) {
      return {
        'label': 'MODERATE ANEMIA',
        'color': const Color(0xFFE65100),
        'bg': const Color(0xFFFFF3E0)
      };
    } else {
      return {
        'label': 'NORMAL RANGE',
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9)
      };
    }
  }

  // --- AI DOCTOR POPUP (BOTTOM SHEET) ---
  void _showAiDoctorConsultation(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 15,
            left: 25,
            right: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Row(
              children: [
                const CircleAvatar(
                    backgroundColor: Color(0xFF0D47A1),
                    child: Icon(Icons.psychology, color: Colors.white)),
                const SizedBox(width: 15),
                const Text("AI Health Advisor",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF1A1C1E))),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "Your Hemoglobin is ${widget.finalHb} g/dL. Based on your symptoms (${widget.userSymptoms.join(', ')}), I can help you with diet plans or next steps.",
              style: const TextStyle(
                  color: Colors.black87, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: "Ask me anything...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none),
                suffixIcon: const Icon(Icons.send, color: Color(0xFF0D47A1)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = getStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Scan Report",
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- MAIN SCORE DISPLAY ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  const Text("Hemoglobin Level",
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text("${widget.finalHb}",
                          style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0D47A1))),
                      const SizedBox(width: 5),
                      const Text("g/dL",
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                        color: status['bg'] as Color,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text(status['label'] as String,
                        style: TextStyle(
                            color: status['color'] as Color,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- SYMPTOMS SECTION ---
            const Align(
                alignment: Alignment.centerLeft,
                child: Text("SYMPTOMS LOGGED",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))),
            const SizedBox(height: 10),
            ...widget.userSymptoms
                .map((s) =>
                    _buildDataTile(s, "YES", Icons.check_circle, Colors.green))
                .toList(),

            const SizedBox(height: 30),

            // --- PRIMARY BUTTON: CONSULT AI ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () => _showAiDoctorConsultation(context),
              icon: const Icon(Icons.psychology_outlined),
              label: const Text("Consult AI Advisor",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 12),

            // --- SECONDARY BUTTON: PDF EXPORT ---
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReportPreviewScreen(
                            finalHb: widget.finalHb,
                            selectedSymptoms: widget.userSymptoms)));
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text("Download PDF Report",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 25),

            // --- FINAL DONE BUTTON (GREEN) ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                elevation: 2,
              ),
              onPressed: () {
                // Ye line change karni hai:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen()),
                  (route) =>
                      false, // Ye purani saari screens (login, scan, etc.) nikaal dega
                );
              },
              child: const Text("Done & Back to Home",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTile(
      String title, String trailing, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14))),
          Text(trailing,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
