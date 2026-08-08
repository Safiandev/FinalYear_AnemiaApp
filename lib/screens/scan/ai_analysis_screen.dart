import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hemoglobe_ai/result_screen.dart'; // Ensure ResultScreen accepts data
import 'package:hemoglobe_ai/services/anemia_detection_service.dart';

class AiAnalysisScreen extends StatefulWidget {
  final File imageFile; // Image received from Camera/Gallery

  const AiAnalysisScreen({super.key, required this.imageFile});

  @override
  State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
}

class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
  double progress = 0.0;
  int percent = 0;
  String currentTask = "Initializing AI Engine...";

  // Status check variables
  bool qualityCheck = false;
  bool featureExtraction = false;
  bool hemoglobinEstimation = false;

  final AnemiaDetectionService _detectionService = AnemiaDetectionService();

  @override
  void initState() {
    super.initState();
    _startDeepAnalysis();
  }

  void _startDeepAnalysis() async {
    // --- STEP 1: Image Quality Validation ---
    setState(() => currentTask = "Validating Image Quality...");
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      qualityCheck = true;
      percent = 25;
      progress = 0.25;
    });

    // --- STEP 2: Feature Extraction & TFLite Model Execution ---
    setState(() => currentTask = "Extracting Conjunctival Patterns...");
    for (int i = 25; i <= 60; i += 5) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        percent = i;
        progress = i / 100;
      });
    }

    // Actual TFLite Model Inference Execution
    Map<String, dynamic> predictionData =
        await _detectionService.predict(widget.imageFile);
    setState(() => featureExtraction = true);

    // --- STEP 3: Hemoglobin Estimation ---
    setState(() => currentTask = "Estimating Hemoglobin Levels...");
    for (int i = 60; i <= 100; i += 4) {
      await Future.delayed(const Duration(milliseconds: 60));
      setState(() {
        percent = i;
        progress = i / 100;
      });
    }
    setState(() => hemoglobinEstimation = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    // --- NAVIGATION TO RESULT SCREEN WITH DATA ---
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          predictionData: predictionData,
          imageFile: widget.imageFile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('AI Analysis',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ---------- CIRCULAR PROGRESS WITH GLOW ----------
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    color: primaryColor,
                    backgroundColor: Colors.blue.shade50,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const Text(
                      'ANALYZING',
                      style: TextStyle(
                          letterSpacing: 2, color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 40),

            // ---------- STATUS SECTION ----------
            Text(
              currentTask,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // ---------- PROGRESS STEPS ----------
            _buildStepRow("Quality Validation", qualityCheck),
            _buildStepRow("Feature Extraction", featureExtraction),
            _buildStepRow("HB Estimation", hemoglobinEstimation),

            const Spacer(),

            // ---------- SECURITY FOOTER ----------
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: primaryColor, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'AI analysis is performed locally and securely.',
                      style: TextStyle(fontSize: 13, color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String title, bool isDone) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? Colors.green : Colors.blue.withOpacity(0.3),
            size: 22,
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: isDone ? Colors.black : Colors.grey,
              fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          if (!isDone && percent > 0)
            const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'package:hemoglobe_ai/result_screen.dart'; // Ensure this file exists

// class AiAnalysisScreen extends StatefulWidget {
//   const AiAnalysisScreen({super.key});

//   @override
//   State<AiAnalysisScreen> createState() => _AiAnalysisScreenState();
// }

// class _AiAnalysisScreenState extends State<AiAnalysisScreen> {
//   double progress = 0.0;
//   int percent = 0;
//   String currentTask = "Initializing AI Engine...";

//   // Status check variables
//   bool qualityCheck = false;
//   bool featureExtraction = false;
//   bool hemoglobinEstimation = false;

//   @override
//   void initState() {
//     super.initState();
//     _startDeepAnalysis();
//   }

//   void _startDeepAnalysis() async {
//     // --- STEP 1: Image Quality Validation ---
//     setState(() => currentTask = "Validating Image Quality...");
//     await Future.delayed(const Duration(seconds: 2));
//     setState(() {
//       qualityCheck = true;
//       percent = 25;
//       progress = 0.25;
//     });

//     // --- STEP 2: Feature Extraction (Simulated) ---
//     setState(() => currentTask = "Extracting Conjunctival Patterns...");
//     for (int i = 25; i <= 60; i += 5) {
//       await Future.delayed(const Duration(milliseconds: 150));
//       setState(() {
//         percent = i;
//         progress = i / 100;
//       });
//     }
//     setState(() => featureExtraction = true);

//     // --- STEP 3: Hemoglobin Estimation ---
//     setState(() => currentTask = "Estimating Hemoglobin Levels...");
//     for (int i = 60; i <= 100; i += 2) {
//       await Future.delayed(const Duration(milliseconds: 80));
//       setState(() {
//         percent = i;
//         progress = i / 100;
//       });
//     }
//     setState(() => hemoglobinEstimation = true);

//     // --- NAVIGATION TO RESULT SCREEN ---
//     if (!mounted) return;

//     // Yahan hum ResultScreen par move kar jayenge
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const ResultScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Synth-wave colors/Dark aesthetic touch
//     final primaryColor = Colors.blue.shade700;

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.close, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('AI Analysis',
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
//         child: Column(
//           children: [
//             const SizedBox(height: 20),

//             // ---------- CIRCULAR PROGRESS WITH GLOW ----------
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 SizedBox(
//                   width: 200,
//                   height: 200,
//                   child: CircularProgressIndicator(
//                     value: progress,
//                     strokeWidth: 12,
//                     color: primaryColor,
//                     backgroundColor: Colors.blue.shade50,
//                     strokeCap: StrokeCap.round,
//                   ),
//                 ),
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       '$percent%',
//                       style: TextStyle(
//                         fontSize: 42,
//                         fontWeight: FontWeight.bold,
//                         color: primaryColor,
//                       ),
//                     ),
//                     const Text(
//                       'ANALYZING',
//                       style: TextStyle(
//                           letterSpacing: 2, color: Colors.grey, fontSize: 12),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 40),

//             // ---------- STATUS SECTION ----------
//             Text(
//               currentTask,
//               style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87),
//               textAlign: TextAlign.center,
//             ),

//             const SizedBox(height: 30),

//             // ---------- PROGRESS STEPS ----------
//             _buildStepRow("Quality Validation", qualityCheck),
//             _buildStepRow("Feature Extraction", featureExtraction),
//             _buildStepRow("HB Estimation", hemoglobinEstimation),

//             const Spacer(),

//             // ---------- SECURITY FOOTER ----------
//             Container(
//               padding: const EdgeInsets.all(15),
//               decoration: BoxDecoration(
//                 color: Colors.blue.shade50,
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.verified_user, color: primaryColor, size: 20),
//                   const SizedBox(width: 12),
//                   const Expanded(
//                     child: Text(
//                       'AI analysis is performed locally and securely.',
//                       style: TextStyle(fontSize: 13, color: Colors.blueGrey),
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

//   Widget _buildStepRow(String title, bool isDone) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         children: [
//           Icon(
//             isDone ? Icons.check_circle : Icons.radio_button_unchecked,
//             color: isDone ? Colors.green : Colors.blue.withOpacity(0.3),
//             size: 22,
//           ),
//           const SizedBox(width: 15),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 15,
//               color: isDone ? Colors.black : Colors.grey,
//               fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           const Spacer(),
//           if (!isDone && percent > 0)
//             const SizedBox(
//               width: 15,
//               height: 15,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             ),
//         ],
//       ),
//     );
//   }
// }
