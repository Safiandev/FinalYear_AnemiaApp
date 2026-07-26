import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hemoglobe_ai/services/notification_service.dart';

class ReminderItem {
  int notificationId;
  String id;
  String title;
  String subtitle;
  String timeOrDate;
  bool isActive;
  bool isCustom;
  IconData iconData;

  ReminderItem({
    required this.notificationId,
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeOrDate,
    this.isActive = true,
    this.isCustom = false,
    this.iconData = Icons.alarm,
  });

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'timeOrDate': timeOrDate,
        'isActive': isActive,
        'isCustom': isCustom,
        'iconCodePoint': iconData.codePoint,
      };

  factory ReminderItem.fromJson(Map<String, dynamic> json) => ReminderItem(
        notificationId: json['notificationId'] ??
            (DateTime.now().millisecondsSinceEpoch % 100000),
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? 'Reminder',
        subtitle: json['subtitle'] ?? '',
        timeOrDate: json['timeOrDate'] ?? 'Not Set',
        isActive: json['isActive'] ?? true,
        isCustom: json['isCustom'] ?? false,
        iconData: IconData(
          json['iconCodePoint'] ?? Icons.alarm.codePoint,
          fontFamily: 'MaterialIcons',
        ),
      );
}

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  SharedPreferences? _prefs;
  List<ReminderItem> _remindersList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    _prefs = await SharedPreferences.getInstance();
    String? storedData = _prefs?.getString('custom_reminders_list');

    if (storedData != null && storedData.isNotEmpty) {
      try {
        List<dynamic> jsonList = jsonDecode(storedData);
        if (mounted) {
          setState(() {
            _remindersList =
                jsonList.map((item) => ReminderItem.fromJson(item)).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        _setupDefaultReminders();
      }
    } else {
      _setupDefaultReminders();
    }
  }

  void _setupDefaultReminders() {
    if (mounted) {
      setState(() {
        _remindersList = [
          ReminderItem(
            notificationId: 101,
            id: 'hemoglobinDate',
            title: 'Next Hemoglobin Test',
            subtitle: 'Usually recommended every 1–3 months',
            timeOrDate: _prefs?.getString('hemoglobinDate') ?? 'Not Set',
            isActive: false, // User pehli baar setup karega
            iconData: Icons.bloodtype,
          ),
          ReminderItem(
            notificationId: 102,
            id: 'ironTime',
            title: 'Iron Supplement',
            subtitle: 'Morning before breakfast (best absorption)',
            timeOrDate: _prefs?.getString('ironTime') ?? 'Not Set',
            isActive: false,
            iconData: Icons.medication,
          ),
          ReminderItem(
            notificationId: 103,
            id: 'vitaminCTime',
            title: 'Vitamin C Intake',
            subtitle: 'With iron supplement or meals',
            timeOrDate: _prefs?.getString('vitaminCTime') ?? 'Not Set',
            isActive: false,
            iconData: Icons.local_drink,
          ),
          ReminderItem(
            notificationId: 104,
            id: 'hydrationInterval',
            title: 'Hydration Reminder',
            subtitle: 'Drink water consistently',
            timeOrDate: _prefs?.getString('hydrationInterval') ?? 'Not Set',
            isActive: false,
            iconData: Icons.water_drop,
          ),
          ReminderItem(
            notificationId: 105,
            id: 'sleepTime',
            title: 'Sleep Schedule',
            subtitle: 'Recommended: 7–8 hours daily',
            timeOrDate: _prefs?.getString('sleepTime') ?? 'Not Set',
            isActive: false,
            iconData: Icons.bedtime,
          ),
        ];
        _isLoading = false;
      });
      _saveReminders();
    }
  }

  Future<void> _saveReminders() async {
    if (_prefs == null) return;
    List<Map<String, dynamic>> jsonList =
        _remindersList.map((e) => e.toJson()).toList();
    await _prefs!.setString('custom_reminders_list', jsonEncode(jsonList));

    ReminderItem scanReminder = _remindersList.firstWhere(
      (r) => r.id == 'hemoglobinDate',
      orElse: () => ReminderItem(
        notificationId: 101,
        id: 'hemoglobinDate',
        title: '',
        subtitle: '',
        timeOrDate: 'Not Set',
      ),
    );
    await _prefs!.setString('hemoglobinDate', scanReminder.timeOrDate);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Level 1 Validation: Check OS Level Permission
  Future<bool> _checkAndHandlePermission() async {
    bool hasPermission = await NotificationService.requestPermissions();
    if (!hasPermission && mounted) {
      _showPermissionDeniedDialog();
      return false;
    }
    return true;
  }

  /// Level 2 Validation: Check Notification Preferences Keys in SharedPreferences
  bool _checkPreferenceAllowed(ReminderItem item) {
    if (_prefs == null) return true;

    // 1. Check Master Push Toggle
    bool masterPush = _prefs!.getBool('pref_push') ?? true;
    if (!masterPush) {
      _showPrefDisabledDialog(
        title: "Push Notifications Off",
        message:
            "Master Push Notifications are turned off in Notification Preferences. Enable them first to activate reminders.",
      );
      return false;
    }

    // 2. Check Specific Categories
    if (item.id == 'hemoglobinDate') {
      bool scanPref = _prefs!.getBool('pref_scan') ?? true;
      if (!scanPref) {
        _showPrefDisabledDialog(
          title: "Scan Alerts Disabled",
          message:
              "'Hemoglobin Scan Due Alerts' is turned off in Notification Preferences.",
        );
        return false;
      }
    } else if (item.id == 'ironTime' || item.id == 'vitaminCTime') {
      bool suppPref = _prefs!.getBool('pref_supplement') ?? true;
      if (!suppPref) {
        _showPrefDisabledDialog(
          title: "Supplement Alerts Disabled",
          message:
              "'Supplement & Dose Reminders' is turned off in Notification Preferences.",
        );
        return false;
      }
    }

    return true;
  }

  void _showPrefDisabledDialog(
      {required String title, required String message}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_off_outlined,
                color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("OK",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_off, color: Colors.amber),
            SizedBox(width: 10),
            Text("Notifications Off", style: TextStyle(fontSize: 18)),
          ],
        ),
        content: const Text(
          "Notifications are currently disabled for Hemoglobe AI. Please enable notification permissions in your device settings to receive timely reminders.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Dismiss", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              NotificationService.requestPermissions();
            },
            child: const Text("Allow Permissions",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Helper logic to schedule system notification based on item state & 2-level validation
  Future<void> _applyScheduleForReminder(ReminderItem item) async {
    if (!item.isActive) {
      await NotificationService.cancelNotification(item.notificationId);
      return;
    }

    // Level 1: System OS Level Permission
    bool permissionGranted = await _checkAndHandlePermission();
    if (!permissionGranted) return;

    // Level 2: App Preferences Validation
    bool prefAllowed = _checkPreferenceAllowed(item);
    if (!prefAllowed) return;

    if (item.id == 'hemoglobinDate') {
      try {
        List<String> parts = item.timeOrDate.split('-');
        if (parts.length == 3) {
          int day = int.parse(parts[0]);
          int month = int.parse(parts[1]);
          int year = int.parse(parts[2]);
          DateTime targetTime = DateTime(year, month, day, 9, 0);

          if (targetTime.isBefore(DateTime.now())) {
            targetTime = DateTime.now().add(const Duration(minutes: 2));
          }

          await NotificationService.scheduleNotification(
            id: item.notificationId,
            title: "Hemoglobe AI — Scan Due!",
            body: "Your scheduled Hemoglobin scan is due today.",
            scheduledTime: targetTime,
          );
        }
      } catch (_) {}
    } else {
      // Time or Custom Interval Parsing
      try {
        DateTime now = DateTime.now();
        TimeOfDay? time = _parseTimeString(item.timeOrDate);

        if (time != null) {
          DateTime targetTime =
              DateTime(now.year, now.month, now.day, time.hour, time.minute);
          if (targetTime.isBefore(now)) {
            targetTime = targetTime.add(const Duration(days: 1));
          }

          await NotificationService.scheduleNotification(
            id: item.notificationId,
            title: "Hemoglobe AI — ${item.title}",
            body: item.subtitle,
            scheduledTime: targetTime,
          );
        }
      } catch (_) {}
    }
  }

  TimeOfDay? _parseTimeString(String timeStr) {
    try {
      final cleanStr = timeStr.trim().toUpperCase();
      final isPm = cleanStr.contains("PM");
      final isAm = cleanStr.contains("AM");
      final formatted = cleanStr.replaceAll(RegExp(r'[^\d:]'), '');
      final parts = formatted.split(':');

      if (parts.length == 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        if (isPm && hour < 12) hour += 12;
        if (isAm && hour == 12) hour = 0;

        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _editDate(ReminderItem item) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(2030),
    );

    if (picked != null && mounted) {
      String formatted = "${picked.day}-${picked.month}-${picked.year}";
      setState(() {
        item.timeOrDate = formatted;
        item.isActive = true;
      });
      await _saveReminders();
      await _applyScheduleForReminder(item);
      _showSnackBar("Test reminder scheduled for $formatted");
    }
  }

  Future<void> _editTime(ReminderItem item) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && mounted) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? "AM" : "PM";
      String formatted = "$hour:$minute $period";

      setState(() {
        item.timeOrDate = formatted;
        item.isActive = true;
      });
      await _saveReminders();
      await _applyScheduleForReminder(item);
      _showSnackBar("Reminder updated to $formatted");
    }
  }

  void _openAddCustomModal() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (sbContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add Custom Reminder",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: "Title (e.g., Blood Test, Medication)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: "Description / Recommendation",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Time: ${selectedTime.format(sbContext)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade50,
                          foregroundColor: Colors.indigo,
                        ),
                        onPressed: () async {
                          TimeOfDay? picked = await showTimePicker(
                            context: sbContext,
                            initialTime: selectedTime,
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedTime = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: const Text("Select Time"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (titleController.text.trim().isEmpty) {
                        _showSnackBar("Please enter a title", isError: true);
                        return;
                      }

                      String timeFormatted = selectedTime.format(sbContext);
                      int newNotifId =
                          DateTime.now().millisecondsSinceEpoch % 1000000;

                      ReminderItem newItem = ReminderItem(
                        notificationId: newNotifId,
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text.trim(),
                        subtitle: descController.text.trim().isNotEmpty
                            ? descController.text.trim()
                            : 'Custom Health Reminder',
                        timeOrDate: timeFormatted,
                        isCustom: true,
                        iconData: Icons.notifications_active,
                      );

                      if (mounted) {
                        setState(() {
                          _remindersList.add(newItem);
                        });
                      }

                      await _saveReminders();
                      await _applyScheduleForReminder(newItem);

                      if (mounted) {
                        if (Navigator.canPop(modalContext)) {
                          Navigator.pop(modalContext);
                        }
                        _showSnackBar("Custom reminder added & scheduled!");
                      }
                    },
                    child: const Text(
                      "Save Reminder",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Reminders & Schedules",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // reminders_screen.dart (AppBar action button logic)
          IconButton(
            icon: const Icon(Icons.notifications_active, color: Colors.indigo),
            tooltip: "Test Notification",
            onPressed: () async {
              bool permissionGranted = await _checkAndHandlePermission();
              if (permissionGranted) {
                bool masterPush = _prefs?.getBool('pref_push') ?? true;
                if (!masterPush) {
                  _showPrefDisabledDialog(
                    title: "Push Notifications Off",
                    message: "Master Push Notifications are turned off.",
                  );
                  return;
                }

                // Sirf Service ko call karein (wo notification trigger bhi karega aur history me single entry save bhi karega)
                await NotificationService.showInstantNotification(
                  title: "Hemoglobe AI Test",
                  body:
                      "Notification permission and sound are working perfectly!",
                );

                _showSnackBar("Test notification sent!");
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCustomModal,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Custom",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _remindersList.isEmpty
              ? const Center(child: Text("No reminders set yet."))
              : ListView.builder(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 80),
                  itemCount: _remindersList.length,
                  itemBuilder: (context, index) {
                    final item = _remindersList[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: item.isActive
                                    ? Colors.indigo.shade50
                                    : Colors.grey.shade100,
                                child: Icon(
                                  item.iconData,
                                  color: item.isActive
                                      ? Colors.indigo
                                      : Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: item.isActive
                                            ? Colors.black
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: item.isActive,
                                activeThumbColor: Colors.indigo,
                                onChanged: (val) async {
                                  if (val) {
                                    bool permissionGranted =
                                        await _checkAndHandlePermission();
                                    if (!permissionGranted) return;

                                    bool prefAllowed =
                                        _checkPreferenceAllowed(item);
                                    if (!prefAllowed) return;
                                  }

                                  setState(() {
                                    item.isActive = val;
                                  });
                                  await _saveReminders();
                                  await _applyScheduleForReminder(item);

                                  _showSnackBar(val
                                      ? "${item.title} activated"
                                      : "${item.title} turned off");
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Scheduled: ${item.timeOrDate}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: item.isActive
                                      ? Colors.indigo.shade900
                                      : Colors.grey,
                                ),
                              ),
                              Row(
                                children: [
                                  if (item.isCustom)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () async {
                                        setState(() {
                                          _remindersList.removeAt(index);
                                        });
                                        await _saveReminders();
                                        await NotificationService
                                            .cancelNotification(
                                                item.notificationId);
                                        _showSnackBar("Reminder removed");
                                      },
                                    ),
                                  TextButton.icon(
                                    onPressed: () {
                                      if (item.id == 'hemoglobinDate') {
                                        _editDate(item);
                                      } else {
                                        _editTime(item);
                                      }
                                    },
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text("Edit"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hemoglobe_ai/services/notification_service.dart';

// class ReminderItem {
//   int notificationId;
//   String id;
//   String title;
//   String subtitle;
//   String timeOrDate;
//   bool isActive;
//   bool isCustom;
//   IconData iconData;

//   ReminderItem({
//     required this.notificationId,
//     required this.id,
//     required this.title,
//     required this.subtitle,
//     required this.timeOrDate,
//     this.isActive = true,
//     this.isCustom = false,
//     this.iconData = Icons.alarm,
//   });

//   Map<String, dynamic> toJson() => {
//         'notificationId': notificationId,
//         'id': id,
//         'title': title,
//         'subtitle': subtitle,
//         'timeOrDate': timeOrDate,
//         'isActive': isActive,
//         'isCustom': isCustom,
//         'iconCodePoint': iconData.codePoint,
//       };

//   factory ReminderItem.fromJson(Map<String, dynamic> json) => ReminderItem(
//         notificationId: json['notificationId'] ??
//             (DateTime.now().millisecondsSinceEpoch % 100000),
//         id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
//         title: json['title'] ?? 'Reminder',
//         subtitle: json['subtitle'] ?? '',
//         timeOrDate: json['timeOrDate'] ?? 'Not Set',
//         isActive: json['isActive'] ?? true,
//         isCustom: json['isCustom'] ?? false,
//         iconData: IconData(
//           json['iconCodePoint'] ?? Icons.alarm.codePoint,
//           fontFamily: 'MaterialIcons',
//         ),
//       );
// }

// class RemindersScreen extends StatefulWidget {
//   const RemindersScreen({super.key});

//   @override
//   State<RemindersScreen> createState() => _RemindersScreenState();
// }

// class _RemindersScreenState extends State<RemindersScreen> {
//   SharedPreferences? _prefs;
//   List<ReminderItem> _remindersList = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadReminders();
//   }

//   Future<void> _loadReminders() async {
//     _prefs = await SharedPreferences.getInstance();
//     String? storedData = _prefs?.getString('custom_reminders_list');

//     if (storedData != null && storedData.isNotEmpty) {
//       try {
//         List<dynamic> jsonList = jsonDecode(storedData);
//         if (mounted) {
//           setState(() {
//             _remindersList =
//                 jsonList.map((item) => ReminderItem.fromJson(item)).toList();
//             _isLoading = false;
//           });
//         }
//       } catch (e) {
//         _setupDefaultReminders();
//       }
//     } else {
//       _setupDefaultReminders();
//     }
//   }

//   void _setupDefaultReminders() {
//     if (mounted) {
//       setState(() {
//         _remindersList = [
//           ReminderItem(
//             notificationId: 101,
//             id: 'hemoglobinDate',
//             title: 'Next Hemoglobin Test',
//             subtitle: 'Usually recommended every 1–3 months',
//             timeOrDate: _prefs?.getString('hemoglobinDate') ?? 'Not Set',
//             isActive: false, // User pehli baar setup karega
//             iconData: Icons.bloodtype,
//           ),
//           ReminderItem(
//             notificationId: 102,
//             id: 'ironTime',
//             title: 'Iron Supplement',
//             subtitle: 'Morning before breakfast (best absorption)',
//             timeOrDate: _prefs?.getString('ironTime') ?? 'Not Set',
//             isActive: false,
//             iconData: Icons.medication,
//           ),
//           ReminderItem(
//             notificationId: 103,
//             id: 'vitaminCTime',
//             title: 'Vitamin C Intake',
//             subtitle: 'With iron supplement or meals',
//             timeOrDate: _prefs?.getString('vitaminCTime') ?? 'Not Set',
//             isActive: false,
//             iconData: Icons.local_drink,
//           ),
//           ReminderItem(
//             notificationId: 104,
//             id: 'hydrationInterval',
//             title: 'Hydration Reminder',
//             subtitle: 'Drink water consistently',
//             timeOrDate: _prefs?.getString('hydrationInterval') ?? 'Not Set',
//             isActive: false,
//             iconData: Icons.water_drop,
//           ),
//           ReminderItem(
//             notificationId: 105,
//             id: 'sleepTime',
//             title: 'Sleep Schedule',
//             subtitle: 'Recommended: 7–8 hours daily',
//             timeOrDate: _prefs?.getString('sleepTime') ?? 'Not Set',
//             isActive: false,
//             iconData: Icons.bedtime,
//           ),
//         ];
//         _isLoading = false;
//       });
//       _saveReminders();
//     }
//   }

//   Future<void> _saveReminders() async {
//     if (_prefs == null) return;
//     List<Map<String, dynamic>> jsonList =
//         _remindersList.map((e) => e.toJson()).toList();
//     await _prefs!.setString('custom_reminders_list', jsonEncode(jsonList));

//     ReminderItem scanReminder = _remindersList.firstWhere(
//       (r) => r.id == 'hemoglobinDate',
//       orElse: () => ReminderItem(
//         notificationId: 101,
//         id: 'hemoglobinDate',
//         title: '',
//         subtitle: '',
//         timeOrDate: 'Not Set',
//       ),
//     );
//     await _prefs!.setString('hemoglobinDate', scanReminder.timeOrDate);
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green.shade700,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   /// Level 1 Validation: Check OS Level Permission
//   Future<bool> _checkAndHandlePermission() async {
//     bool hasPermission = await NotificationService.requestPermissions();
//     if (!hasPermission && mounted) {
//       _showPermissionDeniedDialog();
//       return false;
//     }
//     return true;
//   }

//   /// Level 2 Validation: Check Notification Preferences Keys in SharedPreferences
//   bool _checkPreferenceAllowed(ReminderItem item) {
//     if (_prefs == null) return true;

//     // 1. Check Master Push Toggle
//     bool masterPush = _prefs!.getBool('pref_push') ?? true;
//     if (!masterPush) {
//       _showPrefDisabledDialog(
//         title: "Push Notifications Off",
//         message:
//             "Master Push Notifications are turned off in Notification Preferences. Enable them first to activate reminders.",
//       );
//       return false;
//     }

//     // 2. Check Specific Categories
//     if (item.id == 'hemoglobinDate') {
//       bool scanPref = _prefs!.getBool('pref_scan') ?? true;
//       if (!scanPref) {
//         _showPrefDisabledDialog(
//           title: "Scan Alerts Disabled",
//           message:
//               "'Hemoglobin Scan Due Alerts' is turned off in Notification Preferences.",
//         );
//         return false;
//       }
//     } else if (item.id == 'ironTime' || item.id == 'vitaminCTime') {
//       bool suppPref = _prefs!.getBool('pref_supplement') ?? true;
//       if (!suppPref) {
//         _showPrefDisabledDialog(
//           title: "Supplement Alerts Disabled",
//           message:
//               "'Supplement & Dose Reminders' is turned off in Notification Preferences.",
//         );
//         return false;
//       }
//     }

//     return true;
//   }

//   void _showPrefDisabledDialog(
//       {required String title, required String message}) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Row(
//           children: [
//             const Icon(Icons.notifications_off_outlined,
//                 color: Colors.amber, size: 28),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(title,
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
//         ),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text("OK",
//                 style: TextStyle(
//                     color: Colors.white, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Icon(Icons.notifications_off, color: Colors.amber),
//             SizedBox(width: 10),
//             Text("Notifications Off", style: TextStyle(fontSize: 18)),
//           ],
//         ),
//         content: const Text(
//           "Notifications are currently disabled for Hemoglobe AI. Please enable notification permissions in your device settings to receive timely reminders.",
//           style: TextStyle(fontSize: 14),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text("Dismiss", style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.indigo,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             onPressed: () {
//               Navigator.pop(dialogContext);
//               NotificationService.requestPermissions();
//             },
//             child: const Text("Allow Permissions",
//                 style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Helper logic to schedule system notification based on item state & 2-level validation
//   Future<void> _applyScheduleForReminder(ReminderItem item) async {
//     if (!item.isActive) {
//       await NotificationService.cancelNotification(item.notificationId);
//       return;
//     }

//     // Level 1: System OS Level Permission
//     bool permissionGranted = await _checkAndHandlePermission();
//     if (!permissionGranted) return;

//     // Level 2: App Preferences Validation
//     bool prefAllowed = _checkPreferenceAllowed(item);
//     if (!prefAllowed) return;

//     if (item.id == 'hemoglobinDate') {
//       try {
//         List<String> parts = item.timeOrDate.split('-');
//         if (parts.length == 3) {
//           int day = int.parse(parts[0]);
//           int month = int.parse(parts[1]);
//           int year = int.parse(parts[2]);
//           DateTime targetTime = DateTime(year, month, day, 9, 0);

//           if (targetTime.isBefore(DateTime.now())) {
//             targetTime = DateTime.now().add(const Duration(minutes: 2));
//           }

//           await NotificationService.scheduleNotification(
//             id: item.notificationId,
//             title: "Hemoglobe AI — Scan Due!",
//             body: "Your scheduled Hemoglobin scan is due today.",
//             scheduledTime: targetTime,
//           );
//         }
//       } catch (_) {}
//     } else {
//       // Time or Custom Interval Parsing
//       try {
//         DateTime now = DateTime.now();
//         TimeOfDay? time = _parseTimeString(item.timeOrDate);

//         if (time != null) {
//           DateTime targetTime =
//               DateTime(now.year, now.month, now.day, time.hour, time.minute);
//           if (targetTime.isBefore(now)) {
//             targetTime = targetTime.add(const Duration(days: 1));
//           }

//           await NotificationService.scheduleNotification(
//             id: item.notificationId,
//             title: "Hemoglobe AI — ${item.title}",
//             body: item.subtitle,
//             scheduledTime: targetTime,
//           );
//         }
//       } catch (_) {}
//     }
//   }

//   TimeOfDay? _parseTimeString(String timeStr) {
//     try {
//       final cleanStr = timeStr.trim().toUpperCase();
//       final isPm = cleanStr.contains("PM");
//       final isAm = cleanStr.contains("AM");
//       final formatted = cleanStr.replaceAll(RegExp(r'[^\d:]'), '');
//       final parts = formatted.split(':');

//       if (parts.length == 2) {
//         int hour = int.parse(parts[0]);
//         int minute = int.parse(parts[1]);

//         if (isPm && hour < 12) hour += 12;
//         if (isAm && hour == 12) hour = 0;

//         return TimeOfDay(hour: hour, minute: minute);
//       }
//     } catch (_) {}
//     return null;
//   }

//   Future<void> _editDate(ReminderItem item) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//     );

//     if (picked != null && mounted) {
//       String formatted = "${picked.day}-${picked.month}-${picked.year}";
//       setState(() {
//         item.timeOrDate = formatted;
//         item.isActive = true;
//       });
//       await _saveReminders();
//       await _applyScheduleForReminder(item);
//       _showSnackBar("Test reminder scheduled for $formatted");
//     }
//   }

//   Future<void> _editTime(ReminderItem item) async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );

//     if (picked != null && mounted) {
//       final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
//       final minute = picked.minute.toString().padLeft(2, '0');
//       final period = picked.period == DayPeriod.am ? "AM" : "PM";
//       String formatted = "$hour:$minute $period";

//       setState(() {
//         item.timeOrDate = formatted;
//         item.isActive = true;
//       });
//       await _saveReminders();
//       await _applyScheduleForReminder(item);
//       _showSnackBar("Reminder updated to $formatted");
//     }
//   }

//   void _openAddCustomModal() {
//     final titleController = TextEditingController();
//     final descController = TextEditingController();
//     TimeOfDay selectedTime = TimeOfDay.now();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (modalContext) {
//         return StatefulBuilder(
//           builder: (context, setModalState) {
//             return Padding(
//               padding: EdgeInsets.only(
//                 left: 20,
//                 right: 20,
//                 top: 20,
//                 bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Add Custom Reminder",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 15),
//                   TextField(
//                     controller: titleController,
//                     decoration: InputDecoration(
//                       labelText: "Title (e.g., Blood Test, Medication)",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   TextField(
//                     controller: descController,
//                     decoration: InputDecoration(
//                       labelText: "Description / Recommendation",
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Time: ${selectedTime.format(context)}",
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 15,
//                         ),
//                       ),
//                       ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.indigo.shade50,
//                           foregroundColor: Colors.indigo,
//                         ),
//                         onPressed: () async {
//                           TimeOfDay? picked = await showTimePicker(
//                             context: context,
//                             initialTime: selectedTime,
//                           );
//                           if (picked != null) {
//                             setModalState(() {
//                               selectedTime = picked;
//                             });
//                           }
//                         },
//                         icon: const Icon(Icons.access_time),
//                         label: const Text("Select Time"),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.indigo,
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: () async {
//                       if (titleController.text.trim().isEmpty) {
//                         _showSnackBar("Please enter a title", isError: true);
//                         return;
//                       }

//                       String timeFormatted = selectedTime.format(context);
//                       int newNotifId =
//                           DateTime.now().millisecondsSinceEpoch % 1000000;

//                       ReminderItem newItem = ReminderItem(
//                         notificationId: newNotifId,
//                         id: DateTime.now().millisecondsSinceEpoch.toString(),
//                         title: titleController.text.trim(),
//                         subtitle: descController.text.trim().isNotEmpty
//                             ? descController.text.trim()
//                             : 'Custom Health Reminder',
//                         timeOrDate: timeFormatted,
//                         isCustom: true,
//                         iconData: Icons.notifications_active,
//                       );

//                       if (mounted) {
//                         setState(() {
//                           _remindersList.add(newItem);
//                         });
//                       }

//                       await _saveReminders();
//                       await _applyScheduleForReminder(newItem);

//                       if (mounted) {
//                         Navigator.pop(modalContext);
//                         _showSnackBar("Custom reminder added & scheduled!");
//                       }
//                     },
//                     child: const Text(
//                       "Save Reminder",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//  @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text(
//           "Reminders & Schedules",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         iconTheme: const IconThemeData(color: Colors.black),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_active, color: Colors.indigo),
//             tooltip: "Test Notification",
//             onPressed: () async {
//               bool permissionGranted = await _checkAndHandlePermission();
//               if (permissionGranted) {
//                 bool masterPush = _prefs?.getBool('pref_push') ?? true;
//                 if (!masterPush) {
//                   _showPrefDisabledDialog(
//                     title: "Push Notifications Off",
//                     message: "Master Push Notifications are turned off.",
//                   );
//                   return;
//                 }

//                 // Is call se notification sound bhi play hoga aur Center/Badge me Entry bhi chali jayegi!
//                 await NotificationService.showInstantNotification(
//                   title: "Hemoglobe AI Test",
//                   body: "Notification permission and sound are working perfectly!",
//                 );

//                 _showSnackBar("Test notification sent!");
//               }
//             },
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _openAddCustomModal,
//         backgroundColor: Colors.indigo,
//         icon: const Icon(Icons.add, color: Colors.white),
//         label: const Text(
//           "Add Custom",
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
//           : _remindersList.isEmpty
//               ? const Center(child: Text("No reminders set yet."))
//               : ListView.builder(
//                   padding: const EdgeInsets.only(
//                       left: 16, right: 16, top: 16, bottom: 80),
//                   itemCount: _remindersList.length,
//                   itemBuilder: (context, index) {
//                     final item = _remindersList[index];

//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 14),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.04),
//                             blurRadius: 10,
//                             offset: const Offset(0, 4),
//                           )
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               CircleAvatar(
//                                 backgroundColor: item.isActive
//                                     ? Colors.indigo.shade50
//                                     : Colors.grey.shade100,
//                                 child: Icon(
//                                   item.iconData,
//                                   color: item.isActive
//                                       ? Colors.indigo
//                                       : Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       item.title,
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: item.isActive
//                                             ? Colors.black
//                                             : Colors.grey.shade600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 2),
//                                     Text(
//                                       item.subtitle,
//                                       style: TextStyle(
//                                         color: Colors.grey.shade600,
//                                         fontSize: 12,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               Switch(
//                                 value: item.isActive,
//                                 activeColor: Colors.indigo,
//                                 onChanged: (val) async {
//                                   // If user is enabling, check Level 1 & Level 2 validations
//                                   if (val) {
//                                     bool permissionGranted =
//                                         await _checkAndHandlePermission();
//                                     if (!permissionGranted) return;

//                                     bool prefAllowed =
//                                         _checkPreferenceAllowed(item);
//                                     if (!prefAllowed) return;
//                                   }

//                                   setState(() {
//                                     item.isActive = val;
//                                   });
//                                   await _saveReminders();
//                                   await _applyScheduleForReminder(item);

//                                   _showSnackBar(val
//                                       ? "${item.title} activated"
//                                       : "${item.title} turned off");
//                                 },
//                               ),
//                             ],
//                           ),
//                           const Divider(height: 20),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 "Scheduled: ${item.timeOrDate}",
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: item.isActive
//                                       ? Colors.indigo.shade900
//                                       : Colors.grey,
//                                 ),
//                               ),
//                               Row(
//                                 children: [
//                                   if (item.isCustom)
//                                     IconButton(
//                                       icon: const Icon(Icons.delete_outline,
//                                           color: Colors.red),
//                                       onPressed: () async {
//                                         setState(() {
//                                           _remindersList.removeAt(index);
//                                         });
//                                         await _saveReminders();
//                                         await NotificationService
//                                             .cancelNotification(
//                                                 item.notificationId);
//                                         _showSnackBar("Reminder removed");
//                                       },
//                                     ),
//                                   TextButton.icon(
//                                     onPressed: () {
//                                       if (item.id == 'hemoglobinDate') {
//                                         _editDate(item);
//                                       } else {
//                                         _editTime(item);
//                                       }
//                                     },
//                                     icon: const Icon(Icons.edit, size: 16),
//                                     label: const Text("Edit"),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
  

               



