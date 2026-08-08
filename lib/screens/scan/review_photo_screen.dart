import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:hemoglobe_ai/screens/scan/ai_analysis_screen.dart';

class ReviewPhotoScreen extends StatefulWidget {
  final String imagePath;
  const ReviewPhotoScreen({super.key, required this.imagePath});

  @override
  State<ReviewPhotoScreen> createState() => _ReviewPhotoScreenState();
}

class _ReviewPhotoScreenState extends State<ReviewPhotoScreen> {
  bool isScanning = true;
  double qualityScore = 0.0;

  String lightingStatus = "Analyzing...";
  String focusStatus = "Analyzing...";
  String detectionStatus = "Analyzing...";

  Color lightingColor = Colors.grey;
  Color focusColor = Colors.grey;
  Color detectionColor = Colors.grey;

  double filterOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _performSmartImageAnalysis();
  }

  Future<void> _performSmartImageAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final bytes = await File(widget.imagePath).readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      if (!mounted) return;
      _showErrorDialog(
          "Corrupt Image", "Could not read the image data. Please retake.");
      return;
    }

    double totalRed = 0;
    double totalGreen = 0;
    double totalBlue = 0;

    final workingImg =
        image.width > 800 ? img.copyResize(image, width: 800) : image;

    for (var y = 0; y < workingImg.height; y += 10) {
      for (var x = 0; x < workingImg.width; x += 10) {
        final pixel = workingImg.getPixel(x, y);
        totalRed += pixel.r;
        totalGreen += pixel.g;
        totalBlue += pixel.b;
      }
    }

    final totalPixels = (workingImg.width / 10) * (workingImg.height / 10);

    double finalRed = totalRed / totalPixels;
    double finalGreen = totalGreen / totalPixels;
    double finalBlue = totalBlue / totalPixels;

    double avgBrightness =
        (0.299 * finalRed + 0.587 * finalGreen + 0.114 * finalBlue) / 255;
    double avgRedness =
        (finalRed / (finalRed + finalGreen + finalBlue + 0.1)) * 100;

    bool blurOK = finalRed > 40 && finalGreen > 20;

    if (!mounted) return;

    setState(() {
      if (avgBrightness < 0.25) {
        lightingStatus = "Too Dark";
        lightingColor = Colors.orange;
      } else if (avgBrightness > 0.85) {
        lightingStatus = "Too Bright / Glare";
        lightingColor = Colors.orange;
      } else {
        lightingStatus = "Optimal Lighting";
        lightingColor = Colors.green;
      }

      if (blurOK) {
        focusStatus = "Target in Focus";
        focusColor = Colors.green;
      } else {
        focusStatus = "Slightly Blurry";
        focusColor = Colors.orange;
      }

      if (avgRedness > 34) {
        detectionStatus = "Eyelid Detected";
        detectionColor = Colors.green;
        qualityScore = (0.6 * 0.9) +
            (0.2 * avgBrightness.clamp(0.1, 1.0)) +
            (0.2 * (blurOK ? 0.9 : 0.4));
      } else {
        detectionStatus = "Invalid Object";
        detectionColor = Colors.red;
        qualityScore = 0.25;
      }

      filterOpacity = (avgBrightness < 0.4) ? 0.15 : 0.0;
      isScanning = false;
    });

    if (qualityScore < 0.45 || avgRedness < 33) {
      _showErrorDialog(
        "Invalid Image",
        "The captured image doesn't look like a clear eyelid. Please ensure proper lighting and focus.",
      );
    }
  }

  void _showErrorDialog(String title, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold)),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Retake & Pop back to Camera
            },
            child: const Text("Retake Photo",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Review Photo Quality',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(filterOpacity),
                        BlendMode.softLight),
                    child: Image.file(File(widget.imagePath),
                        height: 280, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
                if (isScanning)
                  Container(
                    height: 280,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20)),
                    child: const Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            if (!isScanning) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Quality Score",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("${(qualityScore * 100).toInt()}%",
                      style: TextStyle(
                          color: qualityScore > 0.5 ? Colors.blue : Colors.red,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                  value: qualityScore,
                  backgroundColor: Colors.grey.shade200,
                  color: qualityScore > 0.5 ? Colors.green : Colors.orange,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10)),
            ],
            const SizedBox(height: 25),
            const Text('DETECTION LOGIC',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                    fontSize: 12)),
            const SizedBox(height: 15),
            _qualityTile(
                icon: Icons.light_mode,
                title: 'Lighting',
                subtitle: lightingStatus,
                iconColor: lightingColor,
                done: !isScanning),
            _qualityTile(
                icon: Icons.center_focus_strong,
                title: 'Focus',
                subtitle: focusStatus,
                iconColor: focusColor,
                done: !isScanning),
            _qualityTile(
                icon: Icons.remove_red_eye,
                title: 'Eyelid Detection',
                subtitle: detectionStatus,
                iconColor: detectionColor,
                done: !isScanning),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: (isScanning || qualityScore < 0.45)
                  ? null
                  : () {
                      // ✅ UPDATED: Navigates cleanly to AiAnalysisScreen with dynamic File object
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AiAnalysisScreen(
                            imageFile: File(widget.imagePath),
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))),
              child: Text(
                  qualityScore > 0.6 ? 'Proceed to Analysis' : 'Analyze Anyway',
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))),
              child: const Text('Retake Photo',
                  style: TextStyle(fontSize: 16, color: Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qualityTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color iconColor,
      required bool done}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
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
                    style: TextStyle(color: iconColor, fontSize: 13)),
              ],
            ),
          ),
          if (done)
            Icon(Icons.check_circle_rounded, color: iconColor, size: 22),
        ],
      ),
    );
  }
}

