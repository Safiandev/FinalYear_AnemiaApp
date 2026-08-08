import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hemoglobe_ai/screens/tests/refined_result_screen.dart';

class AiRefinementLoadingScreen extends StatefulWidget {
  final String refinedStatus; // "Anemic" or "Non-Anemic"
  final double refinedConfidence; // 0-100
  final List<String> selectedSymptoms;
  final String reportId;

  const AiRefinementLoadingScreen({
    super.key,
    required this.refinedStatus,
    required this.refinedConfidence,
    required this.selectedSymptoms,
    required this.reportId,
  });

  @override
  State<AiRefinementLoadingScreen> createState() =>
      _AiRefinementLoadingScreenState();
}

class _AiRefinementLoadingScreenState extends State<AiRefinementLoadingScreen> {
  double progress = 0;
  String loadingText = "Analyzing symptoms...";

  bool _isAlreadyUpdated = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _updateFinalReport() async {
    if (_isAlreadyUpdated || widget.reportId.isEmpty) {
      debugPrint("⚠️ Update skipped: already done or reportId empty.");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .update({
        'statusLabel': widget.refinedStatus,
        'confidence': widget.refinedConfidence,
        'symptoms': widget.selectedSymptoms,
        'isCompleted': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      _isAlreadyUpdated = true;
      debugPrint("✅ Report Updated Successfully: ${widget.reportId}");
    } catch (e) {
      debugPrint("❌ Firestore Update Error (no new doc created): $e");
    }
  }

  void startLoading() {
    _updateFinalReport();

    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (progress < 1.0) {
          progress += 0.01;

          if (progress > 0.3 && progress <= 0.6) {
            loadingText = "Merging eye-scan data...";
          } else if (progress > 0.6 && progress <= 0.8) {
            loadingText = "Applying ML refinement...";
          } else if (progress > 0.8) {
            loadingText = "Finalizing results...";
          }
        } else {
          timer.cancel();
          _navigateToResult();
        }
      });
    });
  }

  void _navigateToResult() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RefinedResultScreen(
            finalStatus: widget.refinedStatus,
            finalConfidence: widget.refinedConfidence,
            userSymptoms: widget.selectedSymptoms,
            reportId: widget.reportId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double safeProgress = progress.clamp(0.0, 1.0);
    int percent = (safeProgress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("AI Re-Analysis",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "STEP 4 OF 4",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.grey),
            ),
            const SizedBox(height: 40),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.1),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOutSine,
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: const Icon(Icons.psychology_outlined,
                      size: 100, color: Colors.blue),
                );
              },
            ),
            const SizedBox(height: 30),
            Text(
              "$percent%",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              loadingText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 40),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: safeProgress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Combining your clinical symptoms with visual image data for a precision-refined analysis.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hemoglobe_ai/screens/tests/refined_result_screen.dart';

// class AiRefinementLoadingScreen extends StatefulWidget {
//   final double refinedHb;
//   final List<String> selectedSymptoms;
//   final String reportId; // ✅ FIXED: String? se String kar diya — yeh hamesha
//   //    available hona chahiye. Agar yahan null aata hai toh bug upstream hai.

//   const AiRefinementLoadingScreen({
//     super.key,
//     required this.refinedHb,
//     required this.selectedSymptoms,
//     required this.reportId, // ✅ Required — null allow nahi
//   });

//   @override
//   State<AiRefinementLoadingScreen> createState() =>
//       _AiRefinementLoadingScreenState();
// }

// class _AiRefinementLoadingScreenState extends State<AiRefinementLoadingScreen> {
//   double progress = 0;
//   String loadingText = "Analyzing symptoms...";

//   // ✅ CRITICAL FIX: Yeh flag ensure karta hai ke Firestore update
//   // sirf ONCE hogi — chahe timer kitni baar bhi chale.
//   bool _isAlreadyUpdated = false;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     startLoading();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   String _getStatusLabel(double hb) {
//     if (hb < 8.0) return "Severe Anemia";
//     if (hb < 12.0) return "Mild Anemia";
//     return "Normal Range";
//   }

