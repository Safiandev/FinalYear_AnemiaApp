// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:hemoglobe_ai/main_navigation_screen.dart';
// import 'package:hemoglobe_ai/user_provider.dart';

// class ReportPreviewScreen extends StatefulWidget {
//   final double finalHb;
//   final List<String> selectedSymptoms;

//   const ReportPreviewScreen({
//     super.key,
//     required this.finalHb,
//     required this.selectedSymptoms,
//   });

//   @override
//   State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
// }

// class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
//   bool _isFinishing = false;
//   late String reportId;

//   String get userName => UserProvider.userName ?? "Guest User";
//   String get userAge => UserProvider.userAge ?? "N/A";
//   String get userGender => UserProvider.userGender ?? "N/A";

//   @override
//   void initState() {
//     super.initState();
//     reportId = (Random().nextInt(9000) + 1000).toString();
//   }

//   // ✅ Removed all 'const' from here to fix the operator error
//   Map<String, dynamic> getStatusDetails() {
//     if (widget.finalHb < 8.0) {
//       return {
//         'label': 'SEVERE ANEMIA',
//         'color': Colors.red.shade700,
//         'bgColor': Colors.red.shade50,
//         'pdfColor': PdfColors.red900
//       };
//     } else if (widget.finalHb < 12.0) {
//       return {
//         'label': 'MODERATE ANEMIA',
//         'color': Colors.orange.shade800,
//         'bgColor': Colors.orange.shade50,
//         'pdfColor': PdfColors.orange900
//       };
//     } else {
//       return {
//         'label': 'NORMAL RANGE',
//         'color': Colors.green.shade700,
//         'bgColor': Colors.green.shade50,
//         'pdfColor': PdfColors.green900
//       };
//     }
//   }

//   List<Map<String, String>> getRecommendations() {
//     if (widget.finalHb < 12.0) {
//       return [
//         {
//           "food": "Spinach & Kale",
//           "benefit": "Rich in Iron and Folic acid.",
//           "precaution": "Cook properly."
//         },
//         {
//           "food": "Red Meat",
//           "benefit": "High heme-iron source.",
//           "precaution": "Limit if high BP."
//         },
//       ];
//     }
//     return [
//       {
//         "food": "Citrus Fruits",
//         "benefit": "Vitamin C helps iron absorption.",
//         "precaution": "Take with meals."
//       },
//       {
//         "food": "Nuts & Seeds",
//         "benefit": "Maintain healthy blood levels.",
//         "precaution": "Soak overnight."
//       },
//     ];
//   }

//   Future<File> _generatePdfFile() async {
//     final pdf = pw.Document();
//     final status = getStatusDetails();
//     final foods = getRecommendations();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Padding(
//             padding: const pw.EdgeInsets.all(35),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text("HemoScan AI",
//                               style: pw.TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: PdfColors.blue900)),
//                           pw.Text("Smart Hemoglobin Assessment",
//                               style: const pw.TextStyle(
//                                   fontSize: 10, color: PdfColors.grey)),
//                         ]),
//                     pw.Text("Report ID: #$reportId",
//                         style: pw.TextStyle(
//                             fontSize: 12, fontWeight: pw.FontWeight.bold)),
//                   ],
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Divider(thickness: 1.5, color: PdfColors.blue900),
//                 pw.SizedBox(height: 20),

//                 pw.Row(children: [
//                   pw.Expanded(
//                       child: pw.Text("Patient: $userName",
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Expanded(child: pw.Text("Age: $userAge")),
//                   pw.Expanded(child: pw.Text("Gender: $userGender")),
//                 ]),
//                 pw.SizedBox(height: 30),

//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(20),
//                   decoration: const pw.BoxDecoration(
//                       color: PdfColors.grey100,
//                       borderRadius:
//                           pw.BorderRadius.all(pw.Radius.circular(10))),
//                   child: pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text("HEMOGLOBIN LEVEL (Hb)",
//                           style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold, fontSize: 14)),
//                       pw.Column(children: [
//                         pw.Text("${widget.finalHb} g/dL",
//                             style: pw.TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: status['pdfColor'])),
//                         pw.Text(status['label'],
//                             style: pw.TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: status['pdfColor'])),
//                       ]),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 30),

