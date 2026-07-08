// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class RemindersScreen extends StatefulWidget {
//   const RemindersScreen({super.key});

//   @override
//   State<RemindersScreen> createState() => _RemindersScreenState();
// }

// class _RemindersScreenState extends State<RemindersScreen> {
//   late SharedPreferences prefs;

//   String hemoglobinDate = "Not Set";
//   String ironTime = "8:00 AM";
//   String vitaminCTime = "12:00 PM";
//   String hydrationInterval = "Every 2 hours";
//   String sleepTime = "10:00 PM";

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     initializePrefs();
//     initializeNotifications();
//   }

//   // ---------- Initialize SharedPreferences ----------
//   Future<void> initializePrefs() async {
//     prefs = await SharedPreferences.getInstance();
//     setState(() {
//       hemoglobinDate = prefs.getString('hemoglobinDate') ?? 'Not Set';
//       ironTime = prefs.getString('ironTime') ?? '8:00 AM';
//       vitaminCTime = prefs.getString('vitaminCTime') ?? '12:00 PM';
//       hydrationInterval =
//           prefs.getString('hydrationInterval') ?? 'Every 2 hours';
//       sleepTime = prefs.getString('sleepTime') ?? '10:00 PM';
//     });
//   }

//   // ---------- Initialize Notifications ----------
//   void initializeNotifications() async {
//     tz.initializeTimeZones();

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: initializationSettingsAndroid,
//           iOS: null,
//           macOS: null,
//         );

//     await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }

//   // ---------- Schedule Notification ----------
//   Future<void> scheduleNotification(
//     int id,
//     String title,
//     DateTime scheduledTime,
//   ) async {
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       'Reminder',
//       title,
//       tz.TZDateTime.from(scheduledTime, tz.local),
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           'reminder_channel',
//           'Reminders',
//           channelDescription: 'Reminder notifications',
//           importance: Importance.max,
//           priority: Priority.high,
//           playSound: true,
//         ),
//       ),
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }

//   // ---------- DATE PICKER ----------
//   Future<void> pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//     );

//     if (picked != null) {
//       setState(() {
//         hemoglobinDate = "${picked.day}-${picked.month}-${picked.year}";
//         prefs.setString('hemoglobinDate', hemoglobinDate);

//         // Schedule notification at 9 AM on selected date
//         scheduleNotification(
//           0,
//           "Next Hemoglobin Test",
//           DateTime(picked.year, picked.month, picked.day, 9, 0),
//         );
//       });
//     }
//   }

//   // ---------- TIME PICKER ----------
//   Future<void> pickTime(String key, Function(String) updateTime) async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (picked != null) {
//       final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
//       final minute = picked.minute.toString().padLeft(2, '0');
//       final period = picked.period == DayPeriod.am ? "AM" : "PM";

//       String formatted = "$hour:$minute $period";

//       setState(() {
//         updateTime(formatted);
//         prefs.setString(key, formatted);

//         // Schedule notification for today at picked time
//         DateTime now = DateTime.now();
//         DateTime scheduledTime = DateTime(
//           now.year,
//           now.month,
//           now.day,
//           picked.hour,
//           picked.minute,
//         );
//         scheduleNotification(
//           key.hashCode,
//           key.replaceAll('_', ' '),
//           scheduledTime,
//         );
//       });
//     }
//   }

//   // ---------- HYDRATION INTERVAL ----------
//   void chooseHydrationInterval() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         List<String> options = [
//           "Every 1 hour",
//           "Every 2 hours",
//           "Every 3 hours",
//           "Every 4 hours",
//         ];

//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: options.map((option) {
//             return ListTile(
//               title: Text(option),
//               onTap: () {
//                 setState(() {
//                   hydrationInterval = option;
//                   prefs.setString('hydrationInterval', hydrationInterval);
//                   Navigator.pop(context);
//                 });
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   // ---------- Reminder Card ----------
//   Widget reminderCard({
//     required IconData icon,
//     required String title,
//     required String recommendation,
//     required String userValue,
//     required VoidCallback onEdit,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 backgroundColor: Colors.blue.withOpacity(0.1),
//                 child: Icon(icon, color: Colors.blue),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//               TextButton(onPressed: onEdit, child: const Text("Edit")),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Recommended: $recommendation",
//             style: const TextStyle(color: Colors.grey),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "Your Reminder: $userValue",
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Reminders", style: TextStyle(color: Colors.black)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 1,
//       ),
//       backgroundColor: Colors.grey.shade100,
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           reminderCard(
//             icon: Icons.bloodtype,
//             title: "Next Hemoglobin Test",
//             recommendation: "Usually every 1–3 months depending on levels",
//             userValue: hemoglobinDate,
//             onEdit: pickDate,
//           ),
//           reminderCard(
//             icon: Icons.medication,
//             title: "Iron Supplement",
//             recommendation: "Morning before breakfast (best absorption)",
//             userValue: ironTime,
//             onEdit: () => pickTime('ironTime', (value) => ironTime = value),
//           ),
//           reminderCard(
//             icon: Icons.local_drink,
//             title: "Vitamin C Intake",
//             recommendation: "With iron supplement or meals",
//             userValue: vitaminCTime,
//             onEdit: () =>
//                 pickTime('vitaminCTime', (value) => vitaminCTime = value),
//           ),
//           reminderCard(
//             icon: Icons.water_drop,
//             title: "Hydration Reminder",
//             recommendation: "Drink water every 2 hours",
//             userValue: hydrationInterval,
//             onEdit: chooseHydrationInterval,
//           ),
//           reminderCard(
//             icon: Icons.bedtime,
//             title: "Sleep Reminder",
//             recommendation: "Recommended: 7–8 hours per night",
//             userValue: sleepTime,
//             onEdit: () => pickTime('sleepTime', (value) => sleepTime = value),
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }

