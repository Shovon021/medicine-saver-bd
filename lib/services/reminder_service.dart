import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Service for managing medicine reminders.
class ReminderService {
  static final ReminderService instance = ReminderService._init();
  static const String _storageKey = 'medicine_reminders';
  
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  SharedPreferences? _prefs;
  List<MedicineReminder> _reminders = [];
  bool _isInitialized = false;
  
  ReminderService._init();

  /// Get all reminders.
  List<MedicineReminder> get reminders => List.unmodifiable(_reminders);

  /// Initialize the notification service.
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone properly
    tz_data.initializeTimeZones();
    // Set local timezone based on device's offset
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    final hours = offset.inHours;
    final sign = hours >= 0 ? '+' : '-';
    final tzName = 'Etc/GMT${sign == '+' ? '-' : '+'}${hours.abs()}'; // Note: Etc/GMT uses inverted signs
    try {
      tz.setLocalLocation(tz.getLocation(tzName));
    } catch (e) {
      // Fallback to UTC if timezone not found
      tz.setLocalLocation(tz.UTC);
    }
    debugPrint('🕐 Timezone initialized: ${tz.local.name}, Device offset: ${offset.inHours}h');


    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request permissions on Android 13+
    await _requestPermissions();

    // Load saved reminders
    _prefs = await SharedPreferences.getInstance();
    await _loadReminders();
    
    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      // Request notification permission (Android 13+)
      await android.requestNotificationsPermission();
      // Request exact alarm permission (Android 12+)
      await android.requestExactAlarmsPermission();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - could navigate to reminder details
  }

  /// Schedule a new reminder.
  Future<MedicineReminder?> scheduleReminder({
    required String medicineName,
    required String dosage,
    required ReminderTime time,
    required List<int> daysOfWeek, // 1=Monday, 7=Sunday
    String? notes,
  }) async {
    try {
      final reminder = MedicineReminder(
        id: DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF, // Mask to 31 bits for Android compatibility
        medicineName: medicineName,
        dosage: dosage,
        hour: time.hour,
        minute: time.minute,
        daysOfWeek: daysOfWeek,
        notes: notes,
        isActive: true,
      );

      // Schedule notifications for each day
      for (final day in daysOfWeek) {
        try {
          await _scheduleWeeklyNotification(reminder, day);
        } catch (e) {
          // Continue even if one day fails
          debugPrint('Failed to schedule notification for day $day: $e');
        }
      }

      _reminders.add(reminder);
      await _saveReminders();
      return reminder;
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      return null;
    }
  }

  /// Schedule a weekly notification for a specific day.
  Future<void> _scheduleWeeklyNotification(MedicineReminder reminder, int dayOfWeek) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hour,
      reminder.minute,
    );

    // Adjust to the correct day of week
    while (scheduledDate.weekday != dayOfWeek) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Handle time that has passed
    if (scheduledDate.isBefore(now)) {
      // If time passed within last 2 minutes, schedule for 10 seconds from now
      final timeDiff = now.difference(scheduledDate).inMinutes;
      if (timeDiff < 2) {
        scheduledDate = now.add(const Duration(seconds: 10));
      } else {
        // Time significantly passed, schedule for next week
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }
    }

    final notificationId = (reminder.id + dayOfWeek) & 0x7FFFFFFF;
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    // Debug: Log what we're scheduling
    debugPrint('📅 Scheduling notification:');
    debugPrint('   Now: $now');
    debugPrint('   Scheduled: $scheduledDate');
    debugPrint('   TZ Scheduled: $tzScheduledDate');
    debugPrint('   ID: $notificationId');

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Medicine Reminder',
      'Time to take ${reminder.medicineName} (${reminder.dosage})',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_reminders_v2',
          'Medicine Reminders',
          channelDescription: 'Notifications for medicine reminders',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock, // Most reliable for alarms
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel a reminder. Returns true if successful.
  Future<bool> cancelReminder(int reminderId) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index == -1) return false;
      
      final reminder = _reminders[index];
      
      // Cancel all scheduled notifications for this reminder
      for (final day in reminder.daysOfWeek) {
        await _notifications.cancel((reminderId + day) & 0x7FFFFFFF);
      }

      _reminders.removeAt(index);
      await _saveReminders();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle reminder active state. Returns error message if failed, null otherwise.
  Future<String?> toggleReminder(int reminderId) async {
    try {
      await init(); // Ensure initialized
      
      final index = _reminders.indexWhere((r) => r.id == reminderId);
      if (index == -1) return 'Reminder not found';

      final reminder = _reminders[index];
      final updatedReminder = reminder.copyWith(isActive: !reminder.isActive);

      if (updatedReminder.isActive) {
        // Reschedule
        for (final day in updatedReminder.daysOfWeek) {
          try {
            await _scheduleWeeklyNotification(updatedReminder, day);
          } catch (e) {
            return 'Schedule error: $e';
          }
        }
      } else {
        // Cancel
        for (final day in reminder.daysOfWeek) {
          try {
            await _notifications.cancel((reminderId + day) & 0x7FFFFFFF);
          } catch (e) {
             return 'Cancel error: $e';
          }
        }
      }

      _reminders[index] = updatedReminder;
      await _saveReminders();
      return null; // Success
    } catch (e) {
      return 'Toggle error: $e';
    }
  }

  /// Load reminders from storage.
  Future<void> _loadReminders() async {
    final String? jsonString = _prefs?.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      _reminders = [];
      return;
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      _reminders = jsonList.map((j) => MedicineReminder.fromJson(j)).toList();
    } catch (e) {
      _reminders = [];
    }
  }

  /// Save reminders to storage.
  Future<void> _saveReminders() async {
    final String jsonString = json.encode(_reminders.map((r) => r.toJson()).toList());
    await _prefs?.setString(_storageKey, jsonString);
  }
}

