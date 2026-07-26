import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // base64Encode/base64Decode ke liye
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hemoglobe_ai/user_provider.dart';
import 'package:hemoglobe_ai/screens/auth/login_screen.dart';

import 'package:hemoglobe_ai/screens/profile/personal_info_screen.dart';
import 'package:hemoglobe_ai/screens/help/help_support_screen.dart';
import 'package:hemoglobe_ai/screens/settings/notification_preferences_screen.dart';
import 'package:hemoglobe_ai/screens/settings/privacy_data_screen.dart';
import 'package:hemoglobe_ai/screens/dashboard/medical_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _imageBytes;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

 // ------------------- PICK IMAGE -------------------
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _isUploading = true;
        });

        final user = _auth.currentUser;
        if (user != null) {
          // Image ko base64 string mein convert karein (Firestore mein save hoga)
          String base64Image = base64Encode(bytes);

          // Firestore + SharedPreferences update — Firebase Storage bilkul use nahi horaha
          await UserProvider.updatePhotoBase64(base64Image);

          debugPrint("✅ Photo base64 saved successfully (${bytes.length} bytes)");
        }
      } // ← YE BRACE MISSING THA (if (pickedFile != null) ko close karta hai)
    } catch (e) {
      debugPrint("Pick Error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }



 ImageProvider _getProfileImage() {
    // 1. Freshly Picked Image (turant preview ke liye)
    if (_imageBytes != null) return MemoryImage(_imageBytes!);

    // 2. UserProvider mein saved base64 image (Firestore + SharedPreferences se)
    if (UserProvider.userPhotoBase64 != null &&
        UserProvider.userPhotoBase64!.trim().isNotEmpty) {
      try {
        return MemoryImage(base64Decode(UserProvider.userPhotoBase64!));
      } catch (e) {
        debugPrint("Base64 decode error: $e");
      }
    }

    // 3. ✅ Default Avatar Fallback
    return const AssetImage('assets/default_avatar2.jpeg');
  }

  @override
  Widget build(BuildContext context) {
    String name = UserProvider.userName ?? "User Name";
    String email = UserProvider.userEmail ?? "No Email Found";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Column(
          children: [
            // --- USER HEADER CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.indigo.shade100,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 52,
                          backgroundColor: Colors.indigo.shade50,
                          backgroundImage: _getProfileImage(),
                          child: _isUploading
                              ? const CircularProgressIndicator(
                                  color: Colors.indigo)
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: InkWell(
                          onTap: _showImagePickerOptions,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- ACCOUNT & HEALTH SECTION ---
            _sectionHeader("Account & Health"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _profileTile(
                    icon: Icons.person_outline_rounded,
                    title: "Personal Information",
                    subtitle: "Manage your personal profile details",
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                  _profileTile(
                    icon: Icons.assignment_outlined,
                    title: "Medical History",
                    subtitle: "View clinical and lab assessment logs",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MedicalHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- SECURITY & PREFERENCES ---
            _sectionHeader("Security & Preferences"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _profileTile(
                    icon: Icons.security_rounded,
                    title: "Privacy & Data Security",
                    subtitle: "Control data usage and encryption settings",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const PrivacyDataSecurityScreen(),
                        ),
                      );
                    },
                  ),
                  Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
                  _profileTile(
                    icon: Icons.notifications_none_rounded,
                    title: "Notification Preferences",
                    subtitle: "Configure alerts and push updates",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationPreferencesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- HELP SECTION ---
            _sectionHeader("Help & Assistance"),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _profileTile(
                icon: Icons.help_outline_rounded,
                title: "Help & Support",
                subtitle: "FAQs, contact support, and app guide",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 28),

            // LOGOUT BUTTON
            _logoutButton(context),

            const SizedBox(height: 20),
            Text(
              "HemaScan AI v2.4.1",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---
  Widget _sectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.grey.shade800,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.indigo, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Colors.grey.shade400,
        size: 22,
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      color: Colors.blue, size: 20),
                ),
                title: const Text("Take Photo",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded,
                      color: Colors.purple, size: 20),
                ),
                title: const Text("Choose from Gallery",
                    style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                "Logout Account",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to logout from your account?",
            style:
                TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _handleLogout();
              },
              child: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      UserProvider.clearData();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
      debugPrint("✅ Logout Successful");
    } catch (e) {
      debugPrint("❌ Logout Error: $e");
    }
  }

  Widget _logoutButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.shade50.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                "Logout Account",
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hemoglobe_ai/user_provider.dart';
// import 'package:hemoglobe_ai/screens/auth/login_screen.dart';

// // ✅ Clean Imports
// import 'package:hemoglobe_ai/screens/profile/personal_info_screen.dart';
// import 'package:hemoglobe_ai/screens/help/help_support_screen.dart';
// import 'package:hemoglobe_ai/screens/settings/notification_preferences_screen.dart';
// import 'package:hemoglobe_ai/screens/settings/privacy_data_screen.dart';
// import 'package:hemoglobe_ai/screens/dashboard/medical_history_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   Uint8List? _imageBytes;
//   final ImagePicker _picker = ImagePicker();
//   bool _isUploading = false;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // ------------------- PICK IMAGE -------------------
//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? pickedFile = await _picker.pickImage(
//         source: source,
//         maxWidth: 500,
//         maxHeight: 500,
//         imageQuality: 80,
//       );

//       if (pickedFile != null) {
//         final bytes = await pickedFile.readAsBytes();
//         setState(() {
//           _imageBytes = bytes;
//           _isUploading = true;
//         });

//         if (_auth.currentUser != null) {
//           String downloadUrl = await _uploadToFirebase(bytes, pickedFile.name);
//           if (downloadUrl.isNotEmpty) {
//             // 1. Firebase Auth update
//             await _auth.currentUser?.updatePhotoURL(downloadUrl);
//             await _auth.currentUser?.reload();

//             // 2. ✅ FIX: Save to Firestore & Update Provider Memory Globally
//             await UserProvider.updatePhotoUrl(downloadUrl);

//             if (mounted) {
//               setState(() {
//                 _imageBytes =
//                     null; // Memory bytes clear karden, ab URL memory se load hoga
//               });
//             }
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint("Pick Error: $e");
//     } finally {
//       if (mounted) setState(() => _isUploading = false);
//     }
//   }

//   // ------------------- UPLOAD TO FIREBASE -------------------
//   Future<String> _uploadToFirebase(Uint8List bytes, String fileName) async {
//     try {
//       String uid = _auth.currentUser?.uid ?? "guest_user";
//       final storageRef = FirebaseStorage.instance.ref().child(
//             'profile_images/$uid.jpg',
//           );

//       final uploadTask = storageRef.putData(
//         bytes,
//         SettableMetadata(contentType: 'image/jpeg'),
//       );
//       final snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       debugPrint("Upload Error: $e");
//       return "";
//     }
//   }

//   // ------------------- IMAGE PROVIDER -------------------
//   ImageProvider _getProfileImage() {
//     // 1. Agar abhi instantly picked hui image memory me hai
//     if (_imageBytes != null) return MemoryImage(_imageBytes!);

//     // 2. Check UserProvider (Screen swap karne ke baad bhi ye URL save rahega)
//     if (UserProvider.userPhotoUrl != null &&
//         UserProvider.userPhotoUrl!.isNotEmpty) {
//       return NetworkImage(UserProvider.userPhotoUrl!);
//     }

//     // 3. Check Firebase Auth current user
//     final user = _auth.currentUser;
//     if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
//       // Persistent backup sync
//       UserProvider.userPhotoUrl = user.photoURL;
//       return NetworkImage(user.photoURL!);
//     }

//     // 4. Default Fallback
//     return const AssetImage('assets/images/default_avatar.jpeg');
//   }

//   @override
//   Widget build(BuildContext context) {
//     String name = UserProvider.userName ?? "User Name";
//     String email = UserProvider.userEmail ?? "No Email Found";

//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text(
//           "Profile",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
//         child: Column(
//           children: [
//             // --- USER HEADER CARD ---
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.03),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Stack(
//                     alignment: Alignment.bottomRight,
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(3),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: Colors.indigo.shade100,
//                             width: 2,
//                           ),
//                         ),
//                         child: CircleAvatar(
//                           radius: 52,
//                           backgroundColor: Colors.indigo.shade50,
//                           backgroundImage: _getProfileImage(),
//                           child: _isUploading
//                               ? const CircularProgressIndicator(
//                                   color: Colors.indigo)
//                               : null,
//                         ),
//                       ),
//                       Positioned(
//                         right: 2,
//                         bottom: 2,
//                         child: InkWell(
//                           onTap: _showImagePickerOptions,
//                           borderRadius: BorderRadius.circular(20),
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.indigo,
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: Colors.white,
//                                 width: 2,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.indigo.withOpacity(0.3),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 2),
//                                 )
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.camera_alt_rounded,
//                               color: Colors.white,
//                               size: 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 14),
//                   Text(
//                     name,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black87,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     email,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey.shade600,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 24),

//             // --- ACCOUNT & HEALTH SECTION ---
//             _sectionHeader("Account & Health"),
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Column(
//                 children: [
//                   _profileTile(
//                     icon: Icons.person_outline_rounded,
//                     title: "Personal Information",
//                     subtitle: "Manage your personal profile details",
//                     onTap: () async {
//                       await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const PersonalInfoScreen(),
//                         ),
//                       );
//                       if (mounted) {
//                         setState(() {});
//                       }
//                     },
//                   ),
//                   Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
//                   _profileTile(
//                     icon: Icons.assignment_outlined,
//                     title: "Medical History",
//                     subtitle: "View clinical and lab assessment logs",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const MedicalHistoryScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // --- SECURITY & PREFERENCES ---
//             _sectionHeader("Security & Preferences"),
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: Column(
//                 children: [
//                   _profileTile(
//                     icon: Icons.security_rounded,
//                     title: "Privacy & Data Security",
//                     subtitle: "Control data usage and encryption settings",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const PrivacyDataSecurityScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                   Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
//                   _profileTile(
//                     icon: Icons.notifications_none_rounded,
//                     title: "Notification Preferences",
//                     subtitle: "Configure alerts and push updates",
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               const NotificationPreferencesScreen(),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // --- HELP SECTION ---
//             _sectionHeader("Help & Assistance"),
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(color: Colors.grey.shade200),
//               ),
//               child: _profileTile(
//                 icon: Icons.help_outline_rounded,
//                 title: "Help & Support",
//                 subtitle: "FAQs, contact support, and app guide",
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const HelpSupportScreen(),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             const SizedBox(height: 28),

//             // LOGOUT BUTTON
//             _logoutButton(context),

//             const SizedBox(height: 20),
//             Text(
//               "HemaScan AI v2.4.1",
//               style: TextStyle(
//                 color: Colors.grey.shade500,
//                 fontSize: 12,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   // --- UI HELPER WIDGETS ---
//   Widget _sectionHeader(String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 4, bottom: 8),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 15,
//             color: Colors.grey.shade800,
//             letterSpacing: 0.1,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _profileTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       onTap: onTap,
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       leading: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.indigo.shade50,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(icon, color: Colors.indigo, size: 22),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 15,
//           color: Colors.black87,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           fontSize: 12,
//           color: Colors.grey.shade600,
//         ),
//       ),
//       trailing: Icon(
//         Icons.chevron_right_rounded,
//         color: Colors.grey.shade400,
//         size: 22,
//       ),
//     );
//   }

//   void _showImagePickerOptions() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       builder: (context) => SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           child: Wrap(
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.blue.shade50,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.camera_alt_rounded,
//                       color: Colors.blue, size: 20),
//                 ),
//                 title: const Text("Take Photo",
//                     style: TextStyle(fontWeight: FontWeight.w600)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.camera);
//                 },
//               ),
//               ListTile(
//                 leading: Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: Colors.purple.shade50,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.photo_library_rounded,
//                       color: Colors.purple, size: 20),
//                 ),
//                 title: const Text("Choose from Gallery",
//                     style: TextStyle(fontWeight: FontWeight.w600)),
//                 onTap: () {
//                   Navigator.pop(context);
//                   _pickImage(ImageSource.gallery);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // --- LOGOUT CONFIRMATION DIALOG ---
//   void _showLogoutDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           backgroundColor: Colors.white,
//           title: const Row(
//             children: [
//               Icon(Icons.logout_rounded, color: Colors.redAccent),
//               SizedBox(width: 10),
//               Text(
//                 "Logout Account",
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//             ],
//           ),
//           content: Text(
//             "Are you sure you want to logout from your account?",
//             style:
//                 TextStyle(color: Colors.black.withOpacity(0.7), fontSize: 14),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 "Cancel",
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 elevation: 0,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.pop(context);
//                 _handleLogout();
//               },
//               child: const Text(
//                 "Logout",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // --- ACTUAL LOGOUT LOGIC ---
//   Future<void> _handleLogout() async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       UserProvider.clearData();
//       if (mounted) {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//           (route) => false,
//         );
//       }
//       debugPrint("✅ Logout Successful");
//     } catch (e) {
//       debugPrint("❌ Logout Error: $e");
//     }
//   }

//   Widget _logoutButton(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _showLogoutDialog(),
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(vertical: 14),
//           decoration: BoxDecoration(
//             color: Colors.red.shade50.withOpacity(0.6),
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.red.shade200, width: 1),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.logout_rounded, color: Colors.red.shade700, size: 20),
//               const SizedBox(width: 8),
//               Text(
//                 "Logout Account",
//                 style: TextStyle(
//                   color: Colors.red.shade700,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