//                 pw.Text("SYMPTOMS LOGGED",
//                     style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold, fontSize: 12)),
//                 pw.Divider(thickness: 0.5),
//                 ...widget.selectedSymptoms.map((s) => pw.Padding(
//                       padding: const pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(s, style: const pw.TextStyle(fontSize: 11)),
//                             pw.Text("YES",
//                                 style: pw.TextStyle(
//                                     fontWeight: pw.FontWeight.bold,
//                                     color: PdfColors.green)),
//                           ]),
//                     )),
//                 pw.SizedBox(height: 30),

//                 pw.Text("DIETARY RECOMMENDATIONS",
//                     style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold,
//                         fontSize: 12,
//                         color: PdfColors.blue800)),
//                 pw.Divider(thickness: 0.5),
//                 // ✅ 'foods' used here in PDF
//                 ...foods.map((f) => pw.Padding(
//                       padding: const pw.EdgeInsets.only(top: 8),
//                       child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(f['food']!,
//                                 style: pw.TextStyle(
//                                     fontWeight: pw.FontWeight.bold,
//                                     fontSize: 11)),
//                             pw.Text(f['benefit']!,
//                                 style: const pw.TextStyle(fontSize: 10)),
//                           ]),
//                     )),

//                 pw.Spacer(),
//                 pw.Divider(),
//                 pw.Center(
//                     child: pw.Text(
//                         "This report is generated by AI and should be verified by a medical professional.",
//                         style: const pw.TextStyle(
//                             fontSize: 8, color: PdfColors.grey))),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     final output = await getTemporaryDirectory();
//     final file = File("${output.path}/HemoScan_Report_$reportId.pdf");
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final status = getStatusDetails();
//     final foods = getRecommendations(); // ✅ 'foods' used here in UI