// import 'dart:io';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:image/image.dart' as img;
// import 'package:hemoglobe_ai/screens/scan/ai_analysis_screen.dart';

// class ReviewPhotoScreen extends StatefulWidget {
//   final String imagePath;
//   const ReviewPhotoScreen({super.key, required this.imagePath});

//   @override
//   State<ReviewPhotoScreen> createState() => _ReviewPhotoScreenState();
// }

// class _ReviewPhotoScreenState extends State<ReviewPhotoScreen> {
//   bool isScanning = true;
//   double qualityScore = 0.0;

//   String lightingStatus = "Analyzing...";
//   String focusStatus = "Analyzing...";
//   String detectionStatus = "Analyzing...";

//   Color lightingColor = Colors.grey;
//   Color focusColor = Colors.grey;
//   Color detectionColor = Colors.grey;

//   double filterOpacity = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _performSmartImageAnalysis();
//   }

//   Future<void> _performSmartImageAnalysis() async {
//     await Future.delayed(const Duration(milliseconds: 1500));

//     final bytes = await File(widget.imagePath).readAsBytes();
//     final image = img.decodeImage(bytes);

//     if (image == null) {
//       _showErrorDialog(
//           "Corrupt Image", "Could not read the image data. Please retake.");
//       return;
//     }

//     double totalRed = 0;
//     double totalGreen = 0;
//     double totalBlue = 0;

//     final workingImg =
//         image.width > 800 ? img.copyResize(image, width: 800) : image;

//     for (var y = 0; y < workingImg.height; y += 10) {
//       for (var x = 0; x < workingImg.width; x += 10) {
//         final pixel = workingImg.getPixel(x, y);
//         totalRed += pixel.r;
//         totalGreen += pixel.g;
//         totalBlue += pixel.b;
//       }
//     }

//     final totalPixels = (workingImg.width / 10) * (workingImg.height / 10);

//     double finalRed = totalRed / totalPixels;
//     double finalGreen = totalGreen / totalPixels;
//     double finalBlue = totalBlue / totalPixels;

//     double avgBrightness =
//         (0.299 * finalRed + 0.587 * finalGreen + 0.114 * finalBlue) / 255;
//     double avgRedness =
//         (finalRed / (finalRed + finalGreen + finalBlue + 0.1)) * 100;

//     bool blurOK = finalRed > 40 && finalGreen > 20;

//     if (!mounted) return;

//     setState(() {
//       if (avgBrightness < 0.25) {
//         lightingStatus = "Too Dark";
//         lightingColor = Colors.orange;
//       } else if (avgBrightness > 0.85) {
//         lightingStatus = "Too Bright / Glare";
//         lightingColor = Colors.orange;
//       } else {
//         lightingStatus = "Optimal Lighting";
//         lightingColor = Colors.green;
//       }

//       if (blurOK) {
//         focusStatus = "Target in Focus";
//         focusColor = Colors.green;
//       } else {
//         focusStatus = "Slightly Blurry";
//         focusColor = Colors.orange;
//       }

