import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hemoglobe_ai/screens/reports/report_preview_screen.dart';
import 'package:hemoglobe_ai/main_navigation_screen.dart';

class RefinedResultScreen extends StatefulWidget {
  final String finalStatus; // "Anemic" or "Non-Anemic"
  final double finalConfidence; // 0-100
  final List<String> userSymptoms;
  final String reportId;

  const RefinedResultScreen({
    super.key,
    required this.finalStatus,
    required this.finalConfidence,
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
    _ensureReportIsComplete();
  }

  /// Ensures that the Firestore document is marked complete once per screen load
  Future<void> _ensureReportIsComplete() async {
    if (_safetyUpdateDone || widget.reportId.isEmpty) return;

    try {
      final docRef =
          FirebaseFirestore.instance.collection('reports').doc(widget.reportId);

      final doc = await docRef.get();
      if (!doc.exists) return;

      if (doc.data()?['isCompleted'] == true) {
        _safetyUpdateDone = true;
        return;
      }

      await docRef.update({
        'isCompleted': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _safetyUpdateDone = true;
    } catch (e) {
      debugPrint("❌ Firestore Error: $e");
    }
  }

  /// Maps classification status to color palettes and diagnostic labels
  Map<String, dynamic> _getStatus() {
    if (widget.finalStatus == 'Anemic') {
      return {
        'label': 'ANEMIC',
        'color': const Color(0xFFD32F2F),
        'bg': const Color(0xFFFFEBEE),
      };
    } else {
      return {
        'label': 'NON-ANEMIC',
        'color': const Color(0xFF2E7D32),
        'bg': const Color(0xFFE8F5E9),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Scan Report",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
            // Main Score Display Card
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "AI Confidence Score",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${widget.finalConfidence.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0D47A1),
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "%",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: status['bg'] as Color,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status['label'] as String,
                      style: TextStyle(
                        color: status['color'] as Color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Symptoms Logged Heading & Items
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "SYMPTOMS LOGGED",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),

            ...widget.userSymptoms.map(
              (symptom) => _buildDataTile(
                title: symptom,
                trailing: "YES",
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 30),

            // Export PDF Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportPreviewScreen(
                      finalStatus: widget.finalStatus,
                      finalConfidence: widget.finalConfidence,
                      selectedSymptoms: widget.userSymptoms,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text(
                "Download PDF Report",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 25),

            // Complete Navigation Action Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 65),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 2,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "Done & Back to Home",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// Helper Component for Displaying Logged Symptom Rows
  Widget _buildDataTile({
    required String title,
    required String trailing,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            trailing,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hemoglobe_ai/screens/reports/report_preview_screen.dart';
// import 'package:hemoglobe_ai/main_navigation_screen.dart';

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
//     // ✅ Firestore update logic
//     _ensureReportIsComplete();
//   }

//   Future<void> _ensureReportIsComplete() async {
//     if (_safetyUpdateDone || widget.reportId.isEmpty) return;
//     try {
//       final doc = await FirebaseFirestore.instance
//           .collection('reports')
//           .doc(widget.reportId)
//           .get();
//       if (!doc.exists) return;

//       if (doc.data()?['isCompleted'] == true) {
//         _safetyUpdateDone = true;
//         return;
//       }

//       await FirebaseFirestore.instance
//           .collection('reports')
//           .doc(widget.reportId)
//           .update({
//         'isCompleted': true,
//         'lastUpdated': FieldValue.serverTimestamp(),
//       });
//       _safetyUpdateDone = true;
//     } catch (e) {
//       debugPrint("❌ Firestore Error: $e");
//     }
//   }

//   Map<String, dynamic> getStatus() {
//     if (widget.finalHb < 8.0) {
//       return {
//         'label': 'SEVERE ANEMIA',
//         'color': const Color(0xFFD32F2F),
//         'bg': const Color(0xFFFFEBEE)
//       };
//     } else if (widget.finalHb < 12.0) {
//       return {
//         'label': 'MODERATE ANEMIA',
//         'color': const Color(0xFFE65100),
//         'bg': const Color(0xFFFFF3E0)
//       };
//     } else {
//       return {
//         'label': 'NORMAL RANGE',
//         'color': const Color(0xFF2E7D32),
//         'bg': const Color(0xFFE8F5E9)
//       };
//     }
//   }

//   // --- AI DOCTOR POPUP (BOTTOM SHEET) ---
//   void _showAiDoctorConsultation(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//             top: 15,
//             left: 25,
//             right: 25),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10))),
//             const SizedBox(height: 20),
//             const Row(
//               children: [
//                 CircleAvatar(
//                     backgroundColor: Color(0xFF0D47A1),
//                     child: Icon(Icons.psychology, color: Colors.white)),
//                 SizedBox(width: 15),
//                 Text("AI Health Advisor",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                         color: Color(0xFF1A1C1E))),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               "Your Hemoglobin is ${widget.finalHb} g/dL. Based on your symptoms (${widget.userSymptoms.join(', ')}), I can help you with diet plans or next steps.",
//               style: const TextStyle(
//                   color: Colors.black87, fontSize: 15, height: 1.5),
//             ),
//             const SizedBox(height: 20),
//             TextField(
//               decoration: InputDecoration(
//                 hintText: "Ask me anything...",
//                 filled: true,
//                 fillColor: Colors.grey.shade100,
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(15),
//                     borderSide: BorderSide.none),
//                 suffixIcon: const Icon(Icons.send, color: Color(0xFF0D47A1)),
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final status = getStatus();

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text("Scan Report",
//             style: TextStyle(
//                 color: Colors.black,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 20)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () =>
//               Navigator.of(context).popUntil((route) => route.isFirst),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // --- MAIN SCORE DISPLAY ---
//             Container(
//               padding: const EdgeInsets.all(25),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                       color: Colors.black.withOpacity(0.03),
//                       blurRadius: 10,
//                       offset: const Offset(0, 5))
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text("Hemoglobin Level",
//                       style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500)),
//                   const SizedBox(height: 10),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.baseline,
//                     textBaseline: TextBaseline.alphabetic,
//                     children: [
//                       Text("${widget.finalHb}",
//                           style: const TextStyle(
//                               fontSize: 50,
//                               fontWeight: FontWeight.w900,
//                               color: Color(0xFF0D47A1))),
//                       const SizedBox(width: 5),
//                       const Text("g/dL",
//                           style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.grey,
//                               fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                   const SizedBox(height: 15),
//                   Container(
//                     padding:
//                         const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                     decoration: BoxDecoration(
//                         color: status['bg'] as Color,
//                         borderRadius: BorderRadius.circular(10)),
//                     child: Text(status['label'] as String,
//                         style: TextStyle(
//                             color: status['color'] as Color,
//                             fontWeight: FontWeight.bold,
//                             letterSpacing: 0.5)),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 25),

//             // --- SYMPTOMS SECTION ---
//             const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text("SYMPTOMS LOGGED",
//                     style: TextStyle(
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 13))),
//             const SizedBox(height: 10),
//             ...widget.userSymptoms
//                 .map((s) =>
//                     _buildDataTile(s, "YES", Icons.check_circle, Colors.green))
//                 ,

//             const SizedBox(height: 30),

//             // --- PRIMARY BUTTON: CONSULT AI ---
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0D47A1),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 60),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15)),
//                 elevation: 0,
//               ),
//               onPressed: () => _showAiDoctorConsultation(context),
//               icon: const Icon(Icons.psychology_outlined),
//               label: const Text("Consult AI Advisor",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),

//             const SizedBox(height: 12),

//             // --- SECONDARY BUTTON: PDF EXPORT ---
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1565C0),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 60),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15)),
//                 elevation: 0,
//               ),
//               onPressed: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => ReportPreviewScreen(
//                             finalHb: widget.finalHb,
//                             selectedSymptoms: widget.userSymptoms)));
//               },
//               icon: const Icon(Icons.picture_as_pdf_outlined),
//               label: const Text("Download PDF Report",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             ),

//             const SizedBox(height: 25),

//             // --- FINAL DONE BUTTON (GREEN) ---
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4CAF50),
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 65),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(18)),
//                 elevation: 2,
//               ),
//               onPressed: () {
//                 // Ye line change karni hai:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const MainNavigationScreen()),
//                   (route) =>
//                       false, // Ye purani saari screens (login, scan, etc.) nikaal dega
//                 );
//               },
//               child: const Text("Done & Back to Home",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDataTile(
//       String title, String trailing, IconData icon, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(15),
//           border: Border.all(color: Colors.grey.shade100)),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 22),
//           const SizedBox(width: 12),
//           Expanded(
//               child: Text(title,
//                   style: const TextStyle(
//                       fontWeight: FontWeight.w500, fontSize: 14))),
//           Text(trailing,
//               style: TextStyle(
//                   color: color, fontWeight: FontWeight.bold, fontSize: 13)),
//         ],
//       ),
//     );
//   }
// }
