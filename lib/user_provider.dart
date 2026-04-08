import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider {
  static String? userId; // ✅ Added for Firestore Mapping
  static String? userName;
  static String? userEmail;
  static String? userAge;
  static String? userGender;
  static bool isDataLoaded = false;

  // ✅ 1. Login Screen isay call karegi (Error Fix)
  static void setUser(String id, String name) {
    userId = id;
    userName = name;
    debugPrint("✅ UserProvider: User Logged In (ID: $id, Name: $name)");
  }

  // ✅ 2. Firestore se data load karne ke liye
  static Future<void> initUserData() async {
    if (isDataLoaded && userName != null) return;

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid; // Save UID
        userEmail = user.email;

        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          var data = doc.data() as Map<String, dynamic>;
          userName = data['name'] ?? "User";
          userAge = data['age']?.toString() ?? "";
          userGender = data['gender'] ?? "";
          isDataLoaded = true;
          debugPrint("✅ UserProvider: Data Loaded from Firestore");
        }
      }
    } catch (e) {
      debugPrint("❌ Error loading data: $e");
    }
  }

  // ✅ 3. Update karne ke liye (Profile editing etc.)
  static void updateAllData({String? name, String? age, String? gender}) {
    if (name != null) userName = name;
    if (age != null) userAge = age;
    if (gender != null) userGender = gender;
  }

  // ✅ 4. Logout ke liye
  static void clearData() {
    userId = null;
    userName = null;
    userEmail = null;
    userAge = null;
    userGender = null;
    isDataLoaded = false;
    debugPrint("✅ UserProvider: Data Cleared");
  }
}
