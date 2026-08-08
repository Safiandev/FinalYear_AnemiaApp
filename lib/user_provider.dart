import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider {
  static String? userId;
  static String? userName;
  static String? userEmail;
  static String? userAge;
  static String? userGender;
  static String? userPhotoBase64;

  static final ValueNotifier<String?> photoNotifier =
      ValueNotifier<String?>(null);
  static bool isDataLoaded = false;

  // ✅ Completed reports list for Dashboard Graph & Analytics
  static List<Map<String, dynamic>> userReports = [];

  // ✅ Getter to safely verify login state across app
  static bool get isLoggedIn =>
      FirebaseAuth.instance.currentUser != null || userId != null;

  // ✅ Login logic
  static void setUser(String id, String name) {
    if (userId != id) {
      // Different user login -> reset existing loaded flags
      isDataLoaded = false;
    }
    userId = id;
    userName = name;
    debugPrint("✅ UserProvider: User Logged In (ID: $id, Name: $name)");
  }

  static Future<void> loadLocalPhotoBase64() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedBase64 = prefs.getString('saved_user_photo_base64');
      if (savedBase64 != null && savedBase64.trim().isNotEmpty) {
        userPhotoBase64 = savedBase64;
        photoNotifier.value = savedBase64;
        debugPrint("✅ Loaded photo (base64) from SharedPreferences");
      }
    } catch (e) {
      debugPrint("❌ Error reading photo base64 from SharedPreferences: $e");
    }
  }

  // ✅ Firestore se user profile aur reports load karne ka method
  static Future<void> initUserData({bool forceRefresh = false}) async {
    // Step A: Immediate Local Storage Read
    await loadLocalPhotoBase64();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("⚠️ UserProvider: No authenticated Firebase user found.");
      return;
    }

    userId = user.uid;
    userEmail = user.email;

    if (!forceRefresh && isDataLoaded && userPhotoBase64 != null) return;

    try {
      // 1. Fetch User Profile from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        userName = data['name'] ?? userName ?? "User";
        userAge = data['age']?.toString() ?? userAge ?? "";
        userGender = data['gender'] ?? userGender ?? "";

        String? fetchedPhoto = data['photoBase64'];

        if (fetchedPhoto != null && fetchedPhoto.trim().isNotEmpty) {
          userPhotoBase64 = fetchedPhoto;
          photoNotifier.value = fetchedPhoto;

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_user_photo_base64', fetchedPhoto);
        }

        isDataLoaded = true;
        debugPrint(
            "✅ UserProvider: Profile & Photo Loaded (base64 length: ${userPhotoBase64?.length ?? 0})");
      }

      // 2. Fetch User Reports (Safe query handling)
      try {
        QuerySnapshot reportsSnapshot = await FirebaseFirestore.instance
            .collection('reports')
            .where('userId', isEqualTo: user.uid)
            .where('isCompleted', isEqualTo: true)
            .get();

        List<Map<String, dynamic>> fetchedList = reportsSnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        // In-memory sort by timestamp to prevent composite index crash if index is missing in Firebase console
        fetchedList.sort((a, b) {
          Timestamp? tA = a['timestamp'] as Timestamp?;
          Timestamp? tB = b['timestamp'] as Timestamp?;
          if (tA == null) return -1;
          if (tB == null) return 1;
          return tA.compareTo(tB);
        });

        userReports = fetchedList;
        debugPrint(
            "✅ UserProvider: ${userReports.length} Completed Reports Loaded");
      } catch (e) {
        debugPrint("❌ Error querying user reports: $e");
      }
    } catch (e) {
      debugPrint("❌ Error loading data in UserProvider: $e");
    }
  }

  // ✅ Instant in-memory sync for new tests
  static void addReport(Map<String, dynamic> newReport) {
    if (newReport['isCompleted'] == true) {
      userReports.add(newReport);
    }
  }

  // ✅ Profile update
  static void updateAllData({String? name, String? age, String? gender}) {
    if (name != null) userName = name;
    if (age != null) userAge = age;
    if (gender != null) userGender = gender;
  }

  // ✅ Photo Base64 update & persistence
  static Future<void> updatePhotoBase64(String newBase64) async {
    userPhotoBase64 = newBase64;
    photoNotifier.value = newBase64;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_user_photo_base64', newBase64);
    } catch (e) {
      debugPrint("❌ Error saving photo base64 to SharedPreferences: $e");
    }

    User? user = FirebaseAuth.instance.currentUser;
    String? currentUid = userId ?? user?.uid;

    if (currentUid != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUid)
            .set({'photoBase64': newBase64}, SetOptions(merge: true));

        debugPrint(
            "✅ UserProvider & Local/Firestore Photo updated successfully");
      } catch (e) {
        debugPrint("❌ Error updating photo base64 in Firestore: $e");
      }
    }
  }

  // ✅ Logout & Clear logic
  static Future<void> clearData() async {
    userId = null;
    userName = null;
    userEmail = null;
    userAge = null;
    userGender = null;
    userPhotoBase64 = null;
    photoNotifier.value = null;
    userReports = [];
    isDataLoaded = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_user_photo_base64');
    } catch (e) {
      debugPrint("❌ Error clearing local preferences: $e");
    }

    debugPrint("✅ UserProvider: Data & Local Photo Cleared");
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserProvider {
//   static String? userId;
//   static String? userName;
//   static String? userEmail;
//   static String? userAge;
//   static String? userGender;
//   static String? userPhotoBase64;
//    static final ValueNotifier<String?> photoNotifier = ValueNotifier<String?>(null);
//   static bool isDataLoaded = false;

//   // ✅ Completed reports list for Dashboard Graph & Analytics
//   static List<Map<String, dynamic>> userReports = [];

//   // ✅ Login logic
//   static void setUser(String id, String name) {
//     userId = id;
//     userName = name;
//     debugPrint("✅ UserProvider: User Logged In (ID: $id, Name: $name)");
//   }

  
// static Future<void> loadLocalPhotoBase64() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? savedBase64 = prefs.getString('saved_user_photo_base64');
//       if (savedBase64 != null && savedBase64.trim().isNotEmpty) {
//         userPhotoBase64 = savedBase64;
//         photoNotifier.value = savedBase64; // ✅ UI ko batao
//         debugPrint("✅ Loaded photo (base64) from SharedPreferences");
//       }
//     } catch (e) {
//       debugPrint("❌ Error reading photo base64 from SharedPreferences: $e");
//     }
//   }

//   // ✅ Firestore se user profile aur reports load karne ka method
//   static Future<void> initUserData({bool forceRefresh = false}) async {
//     // Step A: Immediate Local Storage Read (App Kill Instant Fix)
//     await loadLocalPhotoBase64();

//     if (!forceRefresh && isDataLoaded && userPhotoBase64 != null) return;

//     try {
//       User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         userId = user.uid;
//         userEmail = user.email;

//         // 1. Fetch User Profile from Firestore
//         DocumentSnapshot doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (doc.exists && doc.data() != null) {
//           var data = doc.data() as Map<String, dynamic>;
//           userName = data['name'] ?? userName ?? "User";
//           userAge = data['age']?.toString() ?? userAge ?? "";
//           userGender = data['gender'] ?? userGender ?? "";

//        // 🛑 Photo Base64 ko Firestore se load karein
//           String? fetchedPhoto = data['photoBase64'];

//           if (fetchedPhoto != null && fetchedPhoto.trim().isNotEmpty) {
//             userPhotoBase64 = fetchedPhoto;
//             photoNotifier.value = fetchedPhoto; // ✅ UI ko batao
//             // Save to Local Storage
//             final prefs = await SharedPreferences.getInstance();
//             await prefs.setString('saved_user_photo_base64', fetchedPhoto);
//           }

//           isDataLoaded = true;
//           debugPrint(
//               "✅ UserProvider: Profile & Photo Loaded (base64 length: ${userPhotoBase64?.length ?? 0})");
//         }

//         // 2. Fetch User Reports
//         QuerySnapshot reportsSnapshot = await FirebaseFirestore.instance
//             .collection('reports')
//             .where('userId', isEqualTo: user.uid)
//             .where('isCompleted', isEqualTo: true)
//             .orderBy('timestamp', descending: false)
//             .get();

//         userReports = reportsSnapshot.docs
//             .map((doc) => doc.data() as Map<String, dynamic>)
//             .toList();

//         debugPrint(
//             "✅ UserProvider: ${userReports.length} Completed Reports Loaded");
//       }
//     } catch (e) {
//       debugPrint("❌ Error loading data in UserProvider: $e");
//     }
//   }

//   // ✅ Jab user test complete kar le to state instantly update karne ke liye
//   static void addReport(Map<String, dynamic> newReport) {
//     if (newReport['isCompleted'] == true) {
//       userReports.add(newReport);
//     }
//   }

//   // ✅ Profile update (Name, Age, Gender)
//   static void updateAllData({String? name, String? age, String? gender}) {
//     if (name != null) userName = name;
//     if (age != null) userAge = age;
//     if (gender != null) userGender = gender;
//   }

//   // ✅ Photo URL update, Local Storage Sync & Firestore Sync
//   // ✅ Photo Base64 update, Local Storage Sync & Firestore Sync
//   static Future<void> updatePhotoBase64(String newBase64) async {
//     userPhotoBase64 = newBase64;
//     photoNotifier.value = newBase64; // ✅ Turant sab listeners ko batao (Dashboard avatar sameet)

//     // Save to SharedPreferences immediately for offline & instant kill persistence
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('saved_user_photo_base64', newBase64);
//     } catch (e) {
//       debugPrint("❌ Error saving photo base64 to SharedPreferences: $e");
//     }

//     User? user = FirebaseAuth.instance.currentUser;
//     String? currentUid = userId ?? user?.uid;

//     if (currentUid != null) {
//       try {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(currentUid)
//             .set({'photoBase64': newBase64}, SetOptions(merge: true));

//         debugPrint(
//             "✅ UserProvider & Local/Firestore Photo (base64) updated successfully");
//       } catch (e) {
//         debugPrint("❌ Error updating photo base64 in Firestore: $e");
//       }
//     }
//   }

//   // ✅ Logout logic
//   static Future<void> clearData() async {
//     userId = null;
//     userName = null;
//     userEmail = null;
//     userAge = null;
//     userGender = null;
//     userPhotoBase64 = null;
//     photoNotifier.value = null; // ✅ Logout par avatar bhi reset ho
//     userReports = [];
//     isDataLoaded = false;

//     // Clear local storage photo on logout
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('saved_user_photo_base64');

//     debugPrint("✅ UserProvider: Data & Local Photo Cleared");
//   }
// }

