import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  // Local Notifications Plugin Instance for checking OS Permissions
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Preferences State Variables
  bool pushNotifications = true;
  bool emailNotifications = true;
  bool smsNotifications = false;
  bool scanReminders = true;
  bool healthTips = true;
  bool supplementReminders = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load saved preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = _prefs.getBool('pref_push') ?? true;
      emailNotifications = _prefs.getBool('pref_email') ?? true;
      smsNotifications = _prefs.getBool('pref_sms') ?? false;
      scanReminders = _prefs.getBool('pref_scan') ?? true;
      healthTips = _prefs.getBool('pref_tips') ?? true;
      supplementReminders = _prefs.getBool('pref_supplement') ?? true;
      _isLoading = false;
    });
  }

  // Helper method to check OS Permission
  Future<bool> _checkOSNotificationPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    bool? granted = await androidImplementation?.areNotificationsEnabled();
    return granted ?? true; // Default true for safety if check fails
  }

  // Show OS Settings Warning Dialog
  void _showOSSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.notifications_off_outlined,
                color: Colors.redAccent, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Phone Notifications Disabled",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          "Notifications for Aura are turned off in your phone settings. Please enable them in your device settings to turn on Push Notifications.",
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
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "OK",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Smart Toggle Handler: Shows Warning Dialog when turning OFF & OS Check when turning ON
  Future<void> _handleToggleChange({
    required String key,
    required bool currentValue,
    required String title,
    required String warningMessage,
    required Function(bool) updateState,
    bool isPushNotificationToggle = false,
  }) async {
    // 1. If user is trying to turn ON Push Notifications, check OS level first
    if (currentValue == false && isPushNotificationToggle) {
      bool isOSAllowed = await _checkOSNotificationPermission();
      if (!isOSAllowed) {
        _showOSSettingsDialog();
        return; // Guard clause: Stop execution, keep switch OFF
      }
    }

    // 2. If user is trying to turn OFF, show Impact Confirmation Dialog
    if (currentValue == true) {
      bool? confirmDisable = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Disable $title?",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            warningMessage,
            style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Keep Enabled"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                "Disable",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      // If user canceled the dialog, do not change toggle state
      if (confirmDisable != true) return;
    }

    bool newValue = !currentValue;
    updateState(newValue);
    await _prefs.setBool(key, newValue);

    _showSnackBar("$title ${newValue ? 'enabled' : 'disabled'}");
  }

  // Save all preferences at once
  Future<void> _saveAllChanges() async {
    await _prefs.setBool('pref_push', pushNotifications);
    await _prefs.setBool('pref_email', emailNotifications);
    await _prefs.setBool('pref_sms', smsNotifications);
    await _prefs.setBool('pref_scan', scanReminders);
    await _prefs.setBool('pref_tips', healthTips);
    await _prefs.setBool('pref_supplement', supplementReminders);

    _showSnackBar("All notification preferences saved successfully!",
        isSuccess: true);
  }

  // Reset to default healthcare values
  Future<void> _resetToDefault() async {
    setState(() {
      pushNotifications = true;
      emailNotifications = true;
      smsNotifications = false;
      scanReminders = true;
      healthTips = true;
      supplementReminders = true;
    });

    await _saveAllChanges();
    _showSnackBar("Reset to default preferences", isSuccess: true);
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isSuccess ? Colors.indigo.shade700 : Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Notification Preferences",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Channels & General"),
                  _buildToggleCard(
                    title: "Push Notifications",
                    subtitle: "Receive instant updates and scan reminders",
                    icon: Icons.notifications_active_outlined,
                    value: pushNotifications,
                    onChanged: (val) {
                      _handleToggleChange(
                        key: 'pref_push',
                        currentValue: pushNotifications,
                        title: "Push Notifications",
                        warningMessage:
                            "Turning this off mutes all master push alerts. You will not receive any instant alerts or scan notifications on your device.",
                        isPushNotificationToggle: true,
                        updateState: (newVal) =>
                            setState(() => pushNotifications = newVal),
                      );
                    },
                  ),
                  _buildToggleCard(
                    title: "Email Reports & Summaries",
                    subtitle: "Receive weekly health insights via email",
                    icon: Icons.mark_email_read_outlined,
                    value: emailNotifications,
                    onChanged: (val) {
                      _handleToggleChange(
                        key: 'pref_email',
                        currentValue: emailNotifications,
                        title: "Email Notifications",
                        warningMessage:
                            "You will stop receiving weekly diagnostic summaries and digital reports via email.",
                        updateState: (newVal) =>
                            setState(() => emailNotifications = newVal),
                      );
                    },
                  ),
                  _buildToggleCard(
                    title: "SMS Emergency Alerts",
                    subtitle: "Important critical updates via SMS",
                    icon: Icons.sms_outlined,
                    value: smsNotifications,
                    onChanged: (val) {
                      _handleToggleChange(
                        key: 'pref_sms',
                        currentValue: smsNotifications,
                        title: "SMS Emergency Alerts",
                        warningMessage:
                            "Critical hemoglobin level warnings and urgent care SMS reminders will be disabled.",
                        updateState: (newVal) =>
                            setState(() => smsNotifications = newVal),
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  _buildSectionHeader("Health & Care Schedule"),
                  _buildToggleCard(
                    title: "Hemoglobin Scan Due Alerts",
                    subtitle: "Remind me when my next Hb test is due",
                    icon: Icons.bloodtype_outlined,
                    value: scanReminders,
                    onChanged: (val) {
                      _handleToggleChange(
                        key: 'pref_scan',
                        currentValue: scanReminders,
                        title: "Scan Due Alerts",
                        warningMessage:
                            "Your scheduled scan reminders will not pop up. You will need to check the Reminders screen manually to track your upcoming tests.",
                        updateState: (newVal) =>
                            setState(() => scanReminders = newVal),
                      );
                    },
                  ),
                  _buildToggleCard(
                    title: "Supplement & Dose Reminders",
                    subtitle: "Timely alerts for Iron & Vitamin intake",
                    icon: Icons.medication_outlined,
                    value: supplementReminders,
                    onChanged: (val) {
                      _handleToggleChange(
                        key: 'pref_supplement',
                        currentValue: supplementReminders,
                        title: "Supplement Reminders",
                        warningMessage:
                            "Timely dose prompts for Iron and Vitamin supplements will be muted.",
                        updateState: (newVal) =>
                            setState(() => supplementReminders = newVal),
                      );
                    },
                  ),
                  _buildToggleCard(
                    title: "Daily Health Insights",
                    subtitle: "Anemia management tips & lifestyle advice",
                    icon: Icons.lightbulb_outline,
                    value: healthTips,
                    onChanged: (val) {
                      _handleToggleChange(
                        key: 'pref_tips',
                        currentValue: healthTips,
                        title: "Health Insights",
                        warningMessage:
                            "Daily anemia management tips and lifestyle recommendation alerts will be turned off.",
                        updateState: (newVal) =>
                            setState(() => healthTips = newVal),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons Section
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetToDefault,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.indigo.shade200),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Reset Default",
                            style: TextStyle(
                              color: Colors.indigo.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveAllChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Save Settings",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          "Aura v2.4.1",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Encrypted Healthcare Data Security",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Colors.grey.shade700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? Colors.indigo.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? Colors.indigo : Colors.grey.shade500,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: value ? Colors.black : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.indigo,
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationPreferencesScreen extends StatefulWidget {
//   const NotificationPreferencesScreen({super.key});

//   @override
//   State<NotificationPreferencesScreen> createState() =>
//       _NotificationPreferencesScreenState();
// }

// class _NotificationPreferencesScreenState
//     extends State<NotificationPreferencesScreen> {
//   late SharedPreferences _prefs;
//   bool _isLoading = true;

//   // Local Notifications Plugin Instance for checking OS Permissions
//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Preferences State Variables
//   bool pushNotifications = true;
//   bool emailNotifications = true;
//   bool smsNotifications = false;
//   bool scanReminders = true;
//   bool healthTips = true;
//   bool supplementReminders = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//   }

//   // Load saved preferences from SharedPreferences
//   Future<void> _loadPreferences() async {
//     _prefs = await SharedPreferences.getInstance();
//     setState(() {
//       pushNotifications = _prefs.getBool('pref_push') ?? true;
//       emailNotifications = _prefs.getBool('pref_email') ?? true;
//       smsNotifications = _prefs.getBool('pref_sms') ?? false;
//       scanReminders = _prefs.getBool('pref_scan') ?? true;
//       healthTips = _prefs.getBool('pref_tips') ?? true;
//       supplementReminders = _prefs.getBool('pref_supplement') ?? true;
//       _isLoading = false;
//     });
//   }

//   // Helper method to check OS Permission
//   Future<bool> _checkOSNotificationPermission() async {
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//         _notificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     bool? granted = await androidImplementation?.areNotificationsEnabled();
//     return granted ?? true; // Default true for safety if check fails
//   }

//   // Show OS Settings Warning Dialog
//   void _showOSSettingsDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Row(
//           children: [
//             Icon(Icons.notifications_off_outlined,
//                 color: Colors.redAccent, size: 28),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 "Phone Notifications Disabled",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           "Notifications for Aura are turned off in your phone settings. Please enable them in your device settings to turn on Push Notifications.",
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
//             onPressed: () => Navigator.pop(ctx),
//             child: const Text(
//               "OK",
//               style:
//                   TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Smart Toggle Handler: Shows Warning Dialog when turning OFF & OS Check when turning ON
//   Future<void> _handleToggleChange({
//     required String key,
//     required bool currentValue,
//     required String title,
//     required String warningMessage,
//     required Function(bool) updateState,
//     bool isPushNotificationToggle = false,
//   }) async {
//     // 1. If user is trying to turn ON Push Notifications, check OS level first
//     if (currentValue == false && isPushNotificationToggle) {
//       bool isOSAllowed = await _checkOSNotificationPermission();
//       if (!isOSAllowed) {
//         _showOSSettingsDialog();
//         return; // Guard clause: Stop execution, keep switch OFF
//       }
//     }

//     // 2. If user is trying to turn OFF, show Impact Confirmation Dialog
//     if (currentValue == true) {
//       bool? confirmDisable = await showDialog<bool>(
//         context: context,
//         builder: (ctx) => AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           title: Row(
//             children: [
//               const Icon(Icons.warning_amber_rounded,
//                   color: Colors.amber, size: 28),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   "Disable $title?",
//                   style: const TextStyle(
//                       fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//           content: Text(
//             warningMessage,
//             style: TextStyle(color: Colors.grey.shade800, fontSize: 14),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(ctx, false),
//               child: const Text("Keep Enabled"),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.redAccent,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               onPressed: () => Navigator.pop(ctx, true),
//               child: const Text(
//                 "Disable",
//                 style:
//                     TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ],
//         ),
//       );

//       // If user canceled the dialog, do not change toggle state
//       if (confirmDisable != true) return;
//     }

//     bool newValue = !currentValue;
//     updateState(newValue);
//     await _prefs.setBool(key, newValue);

//     _showSnackBar("$title ${newValue ? 'enabled' : 'disabled'}");
//   }

//   // Save all preferences at once
//   Future<void> _saveAllChanges() async {
//     await _prefs.setBool('pref_push', pushNotifications);
//     await _prefs.setBool('pref_email', emailNotifications);
//     await _prefs.setBool('pref_sms', smsNotifications);
//     await _prefs.setBool('pref_scan', scanReminders);
//     await _prefs.setBool('pref_tips', healthTips);
//     await _prefs.setBool('pref_supplement', supplementReminders);

//     _showSnackBar("All notification preferences saved successfully!",
//         isSuccess: true);
//   }

//   // Reset to default healthcare values
//   Future<void> _resetToDefault() async {
//     setState(() {
//       pushNotifications = true;
//       emailNotifications = true;
//       smsNotifications = false;
//       scanReminders = true;
//       healthTips = true;
//       supplementReminders = true;
//     });

//     await _saveAllChanges();
//     _showSnackBar("Reset to default preferences", isSuccess: true);
//   }

//   void _showSnackBar(String message, {bool isSuccess = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(
//               isSuccess ? Icons.check_circle : Icons.info_outline,
//               color: Colors.white,
//               size: 20,
//             ),
//             const SizedBox(width: 10),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor:
//             isSuccess ? Colors.indigo.shade700 : Colors.grey.shade800,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text(
//           "Notification Preferences",
//           style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildSectionHeader("Channels & General"),
//                   _buildToggleCard(
//                     title: "Push Notifications",
//                     subtitle: "Receive instant updates and scan reminders",
//                     icon: Icons.notifications_active_outlined,
//                     value: pushNotifications,
//                     onChanged: (val) {
//                       _handleToggleChange(
//                         key: 'pref_push',
//                         currentValue: pushNotifications,
//                         title: "Push Notifications",
//                         warningMessage:
//                             "Turning this off mutes all master push alerts. You will not receive any instant alerts or scan notifications on your device.",
//                         isPushNotificationToggle: true,
//                         updateState: (newVal) =>
//                             setState(() => pushNotifications = newVal),
//                       );
//                     },
//                   ),
//                   _buildToggleCard(
//                     title: "Email Reports & Summaries",
//                     subtitle: "Receive weekly health insights via email",
//                     icon: Icons.mark_email_read_outlined,
//                     value: emailNotifications,
//                     onChanged: (val) {
//                       _handleToggleChange(
//                         key: 'pref_email',
//                         currentValue: emailNotifications,
//                         title: "Email Notifications",
//                         warningMessage:
//                             "You will stop receiving weekly diagnostic summaries and digital reports via email.",
//                         updateState: (newVal) =>
//                             setState(() => emailNotifications = newVal),
//                       );
//                     },
//                   ),
//                   _buildToggleCard(
//                     title: "SMS Emergency Alerts",
//                     subtitle: "Important critical updates via SMS",
//                     icon: Icons.sms_outlined,
//                     value: smsNotifications,
//                     onChanged: (val) {
//                       _handleToggleChange(
//                         key: 'pref_sms',
//                         currentValue: smsNotifications,
//                         title: "SMS Emergency Alerts",
//                         warningMessage:
//                             "Critical hemoglobin level warnings and urgent care SMS reminders will be disabled.",
//                         updateState: (newVal) =>
//                             setState(() => smsNotifications = newVal),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 24),
//                   _buildSectionHeader("Health & Care Schedule"),
//                   _buildToggleCard(
//                     title: "Hemoglobin Scan Due Alerts",
//                     subtitle: "Remind me when my next Hb test is due",
//                     icon: Icons.bloodtype_outlined,
//                     value: scanReminders,
//                     onChanged: (val) {
//                       _handleToggleChange(
//                         key: 'pref_scan',
//                         currentValue: scanReminders,
//                         title: "Scan Due Alerts",
//                         warningMessage:
//                             "Your scheduled scan reminders will not pop up. You will need to check the Reminders screen manually to track your upcoming tests.",
//                         updateState: (newVal) =>
//                             setState(() => scanReminders = newVal),
//                       );
//                     },
//                   ),
//                   _buildToggleCard(
//                     title: "Supplement & Dose Reminders",
//                     subtitle: "Timely alerts for Iron & Vitamin intake",
//                     icon: Icons.medication_outlined,
//                     value: supplementReminders,
//                     onChanged: (val) {
//                       _handleToggleChange(
//                         key: 'pref_supplement',
//                         currentValue: supplementReminders,
//                         title: "Supplement Reminders",
//                         warningMessage:
//                             "Timely dose prompts for Iron and Vitamin supplements will be muted.",
//                         updateState: (newVal) =>
//                             setState(() => supplementReminders = newVal),
//                       );
//                     },
//                   ),
//                   _buildToggleCard(
//                     title: "Daily Health Insights",
//                     subtitle: "Anemia management tips & lifestyle advice",
//                     icon: Icons.lightbulb_outline,
//                     value: healthTips,
//                     onChanged: (val) {
//                       _handleToggleChange(
//                         key: 'pref_tips',
//                         currentValue: healthTips,
//                         title: "Health Insights",
//                         warningMessage:
//                             "Daily anemia management tips and lifestyle recommendation alerts will be turned off.",
//                         updateState: (newVal) =>
//                             setState(() => healthTips = newVal),
//                       );
//                     },
//                   ),

//                   const SizedBox(height: 32),

//                   // Action Buttons Section
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: _resetToDefault,
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(color: Colors.indigo.shade200),
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: Text(
//                             "Reset Default",
//                             style: TextStyle(
//                               color: Colors.indigo.shade800,
//                               fontWeight: FontWeight.w600,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: _saveAllChanges,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.indigo,
//                             elevation: 0,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           child: const Text(
//                             "Save Settings",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 36),
//                   const Center(
//                     child: Column(
//                       children: [
//                         Text(
//                           "Aura v2.4.1",
//                           style: TextStyle(
//                             color: Colors.grey,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         SizedBox(height: 2),
//                         Text(
//                           "Encrypted Healthcare Data Security",
//                           style: TextStyle(color: Colors.grey, fontSize: 11),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 4, bottom: 12),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 15,
//           color: Colors.grey.shade700,
//           letterSpacing: 0.3,
//         ),
//       ),
//     );
//   }

//   Widget _buildToggleCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//   }) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: value ? Colors.indigo.shade50 : Colors.grey.shade100,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               icon,
//               color: value ? Colors.indigo : Colors.grey.shade500,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 15,
//                     color: value ? Colors.black : Colors.grey.shade700,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     color: Colors.grey.shade600,
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Switch(
//             value: value,
//             onChanged: onChanged,
//             activeColor: Colors.indigo,
//           ),
//         ],
//       ),
//     );
//   }
// }