//     return Scaffold(
//       backgroundColor: const Color(0xFFFBFDFF),
//       appBar: AppBar(
//         title: const Text("Scan Report",
//             style: TextStyle(
//                 color: Color(0xFF1A1C1E),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeaderInfo(),
//                 const SizedBox(height: 20),
//                 _buildResultCard(status),
//                 const SizedBox(height: 25),
//                 const Text("SYMPTOMS LOGGED",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF5E6368),
//                         fontSize: 11,
//                         letterSpacing: 1.2)),
//                 const SizedBox(height: 10),
//                 if (widget.selectedSymptoms.isEmpty)
//                   const Text("No symptoms reported.",
//                       style: TextStyle(color: Colors.grey, fontSize: 13)),
//                 ...widget.selectedSymptoms.map((s) => _buildSymptomRow(s)),
//                 const SizedBox(height: 25),
//                 const Text("RECOMMENDED DIET",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF5E6368),
//                         fontSize: 11,
//                         letterSpacing: 1.2)),
//                 const SizedBox(height: 10),
//                 ...foods.map((f) => _buildFoodItem(f)),
//                 const SizedBox(height: 30),
//                 _buildActionButtons(),
//               ],
//             ),
//           ),
//           _buildBottomNavbar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderInfo() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//           border: Border.all(color: Colors.blueGrey.shade50)),
//       child: Row(
//         children: [
//           CircleAvatar(
//               radius: 28,
//               backgroundColor: Colors.blue.shade50,
//               child: const Icon(Icons.person_rounded,
//                   color: Color(0xFF0D47A1), size: 30)),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(userName,
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A1C1E))),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     _buildInfoTag(
//                         userGender,
//                         userGender.toLowerCase() == 'female'
//                             ? Icons.female_rounded
//                             : Icons.male_rounded),
//                     const SizedBox(width: 8),
//                     _buildInfoTag(
//                         "$userAge Years", Icons.calendar_month_rounded),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Text("#$reportId",
//               style: TextStyle(
//                   color: Colors.grey.shade400,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoTag(String text, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//           color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         children: [
//           Icon(icon, size: 12, color: const Color(0xFF0D47A1)),
//           const SizedBox(width: 4),
//           Text(text,
//               style: const TextStyle(
//                   color: Color(0xFF44474E),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   Widget _buildSymptomRow(String text) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade100)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.check_circle_rounded,
//                   color: Colors.green, size: 18),
//               const SizedBox(width: 12),
//               Text(text,
//                   style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF1A1C1E),
//                       fontWeight: FontWeight.w500)),
//             ],
//           ),
//           const Text("YES",
//               style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w900,
//                   fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultCard(Map<String, dynamic> status) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 15)
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text("Hemoglobin Level",
//               style: TextStyle(color: Color(0xFF44474E), fontSize: 14)),
//           const SizedBox(height: 8),
//           RichText(
//             text: TextSpan(children: [
//               TextSpan(
//                   text: "${widget.finalHb}",
//                   style: const TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF001D3D))),
//               const TextSpan(
//                   text: " g/dL",
//                   style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.bold)),
//             ]),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//             decoration: BoxDecoration(
//                 color: status['bgColor'],
//                 borderRadius: BorderRadius.circular(12)),
//             child: Text(status['label'],
//                 style: TextStyle(
//                     color: status['color'], fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFoodItem(Map<String, String> data) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.blue.shade50)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(data['food']!,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
//         const SizedBox(height: 4),
//         Text(data['benefit']!,
//             style: const TextStyle(fontSize: 13, color: Color(0xFF44474E))),
//       ]),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         ElevatedButton.icon(
//           onPressed: () async {
//             File file = await _generatePdfFile();
//             await OpenFilex.open(file.path);
//           },
//           icon: const Icon(Icons.description_rounded, color: Colors.white),
//           label: const Text("Download PDF Report"),
//           style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D47A1),
//               foregroundColor: Colors.white,
//               minimumSize: const Size(double.infinity, 56),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16))),
//         ),
//         const SizedBox(height: 12),
//         OutlinedButton.icon(
//           onPressed: () async {
//             File file = await _generatePdfFile();
//             await Share.shareXFiles([XFile(file.path)],
//                 text: 'My HemoScan AI Report (#$reportId)');
//           },
//           icon: const Icon(Icons.share_rounded, color: Color(0xFF0D47A1)),
//           label: const Text("Share via WhatsApp / Mail"),
//           style: OutlinedButton.styleFrom(
//               foregroundColor: const Color(0xFF0D47A1),
//               side: const BorderSide(color: Color(0xFF0D47A1)),
//               minimumSize: const Size(double.infinity, 56),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16))),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomNavbar() {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
//         decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(24), topRight: Radius.circular(24))),
//         child: ElevatedButton(
//           onPressed: _isFinishing
//               ? null
//               : () async {
//                   setState(() => _isFinishing = true);
//                   await Future.delayed(const Duration(milliseconds: 600));
//                   if (mounted) {
//                     Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const MainNavigationScreen()),
//                         (r) => false);
//                   }
//                 },
//           style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF1F3F4),
//               foregroundColor: Colors.black87,
//               minimumSize: const Size(double.infinity, 54),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14))),
//           child: _isFinishing
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(strokeWidth: 2))
//               : const Text("Done & Back to Home",
//                   style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:io';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:hemoglobe_ai/main_navigation_screen.dart';
// import 'package:hemoglobe_ai/user_provider.dart';

// class ReportPreviewScreen extends StatefulWidget {
//   final double finalHb;
//   final List<String> selectedSymptoms;

//   const ReportPreviewScreen({
//     super.key,
//     required this.finalHb,
//     required this.selectedSymptoms,
//   });

//   @override
//   State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
// }

// class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
//   bool _isFinishing = false;
//   late String reportId;

//   String get userName => UserProvider.userName ?? "Guest User";
//   String get userAge => UserProvider.userAge ?? "N/A";
//   String get userGender => UserProvider.userGender ?? "N/A";

//   @override
//   void initState() {
//     super.initState();
//     reportId = (Random().nextInt(9000) + 1000).toString();
//   }

//   Map<String, dynamic> getStatusDetails() {
//     if (widget.finalHb < 8.0) {
//       return {
//         'label': 'SEVERE ANEMIA',
//         'color': Colors.red.shade700,
//         'bgColor': Colors.red.shade50,
//         'pdfColor': PdfColors.red900
//       };
//     } else if (widget.finalHb < 12.0) {
//       return {
//         'label': 'MODERATE ANEMIA',
//         'color': Colors.orange.shade800,
//         'bgColor': Colors.orange.shade50,
//         'pdfColor': PdfColors.orange900
//       };
//     } else {
//       return {
//         'label': 'NORMAL RANGE',
//         'color': Colors.green.shade700,
//         'bgColor': Colors.green.shade50,
//         'pdfColor': PdfColors.green900
//       };
//     }
//   }

//   List<Map<String, String>> getRecommendations() {
//     if (widget.finalHb < 12.0) {
//       return [
//         {
//           "food": "Spinach & Kale",
//           "benefit": "Rich in Iron and Folic acid.",
//           "precaution": "Cook properly."
//         },
//         {
//           "food": "Red Meat",
//           "benefit": "High heme-iron source.",
//           "precaution": "Limit if high BP."
//         },
//       ];
//     }
//     return [
//       {
//         "food": "Citrus Fruits",
//         "benefit": "Vitamin C helps iron absorption.",
//         "precaution": "Take with meals."
//       },
//       {
//         "food": "Nuts & Seeds",
//         "benefit": "Maintain healthy blood levels.",
//         "precaution": "Soak overnight."
//       },
//     ];
//   }

//   Future<File> _generatePdfFile() async {
//     final pdf = pw.Document();
//     final status = getStatusDetails();
//     final foods = getRecommendations();

//     pdf.addPage(
//       pw.Page(
//         pageFormat: PdfPageFormat.a4,
//         build: (pw.Context context) {
//           return pw.Padding(
//             padding: const pw.EdgeInsets.all(35),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Column(
//                         crossAxisAlignment: pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text("HemoScan AI",
//                               style: pw.TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: pw.FontWeight.bold,
//                                   color: PdfColors.blue900)),
//                           pw.Text("Smart Hemoglobin Assessment",
//                               style: const pw.TextStyle(
//                                   fontSize: 10, color: PdfColors.grey)),
//                         ]),
//                     pw.Text("Report ID: #$reportId",
//                         style: pw.TextStyle(
//                             fontSize: 12, fontWeight: pw.FontWeight.bold)),
//                   ],
//                 ),
//                 pw.SizedBox(height: 10),
//                 pw.Divider(thickness: 1.5, color: PdfColors.blue900),
//                 pw.SizedBox(height: 20),
//                 pw.Row(children: [
//                   pw.Expanded(
//                       child: pw.Text("Patient: $userName",
//                           style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
//                   pw.Expanded(child: pw.Text("Age: $userAge")),
//                   pw.Expanded(child: pw.Text("Gender: $userGender")),
//                 ]),
//                 pw.SizedBox(height: 30),
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(20),
//                   decoration: const pw.BoxDecoration(
//                       color: PdfColors.grey100,
//                       borderRadius:
//                           pw.BorderRadius.all(pw.Radius.circular(10))),
//                   child: pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text("HEMOGLOBIN LEVEL (Hb)",
//                           style: pw.TextStyle(
//                               fontWeight: pw.FontWeight.bold, fontSize: 14)),
//                       pw.Column(children: [
//                         pw.Text("${widget.finalHb} g/dL",
//                             style: pw.TextStyle(
//                                 fontSize: 22,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: status['pdfColor'])),
//                         pw.Text(status['label'],
//                             style: pw.TextStyle(
//                                 fontSize: 10,
//                                 fontWeight: pw.FontWeight.bold,
//                                 color: status['pdfColor'])),
//                       ]),
//                     ],
//                   ),
//                 ),
//                 pw.SizedBox(height: 30),
//                 pw.Text("SYMPTOMS LOGGED",
//                     style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold, fontSize: 12)),
//                 pw.Divider(thickness: 0.5),
//                 ...widget.selectedSymptoms.map((s) => pw.Padding(
//                       padding: const pw.EdgeInsets.symmetric(vertical: 4),
//                       child: pw.Row(
//                           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                           children: [
//                             pw.Text(s, style: const pw.TextStyle(fontSize: 11)),
//                             pw.Text("YES",
//                                 style: pw.TextStyle(
//                                     fontWeight: pw.FontWeight.bold,
//                                     color: PdfColors.green)),
//                           ]),
//                     )),
//                 pw.SizedBox(height: 30),
//                 pw.Text("DIETARY RECOMMENDATIONS",
//                     style: pw.TextStyle(
//                         fontWeight: pw.FontWeight.bold,
//                         fontSize: 12,
//                         color: PdfColors.blue800)),
//                 pw.Divider(thickness: 0.5),
//                 ...foods.map((f) => pw.Padding(
//                       padding: const pw.EdgeInsets.only(top: 8),
//                       child: pw.Column(
//                           crossAxisAlignment: pw.CrossAxisAlignment.start,
//                           children: [
//                             pw.Text(f['food']!,
//                                 style: pw.TextStyle(
//                                     fontWeight: pw.FontWeight.bold,
//                                     fontSize: 11)),
//                             pw.Text(f['benefit']!,
//                                 style: const pw.TextStyle(fontSize: 10)),
//                           ]),
//                     )),
//                 pw.Spacer(),
//                 pw.Divider(),
//                 pw.Center(
//                     child: pw.Text(
//                         "This report is generated by AI and should be verified by a medical professional.",
//                         style: const pw.TextStyle(
//                             fontSize: 8, color: PdfColors.grey))),
//               ],
//             ),
//           );
//         },
//       ),
//     );

//     final output = await getTemporaryDirectory();
//     final file = File("${output.path}/HemoScan_Report_$reportId.pdf");
//     await file.writeAsBytes(await pdf.save());
//     return file;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final status = getStatusDetails();
//     final foods = getRecommendations();

//     return Scaffold(
//       backgroundColor: const Color(0xFFFBFDFF),
//       appBar: AppBar(
//         title: const Text("Scan Report",
//             style: TextStyle(
//                 color: Color(0xFF1A1C1E),
//                 fontWeight: FontWeight.bold,
//                 fontSize: 18)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: Stack(
//         children: [
//           SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeaderInfo(),
//                 const SizedBox(height: 20),
//                 _buildResultCard(status),
//                 const SizedBox(height: 25),
//                 const Text("SYMPTOMS LOGGED",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF5E6368),
//                         fontSize: 11,
//                         letterSpacing: 1.2)),
//                 const SizedBox(height: 10),
//                 if (widget.selectedSymptoms.isEmpty)
//                   const Text("No symptoms reported.",
//                       style: TextStyle(color: Colors.grey, fontSize: 13)),
//                 ...widget.selectedSymptoms.map((s) => _buildSymptomRow(s)),
//                 const SizedBox(height: 25),
//                 const Text("RECOMMENDED DIET",
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF5E6368),
//                         fontSize: 11,
//                         letterSpacing: 1.2)),
//                 const SizedBox(height: 10),
//                 ...foods.map((f) => _buildFoodItem(f)),
//                 const SizedBox(height: 30),
//                 _buildActionButtons(),
//               ],
//             ),
//           ),
//           _buildBottomNavbar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeaderInfo() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//                 color: Colors.black.withOpacity(0.03),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4))
//           ],
//           border: Border.all(color: Colors.blueGrey.shade50)),
//       child: Row(
//         children: [
//           CircleAvatar(
//               radius: 28,
//               backgroundColor: Colors.blue.shade50,
//               child: const Icon(Icons.person_rounded,
//                   color: Color(0xFF0D47A1), size: 30)),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(userName,
//                     style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A1C1E))),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     _buildInfoTag(
//                         userGender,
//                         userGender.toLowerCase() == 'female'
//                             ? Icons.female_rounded
//                             : Icons.male_rounded),
//                     const SizedBox(width: 8),
//                     _buildInfoTag(
//                         "$userAge Years", Icons.calendar_month_rounded),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Text("#$reportId",
//               style: TextStyle(
//                   color: Colors.grey.shade400,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoTag(String text, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//           color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
//       child: Row(
//         children: [
//           Icon(icon, size: 12, color: const Color(0xFF0D47A1)),
//           const SizedBox(width: 4),
//           Text(text,
//               style: const TextStyle(
//                   color: Color(0xFF44474E),
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600)),
//         ],
//       ),
//     );
//   }