/// Represents a medicine reminder.
class MedicineReminder {
  final int id;
  final String medicineName;
  final String dosage;
  final int hour;
  final int minute;
  final List<int> daysOfWeek;
  final String? notes;
  final bool isActive;

  MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.hour,
    required this.minute,
    required this.daysOfWeek,
    this.notes,
    this.isActive = true,
  });

  String get timeString {
    final h = hour > 12 ? hour - 12 : hour;
    final amPm = hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $amPm';
  }

  String get daysString {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (daysOfWeek.length == 7) return 'Every day';
    if (daysOfWeek.toSet().containsAll([1, 2, 3, 4, 5]) && daysOfWeek.length == 5) return 'Weekdays';
    if (daysOfWeek.toSet().containsAll([6, 7]) && daysOfWeek.length == 2) return 'Weekends';
    return daysOfWeek.map((d) => dayNames[d - 1]).join(', ');
  }

  MedicineReminder copyWith({
    int? id,
    String? medicineName,
    String? dosage,
    int? hour,
    int? minute,
    List<int>? daysOfWeek,
    String? notes,
    bool? isActive,
  }) {
    return MedicineReminder(
      id: id ?? this.id,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineName': medicineName,
        'dosage': dosage,
        'hour': hour,
        'minute': minute,
        'daysOfWeek': daysOfWeek,
        'notes': notes,
        'isActive': isActive,
      };

  factory MedicineReminder.fromJson(Map<String, dynamic> json) => MedicineReminder(
        id: json['id'] ?? 0,
        medicineName: json['medicineName'] ?? '',
        dosage: json['dosage'] ?? '',
        hour: json['hour'] ?? 8,
        minute: json['minute'] ?? 0,
        daysOfWeek: List<int>.from(json['daysOfWeek'] ?? []),
        notes: json['notes'],
        isActive: json['isActive'] ?? true,
      );
}

/// Helper class for time scheduling (avoids conflict with Flutter's TimeOfDay).
class ReminderTime {
  final int hour;
  final int minute;

  const ReminderTime({required this.hour, required this.minute});
}
