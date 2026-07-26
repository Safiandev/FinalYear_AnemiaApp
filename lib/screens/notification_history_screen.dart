import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotificationItem {
  final String id;
  final String title;
  final String body;
  final String timestamp;
  bool isRead;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'timestamp': timestamp,
        'isRead': isRead,
      };

  factory AppNotificationItem.fromJson(Map<String, dynamic> json) =>
      AppNotificationItem(
        id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: json['title'] ?? '',
        body: json['body'] ?? '',
        timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
        isRead: json['isRead'] ?? false,
      );
}

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  SharedPreferences? _prefs;
  List<AppNotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Real-time relative time formatting (Dynamic TimeAgo)
  String _getTimeAgo(String? timestampStr) {
    if (timestampStr == null || timestampStr.isEmpty) return "Just now";

    // Agar pehle se hi friendly string ho (like "Just now", "Yesterday")
    if (timestampStr == "Just now" ||
        timestampStr == "Yesterday" ||
        timestampStr.contains("ago")) {
      return timestampStr;
    }

    try {
      DateTime notificationTime = DateTime.parse(timestampStr);
      Duration diff = DateTime.now().difference(notificationTime);

      if (diff.inSeconds < 60) {
        return "Just now";
      } else if (diff.inMinutes < 60) {
        return "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        return "${diff.inHours}h ago";
      } else if (diff.inDays == 1) {
        return "Yesterday";
      } else if (diff.inDays < 7) {
        return "${diff.inDays}d ago";
      } else {
        return "${notificationTime.day}/${notificationTime.month}/${notificationTime.year}";
      }
    } catch (_) {
      return timestampStr;
    }
  }

  Future<void> _loadNotifications() async {
    _prefs = await SharedPreferences.getInstance();
    String? storedData = _prefs?.getString('app_notification_history');

    if (storedData != null && storedData.isNotEmpty) {
      try {
        List<dynamic> jsonList = jsonDecode(storedData);
        setState(() {
          _notifications = jsonList
              .map((item) => AppNotificationItem.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } catch (e) {
        _setSampleNotifications();
      }
    } else {
      _setSampleNotifications();
    }
  }

  void _setSampleNotifications() {
    DateTime now = DateTime.now();
    setState(() {
      _notifications = [
        AppNotificationItem(
          id: '1',
          title: 'Welcome to Hemoglobe AI',
          body:
              'Track your hemoglobin, manage supplements, and schedule test alerts easily.',
          timestamp: now.toIso8601String(),
          isRead: false,
        ),
        AppNotificationItem(
          id: '2',
          title: 'Hemoglobin Test Due',
          body: 'Your next routine hemoglobin assessment is scheduled soon.',
          timestamp: now.subtract(const Duration(hours: 2)).toIso8601String(),
          isRead: false,
        ),
        AppNotificationItem(
          id: '3',
          title: 'Dietary Tip',
          body:
              'Combine Vitamin C with Iron supplements for maximum absorption rate.',
          timestamp: now.subtract(const Duration(days: 1)).toIso8601String(),
          isRead: true,
        ),
      ];
      _isLoading = false;
    });
    _saveNotifications();
  }

  Future<void> _saveNotifications() async {
    if (_prefs == null) return;
    List<Map<String, dynamic>> jsonList =
        _notifications.map((e) => e.toJson()).toList();
    await _prefs!.setString('app_notification_history', jsonEncode(jsonList));
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isRead = true;
      }
    });
    _saveNotifications();
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
    _saveNotifications();
  }

  @override
  Widget build(BuildContext context) {
    bool hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Notifications Center",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_notifications.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'read_all') {
                  _markAllAsRead();
                } else if (value == 'clear_all') {
                  _clearAll();
                }
              },
              itemBuilder: (BuildContext context) => [
                if (hasUnread)
                  const PopupMenuItem(
                    value: 'read_all',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, color: Colors.indigo, size: 20),
                        SizedBox(width: 8),
                        Text("Mark all as read"),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text("Clear all"),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none,
                          size: 70, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "No Notifications",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "You're all caught up!",
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        setState(() {
                          _notifications.removeAt(index);
                        });
                        _saveNotifications();
                      },
                      child: GestureDetector(
                        onTap: () {
                          if (!item.isRead) {
                            setState(() {
                              item.isRead = true;
                            });
                            _saveNotifications();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: item.isRead
                                ? Colors.white
                                : Colors.indigo.shade50.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: item.isRead
                                  ? Colors.grey.shade200
                                  : Colors.indigo.shade200,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: item.isRead
                                    ? Colors.grey.shade200
                                    : Colors.indigo.shade100,
                                child: Icon(
                                  item.isRead
                                      ? Icons.notifications_none
                                      : Icons.notifications_active,
                                  color: item.isRead
                                      ? Colors.grey.shade600
                                      : Colors.indigo,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: item.isRead
                                                  ? Colors.black87
                                                  : Colors.indigo.shade900,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _getTimeAgo(item.timestamp),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.body,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