//   Widget _buildSymptomRow(String text) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.grey.shade100)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.check_circle_rounded,
//                   color: Colors.green, size: 18),
//               const SizedBox(width: 12),
//               Text(text,
//                   style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF1A1C1E),
//                       fontWeight: FontWeight.w500)),
//             ],
//           ),
//           const Text("YES",
//               style: TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w900,
//                   fontSize: 12)),
//         ],
//       ),
//     );
//   }

//   Widget _buildResultCard(Map<String, dynamic> status) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 15)
//         ],
//       ),
//       child: Column(
//         children: [
//           const Text("Hemoglobin Level",
//               style: TextStyle(color: Color(0xFF44474E), fontSize: 14)),
//           const SizedBox(height: 8),
//           RichText(
//             text: TextSpan(children: [
//               TextSpan(
//                   text: "${widget.finalHb}",
//                   style: const TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.w900,
//                       color: Color(0xFF001D3D))),
//               const TextSpan(
//                   text: " g/dL",
//                   style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.bold)),
//             ]),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
//             decoration: BoxDecoration(
//                 color: status['bgColor'],
//                 borderRadius: BorderRadius.circular(12)),
//             child: Text(status['label'],
//                 style: TextStyle(
//                     color: status['color'], fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFoodItem(Map<String, String> data) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.blue.shade50)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(data['food']!,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
//         const SizedBox(height: 4),
//         Text(data['benefit']!,
//             style: const TextStyle(fontSize: 13, color: Color(0xFF44474E))),
//       ]),
//     );
//   }