// ------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  late SharedPreferences prefs;

  String hemoglobinDate = "Not Set";
  String ironTime = "8:00 AM";
  String vitaminCTime = "12:00 PM";
  String hydrationInterval = "Every 2 hours";
  String sleepTime = "10:00 PM";

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    initializePrefs();
    initializeNotifications();
  }

  // ---------- Initialize SharedPreferences ----------
  Future<void> initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      hemoglobinDate = prefs.getString('hemoglobinDate') ?? 'Not Set';
      ironTime = prefs.getString('ironTime') ?? '8:00 AM';
      vitaminCTime = prefs.getString('vitaminCTime') ?? '12:00 PM';
      hydrationInterval =
          prefs.getString('hydrationInterval') ?? 'Every 2 hours';
      sleepTime = prefs.getString('sleepTime') ?? '10:00 PM';
    });
  }

  // ---------- Initialize Notifications ----------
  void initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: null,
      macOS: null,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // ---------- Schedule Notification ----------
  Future<void> scheduleNotification(
    int id,
    String title,
    DateTime scheduledTime,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Reminder',
      title,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          channelDescription: 'Reminder notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ---------- DATE PICKER ----------
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      String formatted = "${picked.day}-${picked.month}-${picked.year}";
      setState(() {
        hemoglobinDate = formatted;
      });
      await prefs.setString('hemoglobinDate', formatted);

      // Schedule notification at 9 AM on selected date
      scheduleNotification(
        0,
        "Next Hemoglobin Test",
        DateTime(picked.year, picked.month, picked.day, 9, 0),
      );
    }
  }

  // ---------- TIME PICKER ----------
  Future<void> pickTime(String key, Function(String) updateTime) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? "AM" : "PM";

      String formatted = "$hour:$minute $period";

      setState(() {
        updateTime(formatted);
      });
      await prefs.setString(key, formatted);

      // Schedule notification for today at picked time
      DateTime now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      scheduleNotification(
        key.hashCode,
        key.replaceAll('_', ' '),
        scheduledTime,
      );
    }
  }

  // ---------- HYDRATION INTERVAL ----------
  void chooseHydrationInterval() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        List<String> options = [
          "Every 1 hour",
          "Every 2 hours",
          "Every 3 hours",
          "Every 4 hours",
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              onTap: () async {
                setState(() {
                  hydrationInterval = option;
                });
                await prefs.setString('hydrationInterval', hydrationInterval);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  // ---------- REMINDER CARD ----------
  Widget reminderCard({
    required IconData icon,
    required String title,
    required String recommendation,
    required String userValue,
    required VoidCallback onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(icon, color: Colors.blue),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              TextButton(onPressed: onEdit, child: const Text("Edit")),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Recommended: $recommendation",
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            "Your Reminder: $userValue",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reminders", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          reminderCard(
            icon: Icons.bloodtype,
            title: "Next Hemoglobin Test",
            recommendation: "Usually every 1–3 months depending on levels",
            userValue: hemoglobinDate,
            onEdit: pickDate,
          ),
          reminderCard(
            icon: Icons.medication,
            title: "Iron Supplement",
            recommendation: "Morning before breakfast (best absorption)",
            userValue: ironTime,
            onEdit: () => pickTime('ironTime', (value) => ironTime = value),
          ),
          reminderCard(
            icon: Icons.local_drink,
            title: "Vitamin C Intake",
            recommendation: "With iron supplement or meals",
            userValue: vitaminCTime,
            onEdit: () =>
                pickTime('vitaminCTime', (value) => vitaminCTime = value),
          ),
          reminderCard(
            icon: Icons.water_drop,
            title: "Hydration Reminder",
            recommendation: "Drink water every 2 hours",
            userValue: hydrationInterval,
            onEdit: chooseHydrationInterval,
          ),
          reminderCard(
            icon: Icons.bedtime,
            title: "Sleep Reminder",
            recommendation: "Recommended: 7–8 hours per night",
            userValue: sleepTime,
            onEdit: () => pickTime('sleepTime', (value) => sleepTime = value),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
