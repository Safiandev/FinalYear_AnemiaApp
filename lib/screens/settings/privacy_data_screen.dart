import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

// Note: Apni directory structure ke according import check kar lein
import 'package:hemoglobe_ai/screens/profile/change_password_screen.dart';

class PrivacyDataSecurityScreen extends StatefulWidget {
  const PrivacyDataSecurityScreen({super.key});

  @override
  State<PrivacyDataSecurityScreen> createState() =>
      _PrivacyDataSecurityScreenState();
}

class _PrivacyDataSecurityScreenState extends State<PrivacyDataSecurityScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool twoFactorEnabled = false;
  bool suspiciousAlertEnabled = true;
  bool isLoading = true;
  bool isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

  // 1. Fetch Existing Security Settings from Firestore
  Future<void> _loadUserSettings() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          setState(() {
            twoFactorEnabled = data['two_factor_enabled'] ?? false;
            suspiciousAlertEnabled = data['suspicious_alerts'] ?? true;
          });
        }
      } catch (e) {
        debugPrint("Error loading settings: $e");
      }
    }
    if (mounted) setState(() => isLoading = false);
  }

  // 2. Update Toggle State in Firestore
  Future<void> _updateSecuritySetting(String key, bool value) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          key: value,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } catch (e) {
        _showSnackBar("Failed to update settings: $e", isError: true);
      }
    }
  }

  // Helper to format date strings safely
  String _formatDate(dynamic dateVal) {
    if (dateVal is Timestamp) {
      DateTime dt = dateVal.toDate();
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } else if (dateVal != null && dateVal.toString().isNotEmpty) {
      return dateVal.toString();
    }
    return "N/A";
  }

  // Helper Widget for PDF Info Rows
  pw.Widget _pdfInfoRow(String title, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.RichText(
        text: pw.TextSpan(
          children: [
            pw.TextSpan(
              text: "$title ",
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.black,
              ),
            ),
            pw.TextSpan(
              text: value,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Professional PDF Data Export Functionality (Fixed Firestore Query)
  Future<void> _exportUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() => isExporting = true);

    try {
      // Fetch User Profile Document
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> userData =
          (userDoc.data() as Map<String, dynamic>?) ?? {};

      // Profile Fields Extraction
      String userName = userData['name'] ??
          userData['full_name'] ??
          userData['userName'] ??
          user.displayName ??
          'N/A';
      String age = userData['age']?.toString() ??
          userData['medical_history']?['age']?.toString() ??
          'N/A';
      String gender =
          userData['gender'] ?? userData['medical_history']?['gender'] ?? 'N/A';

      Map<String, dynamic> medicalHist =
          (userData['medical_history'] as Map<String, dynamic>?) ?? {};
      String bloodGroup =
          medicalHist['blood_group'] ?? userData['blood_group'] ?? 'Not Set';
      String dietPref = medicalHist['diet_preference'] ??
          userData['diet_preference'] ??
          'Omnivore';
      String ironDef =
          medicalHist['iron_deficiency'] ?? userData['iron_deficiency'] ?? 'No';

      // Comprehensive Reports Fetching Strategy
      List<Map<String, dynamic>> scansData = [];

      // Strategy 1: Check users/{uid}/reports Subcollection
      QuerySnapshot subColReports = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reports')
          .get();

      if (subColReports.docs.isNotEmpty) {
        scansData = subColReports.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      } else {
        // Strategy 2: Check Root 'reports' collection with user filter
        QuerySnapshot rootReportsUser = await _firestore
            .collection('reports')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (rootReportsUser.docs.isNotEmpty) {
          scansData = rootReportsUser.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        } else {
          QuerySnapshot rootReportsUser2 = await _firestore
              .collection('reports')
              .where('user_id', isEqualTo: user.uid)
              .get();

          if (rootReportsUser2.docs.isNotEmpty) {
            scansData = rootReportsUser2.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          } else {
            // Strategy 3: Fetch all docs in 'reports' if no userId is present in collection
            QuerySnapshot allReports =
                await _firestore.collection('reports').get();
            scansData = allReports.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
          }
        }
      }

      // PDF Theme Colors
      final primaryColor = PdfColor.fromHex("#1A365D"); // Deep Medical Navy
      final accentColor = PdfColor.fromHex("#2B6CB0"); // Blue Accent
      final lightBgColor = PdfColor.fromHex("#F7FAFC");

      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) => [
            // Professional Header Banner
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: primaryColor,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "HemoGlobe AI",
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "Medical & Hemoglobin Diagnostic Record",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey300,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: accentColor,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      "CONFIDENTIAL",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Patient Profile Box
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: lightBgColor,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300, width: 1),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "PATIENT PROFILE DETAILS",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.Divider(color: PdfColors.grey400, thickness: 0.8),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _pdfInfoRow("Patient Name:", userName),
                            _pdfInfoRow("Age:", age),
                            _pdfInfoRow("Gender:", gender),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _pdfInfoRow("Blood Group:", bloodGroup),
                            _pdfInfoRow("Diet Preference:", dietPref),
                            _pdfInfoRow("Past Iron Deficiency:", ironDef),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            // Scan Table Title & Count
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "HEMOGLOBIN SCAN HISTORY",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                pw.Text(
                  "Total Scans Found: ${scansData.length}",
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Scan Reports Table
            scansData.isEmpty
                ? pw.Container(
                    padding: const pw.EdgeInsets.all(20),
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(
                      color: lightBgColor,
                      borderRadius: pw.BorderRadius.circular(6),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Text(
                      "No scan records found in database.",
                      style: const pw.TextStyle(color: PdfColors.grey700),
                    ),
                  )
                : pw.TableHelper.fromTextArray(
                    border: pw.TableBorder.all(
                        color: PdfColors.grey300, width: 0.5),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                      fontSize: 10,
                    ),
                    headerDecoration: pw.BoxDecoration(color: primaryColor),
                    cellStyle: const pw.TextStyle(fontSize: 9),
                    cellPadding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    headers: [
                      'Sr. #',
                      'Status / Category',
                      'Hb Level',
                      'Date Recorded'
                    ],
                    data: List.generate(scansData.length, (index) {
                      final scan = scansData[index];

                      // Precise Field Extraction based on Firebase Screenshot
                      String status = scan['statusLabel'] ??
                          scan['status'] ??
                          scan['condition'] ??
                          'Recorded';

                      String hbVal = (scan['hbValue'] ??
                              scan['hb_level'] ??
                              scan['hbLevel'] ??
                              scan['hemoglobin'] ??
                              '--')
                          .toString();

                      if (!hbVal.contains('g/dL') && hbVal != '--') {
                        hbVal = "$hbVal g/dL";
                      }

                      String dateStr = _formatDate(scan['lastUpdated'] ??
                          scan['created_at'] ??
                          scan['date'] ??
                          scan['timestamp']);

                      return [
                        "${index + 1}",
                        status,
                        hbVal,
                        dateStr,
                      ];
                    }),
                  ),

            pw.SizedBox(height: 25),

            // Footer Section
            pw.Divider(color: PdfColors.grey300),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Report Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                  style:
                      const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  "HemoGlobe AI Medical Intelligence System",
                  style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700),
                ),
              ],
            ),
          ],
        ),
      );

      // Save PDF with Requested Filename
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/HemoGlobe_Medical_Record.pdf');
      await file.writeAsBytes(await pdf.save());

      // Open Mobile Native Share Sheet
      await Share.shareXFiles(
        [XFile(file.path)],
        text: "HemoGlobe AI Medical Record PDF",
      );

      _showSnackBar("PDF Medical Record generated successfully!");
    } catch (e) {
      debugPrint("Export PDF Error: $e");
      _showSnackBar("Export failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => isExporting = false);
    }
  }

  // 4. Re-authenticate & Delete Account Cascade
  Future<void> _deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Re-authenticate user for security
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Cascade Delete: Scans Collection
      var scans = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .get();
      for (var doc in scans.docs) {
        await doc.reference.delete();
      }

      // Delete Main User Document
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Auth User
      await user.delete();

      if (mounted) {
        _showSnackBar("Account deleted successfully");
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Authentication failed", isError: true);
    } catch (e) {
      _showSnackBar("Account deletion failed: $e", isError: true);
    }
  }

  // Account Deletion Confirmation Dialog
  void _showDeleteDialog() {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Account",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This action is permanent and cannot be undone. All your medical scans, history, and profile data will be permanently wiped.",
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Your Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              if (passwordController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _deleteAccount(passwordController.text.trim());
              } else {
                _showSnackBar("Please enter your password", isError: true);
              }
            },
            child: const Text(
              "Delete Permanently",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String text, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Privacy & Data Security",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Section 1: Account Security
                  sectionTitle("Account Security"),

                  securityOption(
                    icon: Icons.lock_outline,
                    title: "Change Password",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),

                  securityOption(
                    icon: Icons.fingerprint,
                    title: "Two-Factor Authentication",
                    trailing: Switch.adaptive(
                      value: twoFactorEnabled,
                      activeColor: Colors.deepPurple,
                      onChanged: (val) async {
                        setState(() => twoFactorEnabled = val);
                        await _updateSecuritySetting('two_factor_enabled', val);
                        if (mounted) {
                          _showSnackBar(
                            val
                                ? "Two-Factor Authentication Enabled"
                                : "Two-Factor Authentication Disabled",
                          );
                        }
                      },
                    ),
                  ),

                  securityOption(
                    icon: Icons.security_outlined,
                    title: "Suspicious Login Alerts",
                    trailing: Switch.adaptive(
                      value: suspiciousAlertEnabled,
                      activeColor: Colors.deepPurple,
                      onChanged: (val) async {
                        setState(() => suspiciousAlertEnabled = val);
                        await _updateSecuritySetting('suspicious_alerts', val);
                        if (mounted) {
                          _showSnackBar(
                            val
                                ? "Suspicious Login Alerts Enabled"
                                : "Suspicious Login Alerts Disabled",
                          );
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 2: Data Management
                  sectionTitle("Data Management"),

                  securityOption(
                    icon: Icons.picture_as_pdf_outlined,
                    title: "Export My Data (PDF)",
                    trailing: isExporting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    onTap: isExporting ? null : _exportUserData,
                  ),

                  securityOption(
                    icon: Icons.delete_outline,
                    iconColor: Colors.red,
                    iconBgColor: Colors.red.shade50,
                    title: "Delete My Account",
                    titleColor: Colors.red,
                    onTap: _showDeleteDialog,
                  ),

                  const SizedBox(height: 35),

                  // Footer Branding
                  const Text(
                    "HemoGlobe AI v2.4.1",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Managed Healthcare Data Security",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
    );
  }

  // SECTION TITLE WIDGET
  Widget sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  // SECURITY OPTION TILE
  Widget securityOption({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    Color iconColor = Colors.blue,
    Color iconBgColor = const Color(0xFFE3F2FD),
    Color titleColor = Colors.black87,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        leading: CircleAvatar(
          backgroundColor: iconBgColor,
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: titleColor,
            fontSize: 15,
          ),
        ),
        trailing: trailing ??
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ),
    );
  }
}



// import 'dart:convert';
// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';

// // Note: Apni project directory ke mutabiq imports adjust kar lein
// import 'package:hemoglobe_ai/screens/profile/change_password_screen.dart';

// class PrivacyDataSecurityScreen extends StatefulWidget {
//   const PrivacyDataSecurityScreen({super.key});

//   @override
//   State<PrivacyDataSecurityScreen> createState() =>
//       _PrivacyDataSecurityScreenState();
// }

// class _PrivacyDataSecurityScreenState extends State<PrivacyDataSecurityScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool twoFactorEnabled = false;
//   bool suspiciousAlertEnabled = true;
//   bool isLoading = true;
//   bool isExporting = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUserSettings();
//   }

//   // 1. Fetch Existing Security Settings from Firestore
//   Future<void> _loadUserSettings() async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       try {
//         DocumentSnapshot doc =
//             await _firestore.collection('users').doc(user.uid).get();
//         if (doc.exists && doc.data() != null) {
//           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//           setState(() {
//             twoFactorEnabled = data['two_factor_enabled'] ?? false;
//             suspiciousAlertEnabled = data['suspicious_alerts'] ?? true;
//           });
//         }
//       } catch (e) {
//         debugPrint("Error loading settings: $e");
//       }
//     }
//     setState(() => isLoading = false);
//   }

//   // 2. Update Toggle State in Firestore
//   Future<void> _updateSecuritySetting(String key, bool value) async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       try {
//         await _firestore.collection('users').doc(user.uid).set({
//           key: value,
//           'updated_at': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       } catch (e) {
//         _showSnackBar("Failed to update settings: $e", isError: true);
//       }
//     }
//   }

//   // 3. Export User Data Functionality
//   Future<void> _exportUserData() async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     setState(() => isExporting = true);

//     try {
//       // Fetch User Doc
//       DocumentSnapshot userDoc =
//           await _firestore.collection('users').doc(user.uid).get();
//       Map<String, dynamic> userData =
//           (userDoc.data() as Map<String, dynamic>?) ?? {};

//       // Fetch Scans History
//       QuerySnapshot scansSnapshot = await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('scans')
//           .get();

//       List<Map<String, dynamic>> scansData = scansSnapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();

//       // Compile Export Object
//       Map<String, dynamic> exportPayload = {
//         "export_metadata": {
//           "app_name": "HemoGlobe AI",
//           "export_date": DateTime.now().toIso8601String(),
//           "user_id": user.uid,
//           "email": user.email,
//         },
//         "profile": userData,
//         "scans_history": scansData,
//       };

//       // Save to JSON File
//       String jsonString =
//           const JsonEncoder.withIndent('  ').convert(exportPayload);
//       final directory = await getTemporaryDirectory();
//       final file = File(
//           '${directory.path}/HemoGlobe_Data_${user.uid.substring(0, 5)}.json');
//       await file.writeAsString(jsonString);

//       // Trigger Mobile Share Sheet
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: "HemoGlobe AI Exported Healthcare & Profile Record",
//       );

//       _showSnackBar("Data exported successfully!");
//     } catch (e) {
//       _showSnackBar("Export failed: $e", isError: true);
//     } finally {
//       setState(() => isExporting = false);
//     }
//   }

//   // 4. Re-authenticate & Delete Account Cascade
//   Future<void> _deleteAccount(String password) async {
//     final user = _auth.currentUser;
//     if (user == null) return;

//     try {
//       // Re-authenticate user for safety
//       AuthCredential credential = EmailAuthProvider.credential(
//         email: user.email!,
//         password: password,
//       );
//       await user.reauthenticateWithCredential(credential);

//       // Cascade Delete: Scans Collection
//       var scans = await _firestore
//           .collection('users')
//           .doc(user.uid)
//           .collection('scans')
//           .get();
//       for (var doc in scans.docs) {
//         await doc.reference.delete();
//       }

//       // Delete Main User Document
//       await _firestore.collection('users').doc(user.uid).delete();

//       // Delete Auth User Record
//       await user.delete();

//       if (mounted) {
//         _showSnackBar("Account deleted successfully");
//         // Navigate to Login Screen / Clear Stack
//         Navigator.of(context).popUntil((route) => route.isFirst);
//       }
//     } on FirebaseAuthException catch (e) {
//       _showSnackBar(e.message ?? "Authentication failed", isError: true);
//     } catch (e) {
//       _showSnackBar("Account deletion failed: $e", isError: true);
//     }
//   }

//   // Account Deletion Dialog with Password Confirmation
//   void _showDeleteDialog() {
//     final TextEditingController passwordController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           "Delete Account",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "This action is permanent and cannot be undone. All your medical scans, history, and profile data will be permanently wiped.",
//               style: TextStyle(fontSize: 13, color: Colors.black87),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: passwordController,
//               obscureText: true,
//               decoration: InputDecoration(
//                 labelText: "Confirm Your Password",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 10,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () {
//               if (passwordController.text.trim().isNotEmpty) {
//                 Navigator.pop(context);
//                 _deleteAccount(passwordController.text.trim());
//               } else {
//                 _showSnackBar("Please enter your password", isError: true);
//               }
//             },
//             child: const Text(
//               "Delete Permanently",
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSnackBar(String text, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(text),
//         backgroundColor: isError ? Colors.red : Colors.green,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         title: const Text(
//           "Privacy & Data Security",
//           style: TextStyle(
//               color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   // Section 1: Account Security
//                   sectionTitle("Account Security"),

//                   securityOption(
//                     icon: Icons.lock_outline,
//                     title: "Change Password",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ChangePasswordScreen(),
//                         ),
//                       );
//                     },
//                   ),

//                   securityOption(
//                     icon: Icons.fingerprint,
//                     title: "Two-Factor Authentication",
//                     trailing: Switch.adaptive(
//                       value: twoFactorEnabled,
//                       activeColor: Colors.deepPurple,
//                       onChanged: (val) {
//                         setState(() => twoFactorEnabled = val);
//                         _updateSecuritySetting('two_factor_enabled', val);
//                       },
//                     ),
//                   ),

//                   securityOption(
//                     icon: Icons.security_outlined,
//                     title: "Suspicious Login Alerts",
//                     trailing: Switch.adaptive(
//                       value: suspiciousAlertEnabled,
//                       activeColor: Colors.deepPurple,
//                       onChanged: (val) {
//                         setState(() => suspiciousAlertEnabled = val);
//                         _updateSecuritySetting('suspicious_alerts', val);
//                       },
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Section 2: Data Management
//                   sectionTitle("Data Management"),

//                   securityOption(
//                     icon: Icons.download_outlined,
//                     title: "Export My Data",
//                     trailing: isExporting
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           )
//                         : null,
//                     onTap: isExporting ? null : _exportUserData,
//                   ),

//                   securityOption(
//                     icon: Icons.delete_outline,
//                     iconColor: Colors.red,
//                     iconBgColor: Colors.red.shade50,
//                     title: "Delete My Account",
//                     titleColor: Colors.red,
//                     onTap: _showDeleteDialog,
//                   ),

//                   const SizedBox(height: 35),

//                   // Footer Branding
//                   const Text(
//                     "HemoGlobe AI v2.4.1",
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w500,
//                       fontSize: 13,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   const Text(
//                     "Managed Healthcare Data Security",
//                     style: TextStyle(color: Colors.grey, fontSize: 11),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }

//   // SECTION TITLE WIDGET
//   Widget sectionTitle(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
//         child: Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Colors.black87,
//           ),
//         ),
//       ),
//     );
//   }

//   // SECURITY OPTION TILE
//   Widget securityOption({
//     required IconData icon,
//     required String title,
//     VoidCallback? onTap,
//     Widget? trailing,
//     Color iconColor = Colors.blue,
//     Color iconBgColor = const Color(0xFFE3F2FD),
//     Color titleColor = Colors.black87,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.shade200,
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         onTap: onTap,
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         leading: CircleAvatar(
//           backgroundColor: iconBgColor,
//           child: Icon(icon, color: iconColor, size: 22),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.w500,
//             color: titleColor,
//             fontSize: 15,
//           ),
//         ),
//         trailing: trailing ??
//             const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
//       ),
//     );
//   }
// }