//   Widget _buildActionButtons() {
//     return Column(
//       children: [
//         ElevatedButton.icon(
//           onPressed: () async {
//             File file = await _generatePdfFile();
//             await OpenFilex.open(file.path);
//           },
//           icon: const Icon(Icons.description_rounded, color: Colors.white),
//           label: const Text("Download PDF Report"),
//           style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF0D47A1),
//               foregroundColor: Colors.white,
//               minimumSize: const Size(double.infinity, 56),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16))),
//         ),
//         const SizedBox(height: 12),
//         OutlinedButton.icon(
//           onPressed: () async {
//             File file = await _generatePdfFile();
//             await Share.shareXFiles([XFile(file.path)],
//                 text: 'My HemoScan AI Report (#$reportId)');
//           },
//           icon: const Icon(Icons.share_rounded, color: Color(0xFF0D47A1)),
//           label: const Text("Share via WhatsApp / Mail"),
//           style: OutlinedButton.styleFrom(
//               foregroundColor: const Color(0xFF0D47A1),
//               side: const BorderSide(color: Color(0xFF0D47A1)),
//               minimumSize: const Size(double.infinity, 56),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16))),
//         ),
//       ],
//     );
//   }

//   Widget _buildBottomNavbar() {
//     return Align(
//       alignment: Alignment.bottomCenter,
//       child: Container(
//         padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
//         decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(24), topRight: Radius.circular(24))),
//         child: ElevatedButton(
//           onPressed: _isFinishing
//               ? null
//               : () async {
//                   setState(() => _isFinishing = true);
//                   await Future.delayed(const Duration(milliseconds: 600));
//                   if (mounted) {
//                     Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const MainNavigationScreen()),
//                         (r) => false);
//                   }
//                 },
//           style: ElevatedButton.styleFrom(
//             // ✅ Button Color changed to Medical Success Green
//             backgroundColor: const Color(0xFF2E7D32),
//             foregroundColor: Colors.white,
//             minimumSize: const Size(double.infinity, 54),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//             elevation: 2,
//           ),
//           child: _isFinishing
//               ? const SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                       strokeWidth: 2, color: Colors.white))
//               : const Text("Finish",
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         ),
//       ),
//     );
//   }
// }

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import 'package:hemoglobe_ai/main_navigation_screen.dart';
import 'package:hemoglobe_ai/user_provider.dart';

