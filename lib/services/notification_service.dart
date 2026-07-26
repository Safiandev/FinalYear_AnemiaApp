import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzData;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<bool> requestPermissions() async {
    // Android 13+ ke liye permission request
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? androidGranted =
        await androidImplementation?.requestNotificationsPermission();

    // iOS ke liye permission request
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    bool? iosGranted = await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted ?? false;
  }

  static Future<void> initNotification() async {
    // 1. Initialize Timezones (Crucial for scheduled notifications)
    tzData.initializeTimeZones();

    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Notification tap handling if needed
      },
    );

    // Request Android 13+ Notification Permissions
    if (Platform.isAndroid) {
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
      }
    }
  }

  /// Instant Notification Send Karein Aur Notification History Me Entry Add Karein
  static Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'hemoglobe_instant_channel',
      'Instant Notifications',
      channelDescription: 'Channel for immediate test notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    // System Notification Show Karein
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 10000,
      title,
      body,
      details,
    );

    // SharedPreferences me save karein taake Red Dot Badge aur History Center sync ho sakein
    await addNotificationToHistory(title: title, body: body);
  }

  /// Helper Method: SharedPreferences Me Notification Record Save Karna (Unread Mode)
  static Future<void> addNotificationToHistory({
    required String title,
    required String body,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? storedData = prefs.getString('app_notification_history');

      List<dynamic> jsonList = [];
      if (storedData != null && storedData.isNotEmpty) {
        jsonList = jsonDecode(storedData);
      }

      // Naya item create karein jisme `isRead: false` hoga
      Map<String, dynamic> newItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'body': body,
        'timestamp': DateTime.now().toIso8601String(),
        'isRead': false, // Is se Dashboard ka Red Dot badge active hoga
      };

      // Top/Start par insert karein taake latest notification sabse upar dikhe
      jsonList.insert(0, newItem);

      await prefs.setString('app_notification_history', jsonEncode(jsonList));
    } catch (e) {
      print("Error saving notification to history: $e");
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Ensure time is in the future
      DateTime now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(seconds: 10));
      }

      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'hemoglobe_reminders_channel',
        'Scheduled Health Reminders',
        channelDescription:
            'Notifications for tests, supplements, and schedules',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true, // default system sound use hoga
      );

      const NotificationDetails details =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode
            .exactAllowWhileIdle, // Allows alarm in Doze mode
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      final pending = await _notificationsPlugin.pendingNotificationRequests();
      print("✅ Scheduled successfully. Total pending: ${pending.length}");
      for (var p in pending) {
        print("Pending -> id:${p.id}, title:${p.title}");
      }
    } catch (e) {
      // Fallback for devices restricting EXACT alarms
      print("Exact Alarm Error: $e. Retrying with inexact schedule.");
      final tz.TZDateTime tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hemoglobe_reminders_channel',
            'Scheduled Health Reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest_all.dart' as tzData;
// import 'dart:io';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<bool> requestPermissions() async {
//     // Android 13+ ke liye permission request
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//         _notificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     bool? androidGranted =
//         await androidImplementation?.requestNotificationsPermission();

//     // iOS ke liye permission request
//     final IOSFlutterLocalNotificationsPlugin? iosImplementation =
//         _notificationsPlugin.resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>();

//     bool? iosGranted = await iosImplementation?.requestPermissions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     return androidGranted ?? iosGranted ?? false;
//   }

//   static Future<void> initNotification() async {
//     // 1. Initialize Timezones (Crucial for scheduled notifications)
//     tzData.initializeTimeZones();

//     const AndroidInitializationSettings androidInitSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iosInitSettings =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidInitSettings,
//       iOS: iosInitSettings,
//     );

//     await _notificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         // Notification tap handling if needed
//       },
//     );

//     // Request Android 13+ Notification Permissions
//     if (Platform.isAndroid) {
//       final androidImplementation =
//           _notificationsPlugin.resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>();

//       if (androidImplementation != null) {
//         await androidImplementation.requestNotificationsPermission();
//         await androidImplementation.requestExactAlarmsPermission();
//       }
//     }
//   }

//   static Future<void> showInstantNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'hemoglobe_instant_channel',
//       'Instant Notifications',
//       channelDescription: 'Channel for immediate test notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails details =
//         NotificationDetails(android: androidDetails);
//     await _notificationsPlugin.show(0, title, body, details);
//   }

//   static Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledTime,
//   }) async {
//     try {
//       // Ensure time is in the future
//       DateTime now = DateTime.now();
//       if (scheduledTime.isBefore(now)) {
//         scheduledTime = scheduledTime.add(const Duration(seconds: 10));
//       }

//       final tz.TZDateTime tzScheduledTime =
//           tz.TZDateTime.from(scheduledTime, tz.local);

//       const AndroidNotificationDetails androidDetails =
//           AndroidNotificationDetails(
//         'hemoglobe_reminders_channel',
//         'Scheduled Health Reminders',
//         channelDescription:
//             'Notifications for tests, supplements, and schedules',
//         importance: Importance.max,
//         priority: Priority.high,
//         playSound: true, // default system sound use hoga
//       );

//       const NotificationDetails details =
//           NotificationDetails(android: androidDetails);

//       await _notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tzScheduledTime,
//         details,
//         androidScheduleMode: AndroidScheduleMode
//             .exactAllowWhileIdle, // Allows alarm in Doze mode
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );

//       final pending = await _notificationsPlugin.pendingNotificationRequests();
//       print("✅ Scheduled successfully. Total pending: ${pending.length}");
//       for (var p in pending) {
//         print("Pending -> id:${p.id}, title:${p.title}");
//       }
//     } catch (e) {
//       // Fallback for devices restricting EXACT alarms
//       print("Exact Alarm Error: $e. Retrying with inexact schedule.");
//       final tz.TZDateTime tzScheduledTime =
//           tz.TZDateTime.from(scheduledTime, tz.local);

//       await _notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tzScheduledTime,
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'hemoglobe_reminders_channel',
//             'Scheduled Health Reminders',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         ),
//         androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//       );
//     }
//   }

//   static Future<void> cancelNotification(int id) async {
//     await _notificationsPlugin.cancel(id);
//   }

//   static Future<void> cancelAllNotifications() async {
//     await _notificationsPlugin.cancelAll();
//   }
// }
