import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider {
  static String? userName;
  static String? userEmail;
  static String? userAge;
  static String? userGender;
  static bool isDataLoaded = false;

  static Future<void> initUserData() async {
    if (isDataLoaded && userName != null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userEmail = user.email;
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          var data = doc.data() as Map<String, dynamic>;
          userName = data['name'] ?? "User";
          userAge = data['age']?.toString() ?? ""; // Age fetch
          userGender = data['gender'] ?? ""; // Gender fetch
          isDataLoaded = true;
        }
      }
    } catch (e) {
      print("❌ Error loading data: $e");
    }
  }

  // ✅ Sab kuch update karne ke liye function
  static void updateAllData({String? name, String? age, String? gender}) {
    if (name != null) userName = name;
    if (age != null) userAge = age;
    if (gender != null) userGender = gender;
  }

  static void clearData() {
    userName = null;
    userEmail = null;
    userAge = null;
    userGender = null;
    isDataLoaded = false;
  }
}