class ReportPreviewScreen extends StatefulWidget {
  final double finalHb;
  final List<String> selectedSymptoms;

  const ReportPreviewScreen({
    super.key,
    required this.finalHb,
    required this.selectedSymptoms,
  });

  @override
  State<ReportPreviewScreen> createState() => _ReportPreviewScreenState();
}

class _ReportPreviewScreenState extends State<ReportPreviewScreen> {
  bool _isFinishing = false;
  late String reportId;

  String get userName => UserProvider.userName ?? "Guest User";
  String get userAge => UserProvider.userAge ?? "N/A";
  String get userGender => UserProvider.userGender ?? "N/A";

  @override
  void initState() {
    super.initState();
    reportId = (Random().nextInt(9000) + 1000).toString();
  }

  Map<String, dynamic> getStatusDetails() {
    if (widget.finalHb < 8.0) {
      return {
        'label': 'SEVERE ANEMIA',
        'color': Colors.red.shade700,
        'bgColor': Colors.red.shade50,
        'pdfColor': PdfColors.red900
      };
    } else if (widget.finalHb < 12.0) {
      return {
        'label': 'MODERATE ANEMIA',
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50,
        'pdfColor': PdfColors.orange900
      };
    } else {
      return {
        'label': 'NORMAL RANGE',
        'color': Colors.green.shade700,
        'bgColor': Colors.green.shade50,
        'pdfColor': PdfColors.green900
      };
    }
  }

