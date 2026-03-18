import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hemoglobe_ai/user_provider.dart';

// ✅ SARE IMPORTS ADD KAR DIYE HAIN (Rasta/Path check kar lena)
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

        if (_auth.currentUser != null) {
          String downloadUrl = await _uploadToFirebase(bytes, pickedFile.name);
          if (downloadUrl.isNotEmpty) {
            await _auth.currentUser?.updatePhotoURL(downloadUrl);
            await _auth.currentUser?.reload();
          }
        }
      }
    } catch (e) {
      debugPrint("Pick Error: $e");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // ------------------- UPLOAD TO FIREBASE -------------------
  Future<String> _uploadToFirebase(Uint8List bytes, String fileName) async {
    try {
      String uid = _auth.currentUser?.uid ?? "guest_user";
      final storageRef = FirebaseStorage.instance.ref().child(
            'profile_images/$uid.jpg',
          );

      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Upload Error: $e");
      return "";
    }
  }

  // ------------------- IMAGE PROVIDER -------------------
  ImageProvider _getProfileImage() {
    if (_imageBytes != null) return MemoryImage(_imageBytes!);
    final user = _auth.currentUser;
    if (user != null && user.photoURL != null && user.photoURL!.isNotEmpty) {
      return NetworkImage(user.photoURL!);
    }
    return const NetworkImage("https://i.pravatar.cc/150?img=5");
  }

  @override
  Widget build(BuildContext context) {
    String name = UserProvider.userName ?? "User Name";
    String email = UserProvider.userEmail ?? "No Email Found";

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- PROFILE IMAGE ---
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: _getProfileImage(),
                  child:
                      _isUploading ? const CircularProgressIndicator() : null,
                ),
                InkWell(
                  onTap: _showImagePickerOptions,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              email,
              style: const TextStyle(color: Colors.blueGrey),
            ),

            const SizedBox(height: 30),

            // --- ACCOUNT & HEALTH ---
            _sectionTitle("Account & Health"),
            _profileTile(Icons.person, "Personal Information", () async {
              // ✅ Hum 'await' lagayenge taake jab user save kar ke wapis aaye toh agli line chale
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonalInfoScreen()));

              // ✅ Jab Navigator.pop hoga, toh ye niche wali line chalay gi aur screen refresh ho jayegi
              if (mounted) {
                setState(() {
                  // Is empty setState se Flutter screen ko re-draw karega
                  // aur UserProvider se naya data utha lega.
                });
              }
            }),
            _profileTile(Icons.description, "Medical History", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MedicalHistoryScreen()));
            }),

            const SizedBox(height: 20),

            // --- SECURITY & PREFERENCES ---
            _sectionTitle("Security & Preferences"),
            _profileTile(Icons.shield, "Privacy & Data Security", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyDataSecurityScreen()));
            }),
            _profileTile(Icons.notifications, "Notification Preferences", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const NotificationPreferencesScreen()));
            }),

            const SizedBox(height: 20),

            // --- HELP SECTION ---
            _sectionTitle("Help"),
            _profileTile(Icons.help_outline, "Help & Support", () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HelpSupportScreen()));
            }),

            const SizedBox(height: 30),

            _logoutButton(),

            const SizedBox(height: 20),
            const Text(
              "HemaScan AI v2.4.1",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _profileTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: onTap, // ✅ NAVIGATION AB KAAM KAREGI
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _logoutButton() {
    return InkWell(
      onTap: () async {
        await _auth.signOut();
        UserProvider.clearData();
        // Navigator logic yahan login screen ke liye dal dena
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