//       if (avgRedness > 34) {
//         detectionStatus = "Eyelid Detected";
//         detectionColor = Colors.green;
//         qualityScore = (0.6 * 0.9) +
//             (0.2 * avgBrightness.clamp(0.1, 1.0)) +
//             (0.2 * (blurOK ? 0.9 : 0.4));
//       } else {
//         detectionStatus = "Invalid Object";
//         detectionColor = Colors.red;
//         qualityScore = 0.25;
//       }

//       filterOpacity = (avgBrightness < 0.4) ? 0.15 : 0.0;
//       isScanning = false;
//     });

//     if (qualityScore < 0.45 || avgRedness < 33) {
//       _showErrorDialog(
//         "Invalid Image",
//         "The captured image doesn't look like a clear eyelid. Please ensure proper lighting and focus.",
//       );
//     }
//   }

//   void _showErrorDialog(String title, String msg) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: Text(title,
//             style: const TextStyle(
//                 color: Colors.red, fontWeight: FontWeight.bold)),
//         content: Text(msg),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pop(context);
//             },
//             child: const Text("Retake Photo",
//                 style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text('Review Photo Quality',
//             style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               alignment: Alignment.center,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(20),
//                   child: ColorFiltered(
//                     colorFilter: ColorFilter.mode(
//                         Colors.white.withOpacity(filterOpacity),
//                         BlendMode.softLight),
//                     child: Image.file(File(widget.imagePath),
//                         height: 280, width: double.infinity, fit: BoxFit.cover),
//                   ),
//                 ),
//                 if (isScanning)
//                   Container(
//                     height: 280,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                         color: Colors.black.withOpacity(0.3),
//                         borderRadius: BorderRadius.circular(20)),
//                     child: const Center(
//                         child: CircularProgressIndicator(color: Colors.white)),
//                   ),
//               ],
//             ),
//             const SizedBox(height: 15),
//             if (!isScanning) ...[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text("Quality Score",
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   Text("${(qualityScore * 100).toInt()}%",
//                       style: TextStyle(
//                           color: qualityScore > 0.5 ? Colors.blue : Colors.red,
//                           fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               LinearProgressIndicator(
//                   value: qualityScore,
//                   backgroundColor: Colors.grey.shade200,
//                   color: qualityScore > 0.5 ? Colors.green : Colors.orange,
//                   minHeight: 8,
//                   borderRadius: BorderRadius.circular(10)),
//             ],
//             const SizedBox(height: 25),
//             const Text('DETECTION LOGIC',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blueGrey,
//                     fontSize: 12)),
//             const SizedBox(height: 15),
//             _qualityTile(
//                 icon: Icons.light_mode,
//                 title: 'Lighting',
//                 subtitle: lightingStatus,
//                 iconColor: lightingColor,
//                 done: !isScanning),
//             _qualityTile(
//                 icon: Icons.center_focus_strong,
//                 title: 'Focus',
//                 subtitle: focusStatus,
//                 iconColor: focusColor,
//                 done: !isScanning),
//             _qualityTile(
//                 icon: Icons.remove_red_eye,
//                 title: 'Eyelid Detection',
//                 subtitle: detectionStatus,
//                 iconColor: detectionColor,
//                 done: !isScanning),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: (isScanning || qualityScore < 0.45)
//                   ? null
//                   : () {
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const AiAnalysisScreen(imageFile: File(widget.imagePath)));
//                     },
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade700,
//                   disabledBackgroundColor: Colors.grey.shade300,
//                   minimumSize: const Size(double.infinity, 60),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18))),
//               child: const Text('Analyze Anyway',
//                   style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 12),
//             OutlinedButton(
//               onPressed: () => Navigator.pop(context),
//               style: OutlinedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 60),
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(18))),
//               child: const Text('Retake Photo',
//                   style: TextStyle(fontSize: 16, color: Colors.black87)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _qualityTile(
//       {required IconData icon,
//       required String title,
//       required String subtitle,
//       required Color iconColor,
//       required bool done}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: Colors.grey.shade100)),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//                 color: iconColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12)),
//             child: Icon(icon, color: iconColor, size: 24),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 15)),
//                 Text(subtitle,
//                     style: TextStyle(color: iconColor, fontSize: 13)),
//               ],
//             ),
//           ),
//           if (done)
//             Icon(Icons.check_circle_rounded, color: iconColor, size: 22),
//         ],
//       ),
//     );
//   }
// }