  List<Map<String, String>> getRecommendations() {
    if (widget.finalHb < 12.0) {
      return [
        {
          "food": "Spinach & Kale",
          "benefit": "Rich in Iron and Folic acid.",
          "precaution": "Cook properly."
        },
        {
          "food": "Red Meat",
          "benefit": "High heme-iron source.",
          "precaution": "Limit if high BP."
        },
      ];
    }
    return [
      {
        "food": "Citrus Fruits",
        "benefit": "Vitamin C helps iron absorption.",
        "precaution": "Take with meals."
      },
      {
        "food": "Nuts & Seeds",
        "benefit": "Maintain healthy blood levels.",
        "precaution": "Soak overnight."
      },
    ];
  }

  Future<File> _generatePdfFile() async {
    final pdf = pw.Document();
    final status = getStatusDetails();
    final foods = getRecommendations();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(35),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("HemoScan AI",
                              style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blue900)),
                          pw.Text("Smart Hemoglobin Assessment",
                              style: const pw.TextStyle(
                                  fontSize: 10, color: PdfColors.grey)),
                        ]),
                    pw.Text("Report ID: #$reportId",
                        style: pw.TextStyle(
                            fontSize: 12, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1.5, color: PdfColors.blue900),
                pw.SizedBox(height: 20),
                pw.Row(children: [
                  pw.Expanded(
                      child: pw.Text("Patient: $userName",
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(child: pw.Text("Age: $userAge")),
                  pw.Expanded(child: pw.Text("Gender: $userGender")),
                ]),
                pw.SizedBox(height: 30),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius:
                          pw.BorderRadius.all(pw.Radius.circular(10))),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text("HEMOGLOBIN LEVEL (Hb)",
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 14)),
                      pw.Column(children: [
                        pw.Text("${widget.finalHb} g/dL",
                            style: pw.TextStyle(
                                fontSize: 22,
                                fontWeight: pw.FontWeight.bold,
                                color: status['pdfColor'])),
                        pw.Text(status['label'],
                            style: pw.TextStyle(
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: status['pdfColor'])),
                      ]),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Text("SYMPTOMS LOGGED",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Divider(thickness: 0.5),
                ...widget.selectedSymptoms.map((s) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 4),
                      child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(s, style: const pw.TextStyle(fontSize: 11)),
                            pw.Text("YES",
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.green)),
                          ]),
                    )),
                pw.SizedBox(height: 30),
                pw.Text("DIETARY RECOMMENDATIONS",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: PdfColors.blue800)),
                pw.Divider(thickness: 0.5),
                ...foods.map((f) => pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 8),
                      child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(f['food']!,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 11)),
                            pw.Text(f['benefit']!,
                                style: const pw.TextStyle(fontSize: 10)),
                          ]),
                    )),
                pw.Spacer(),
                pw.Divider(),
                pw.Center(
                    child: pw.Text(
                        "This report is generated by AI and should be verified by a medical professional.",
                        style: const pw.TextStyle(
                            fontSize: 8, color: PdfColors.grey))),
              ],
            ),
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/HemoScan_Report_$reportId.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final status = getStatusDetails();
    final foods = getRecommendations();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: AppBar(
        title: const Text("Scan Report",
            style: TextStyle(
                color: Color(0xFF1A1C1E),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderInfo(),
                const SizedBox(height: 20),
                _buildResultCard(status),
                const SizedBox(height: 25),
                const Text("SYMPTOMS LOGGED",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E6368),
                        fontSize: 11,
                        letterSpacing: 1.2)),
                const SizedBox(height: 10),
                if (widget.selectedSymptoms.isEmpty)
                  const Text("No symptoms reported.",
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ...widget.selectedSymptoms.map((s) => _buildSymptomRow(s)),
                const SizedBox(height: 25),
                const Text("RECOMMENDED DIET",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5E6368),
                        fontSize: 11,
                        letterSpacing: 1.2)),
                const SizedBox(height: 10),
                ...foods.map((f) => _buildFoodItem(f)),
                const SizedBox(height: 30),
                _buildActionButtons(),
              ],
            ),
          ),
          _buildBottomNavbar(),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
          border: Border.all(color: Colors.blueGrey.shade50)),
      child: Row(
        children: [
          CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue.shade50,
              child: const Icon(Icons.person_rounded,
                  color: Color(0xFF0D47A1), size: 30)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1C1E))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildInfoTag(
                        userGender,
                        userGender.toLowerCase() == 'female'
                            ? Icons.female_rounded
                            : Icons.male_rounded),
                    const SizedBox(width: 8),
                    _buildInfoTag(
                        "$userAge Years", Icons.calendar_month_rounded),
                  ],
                ),
              ],
            ),
          ),
          Text("#$reportId",
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: const Color(0xFF0D47A1)),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFF44474E),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildSymptomRow(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 18),
              const SizedBox(width: 12),
              Text(text,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1A1C1E),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const Text("YES",
              style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.blueGrey.withOpacity(0.05), blurRadius: 15)
        ],
      ),
      child: Column(
        children: [
          const Text("Hemoglobin Level",
              style: TextStyle(color: Color(0xFF44474E), fontSize: 14)),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "${widget.finalHb}",
                  style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF001D3D))),
              const TextSpan(
                  text: " g/dL",
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
                color: status['bgColor'],
                borderRadius: BorderRadius.circular(12)),
            child: Text(status['label'],
                style: TextStyle(
                    color: status['color'], fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(Map<String, String> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue.shade50)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(data['food']!,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 4),
        Text(data['benefit']!,
            style: const TextStyle(fontSize: 13, color: Color(0xFF44474E))),
      ]),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            File file = await _generatePdfFile();
            await OpenFilex.open(file.path);
          },
          icon: const Icon(Icons.description_rounded, color: Colors.white),
          label: const Text("Download PDF Report"),
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            File file = await _generatePdfFile();
            await Share.shareXFiles([XFile(file.path)],
                text: 'My HemoScan AI Report (#$reportId)');
          },
          icon: const Icon(Icons.share_rounded, color: Color(0xFF0D47A1)),
          label: const Text("Share via WhatsApp / Mail"),
          style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0D47A1),
              side: const BorderSide(color: Color(0xFF0D47A1)),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16))),
        ),
      ],
    );
  }

  Widget _buildBottomNavbar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24))),
        child: ElevatedButton(
          onPressed: _isFinishing
              ? null
              : () async {
                  setState(() => _isFinishing = true);
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainNavigationScreen()),
                        (r) => false);
                  }
                },
          style: ElevatedButton.styleFrom(
            // ✅ Updated to Vibrant Green
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isFinishing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text("Done & Back to Home",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}