//   Future<void> _updateFinalReport() async {
//     // ✅ CRITICAL FIX: Double-update se bachao
//     // Yeh guard ensure karta hai ke sirf EXISTING report update ho,
//     // koi NAYA document kabhi create NA ho is function mein.
//     if (_isAlreadyUpdated || widget.reportId.isEmpty) {
//       debugPrint("⚠️ Update skipped: already done or reportId empty.");
//       return;
//     }

//     try {
//       // ✅ .update() use kar rahe hain — .set() ya .add() BILKUL NAHI.
//       // .update() sirf existing document update karta hai.
//       // Agar document exist nahi karta toh yeh ERROR throw karega
//       // (jo actually helpful hai — silently naya doc nahi banega).
//       await FirebaseFirestore.instance
//           .collection('reports')
//           .doc(widget.reportId)
//           .update({
//         'hbValue': widget.refinedHb,
//         'statusLabel': _getStatusLabel(widget.refinedHb),
//         'symptoms': widget.selectedSymptoms,
//         'isCompleted': true, // ✅ Ab yeh report complete ho gayi
//         'lastUpdated': FieldValue.serverTimestamp(),
//       });

//       _isAlreadyUpdated = true; // ✅ Flag set — dobara nahi chalega
//       debugPrint("✅ Report Updated Successfully: ${widget.reportId}");
//     } catch (e) {
//       // ✅ Error log karo lekin koi naya document MAT banao
//       debugPrint("❌ Firestore Update Error (no new doc created): $e");
//     }
//   }

//   void startLoading() {
//     // ✅ Background mein update shuru — UI block nahi hoga
//     _updateFinalReport();

//     _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
//       if (!mounted) {
//         timer.cancel();
//         return;
//       }

//       setState(() {
//         if (progress < 1.0) {
//           progress += 0.01;

//           if (progress > 0.3 && progress <= 0.6) {
//             loadingText = "Merging eye-scan data...";
//           } else if (progress > 0.6 && progress <= 0.8) {
//             loadingText = "Applying ML refinement...";
//           } else if (progress > 0.8) {
//             loadingText = "Finalizing results...";
//           }
//         } else {
//           timer.cancel();
//           _navigateToResult();
//         }
//       });
//     });
//   }

//   void _navigateToResult() {
//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => RefinedResultScreen(
//             finalHb: widget.refinedHb,
//             userSymptoms: widget.selectedSymptoms,
//             reportId: widget.reportId, // ✅ Same ID forward kar do
//           ),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     double safeProgress = progress.clamp(0.0, 1.0);
//     int percent = (safeProgress * 100).toInt();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("AI Re-Analysis",
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 30),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               "STEP 4 OF 4",
//               style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 1.5,
//                   color: Colors.grey),
//             ),
//             const SizedBox(height: 40),
//             TweenAnimationBuilder(
//               tween: Tween<double>(begin: 0.8, end: 1.1),
//               duration: const Duration(seconds: 1),
//               curve: Curves.easeInOutSine,
//               builder: (context, double value, child) {
//                 return Transform.scale(
//                   scale: value,
//                   child: const Icon(Icons.psychology_outlined,
//                       size: 100, color: Colors.blue),
//                 );
//               },
//             ),
//             const SizedBox(height: 30),
//             Text(
//               "$percent%",
//               style: const TextStyle(
//                 fontSize: 48,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               loadingText,
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 40),
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: safeProgress,
//                 minHeight: 10,
//                 backgroundColor: Colors.grey.shade200,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 30),
//             const Text(
//               "Combining your clinical symptoms with visual image data for a precision-refined Hemoglobin estimate.",
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey, height: 1.5, fontSize: 13),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
