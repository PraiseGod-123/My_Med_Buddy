// lib/services/notification_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/medication_model.dart';
import '../models/appointment_model.dart';
import '../models/health_log_model.dart';

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  bool _initialized = false;

  // Notification channels
  static const String _medicationChannelId = 'medication_reminders';
  static const String _appointmentChannelId = 'appointment_reminders';
  static const String _healthLogChannelId = 'health_log_reminders';
  static const String _generalChannelId = 'general_notifications';

  // Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize timezones
    tz.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _initialized = true;
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Medication reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _medicationChannelId,
          'Medication Reminders',
          description: 'Notifications for medication reminders',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      // Appointment reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _appointmentChannelId,
          'Appointment Reminders',
          description: 'Notifications for appointment reminders',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      // Health log reminders channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _healthLogChannelId,
          'Health Log Reminders',
          description: 'Notifications for health log reminders',
          importance: Importance.defaultImportance,
          enableVibration: true,
          playSound: true,
        ),
      );

      // General notifications channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _generalChannelId,
          'General Notifications',
          description: 'General app notifications',
          importance: Importance.defaultImportance,
          enableVibration: true,
          playSound: true,
        ),
      );
    }
  }

  // Handle notification taps
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload);
        _handleNotificationAction(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  // Handle notification actions
  void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'];
    final id = data['id'];

    switch (type) {
      case 'medication':
        _handleMedicationNotification(id);
        break;
      case 'appointment':
        _handleAppointmentNotification(id);
        break;
      case 'health_log':
        _handleHealthLogNotification(id);
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  void _handleMedicationNotification(String medicationId) {
    // Navigate to medication details or show quick action dialog
    debugPrint('Medication notification tapped: $medicationId');
  }

  void _handleAppointmentNotification(String appointmentId) {
    // Navigate to appointment details
    debugPrint('Appointment notification tapped: $appointmentId');
  }

  void _handleHealthLogNotification(String logId) {
    // Navigate to health log screen
    debugPrint('Health log notification tapped: $logId');
  }

  // Request permissions
  Future<bool> requestPermissions() async {
    if (Platform.isIOS) {
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();

      if (iosPlugin != null) {
        final result = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return result ?? false;
      }
    } else if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final result = await androidPlugin.requestNotificationsPermission();
        return result ?? false;
      }
    }
    return false;
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        final result = await androidPlugin.areNotificationsEnabled();
        return result ?? false;
      }
    }
    return true; // iOS doesn't have a direct method to check this
  }

  // Schedule medication reminder
  Future<void> scheduleMedicationReminder(
    MedicationModel medication,
    DateTime scheduledTime, {
    String? customMessage,
  }) async {
    if (!_initialized) await initialize();

    final notificationId = _generateNotificationId(
      medication.id,
      scheduledTime,
    );

    final title = customMessage ?? 'Medication Reminder';
    final body = 'Time to take ${medication.name} (${medication.dosage})';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _medicationChannelId,
          'Medication Reminders',
          channelDescription: 'Notifications for medication reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          actions: [
            const AndroidNotificationAction(
              'taken',
              'Mark as Taken',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'skip',
              'Skip',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'medication',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: jsonEncode({
        'type': 'medication',
        'id': medication.id,
        'scheduledTime': scheduledTime.toIso8601String(),
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Schedule multiple medication reminders
  Future<void> scheduleMedicationReminders(MedicationModel medication) async {
    if (!medication.isActive) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Schedule for the next 30 days
    for (int day = 0; day < 30; day++) {
      final date = today.add(Duration(days: day));

      // Skip if medication has ended
      if (medication.endDate != null && date.isAfter(medication.endDate!)) {
        break;
      }

      for (final timeStr in medication.times) {
        final parts = timeStr.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        // Only schedule future notifications
        if (scheduledTime.isAfter(now)) {
          await scheduleMedicationReminder(medication, scheduledTime);
        }
      }
    }
  }

  // Cancel medication reminders
  Future<void> cancelMedicationReminders(String medicationId) async {
    if (!_initialized) await initialize();

    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        try {
          final data = jsonDecode(notification.payload!);
          if (data['type'] == 'medication' && data['id'] == medicationId) {
            await _flutterLocalNotificationsPlugin.cancel(notification.id);
          }
        } catch (e) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    }
  }

  // Schedule appointment reminder
  Future<void> scheduleAppointmentReminder(
    AppointmentModel appointment, {
    int reminderMinutes = 30,
    String? customMessage,
  }) async {
    if (!_initialized) await initialize();

    final appointmentDateTime = appointment.dateTime;
    final reminderTime = appointmentDateTime.subtract(
      Duration(minutes: reminderMinutes),
    );

    // Don't schedule if reminder time is in the past
    if (reminderTime.isBefore(DateTime.now())) return;

    final notificationId = _generateNotificationId(
      appointment.id,
      reminderTime,
    );

    final title = customMessage ?? 'Appointment Reminder';
    final body =
        'Appointment with ${appointment.doctorName} in $reminderMinutes minutes';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(reminderTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _appointmentChannelId,
          'Appointment Reminders',
          channelDescription: 'Notifications for appointment reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          actions: [
            const AndroidNotificationAction(
              'view',
              'View Details',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'reschedule',
              'Reschedule',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'appointment',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: jsonEncode({
        'type': 'appointment',
        'id': appointment.id,
        'scheduledTime': appointmentDateTime.toIso8601String(),
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancel appointment reminder
  Future<void> cancelAppointmentReminder(String appointmentId) async {
    if (!_initialized) await initialize();

    final pendingNotifications = await _flutterLocalNotificationsPlugin
        .pendingNotificationRequests();

    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        try {
          final data = jsonDecode(notification.payload!);
          if (data['type'] == 'appointment' && data['id'] == appointmentId) {
            await _flutterLocalNotificationsPlugin.cancel(notification.id);
          }
        } catch (e) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    }
  }

  // Schedule daily health log reminder
  Future<void> scheduleDailyHealthLogReminder({
    TimeOfDay? reminderTime,
    String? customMessage,
  }) async {
    if (!_initialized) await initialize();

    final time =
        reminderTime ?? const TimeOfDay(hour: 20, minute: 0); // 8 PM default
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const notificationId = 9999; // Fixed ID for daily reminder

    final title = customMessage ?? 'Daily Health Log';
    const body = 'How are you feeling today? Log your health status.';

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _healthLogChannelId,
          'Health Log Reminders',
          channelDescription: 'Notifications for health log reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          actions: [
            const AndroidNotificationAction(
              'log',
              'Log Now',
              showsUserInterface: true,
            ),
            const AndroidNotificationAction(
              'later',
              'Remind Later',
              showsUserInterface: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: 'health_log',
          interruptionLevel: InterruptionLevel.passive,
        ),
      ),
      payload: jsonEncode({
        'type': 'health_log',
        'id': 'daily_reminder',
        'scheduledTime': scheduledTime.toIso8601String(),
      }),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel daily health log reminder
  Future<void> cancelDailyHealthLogReminder() async {
    if (!_initialized) await initialize();
    await _flutterLocalNotificationsPlugin.cancel(9999);
  }

  // Show immediate notification
  Future<void> showImmediateNotification({
    required String title,
    required String body,
    String? payload,
    NotificationChannel channel = NotificationChannel.general,
  }) async {
    if (!_initialized) await initialize();

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
      100000,
    );

    await _flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _getChannelId(channel),
          _getChannelName(channel),
          channelDescription: _getChannelDescription(channel),
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: payload,
    );
  }

  // Show medication adherence notification
  Future<void> showAdherenceNotification({
    required String medicationName,
    required int streakDays,
    required double adherenceRate,
  }) async {
    String title;
    String body;

    if (adherenceRate >= 0.9) {
      title = 'Great Job! 🎉';
      body =
          'You\'ve maintained ${adherenceRate.toStringAsFixed(0)}% adherence with $medicationName for $streakDays days!';
    } else if (adherenceRate >= 0.7) {
      title = 'Keep It Up! 👍';
      body =
          'You\'re doing well with $medicationName. Current adherence: ${adherenceRate.toStringAsFixed(0)}%';
    } else {
      title = 'Medication Reminder';
      body =
          'Don\'t forget to take $medicationName regularly for best results.';
    }

    await showImmediateNotification(
      title: title,
      body: body,
      channel: NotificationChannel.medication,
    );
  }

  // Show health tip notification
  Future<void> showHealthTipNotification({
    required String tip,
    String? category,
  }) async {
    final title = category != null
        ? 'Health Tip - ${category.toUpperCase()}'
        : 'Health Tip';

    await showImmediateNotification(
      title: title,
      body: tip,
      channel: NotificationChannel.general,
    );
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Get active notifications (Android only)
  Future<List<ActiveNotification>> getActiveNotifications() async {
    if (!_initialized) await initialize();

    if (Platform.isAndroid) {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        return await androidPlugin.getActiveNotifications();
      }
    }
    return [];
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int notificationId) async {
    if (!_initialized) await initialize();
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  // Reschedule all medication reminders
  Future<void> rescheduleAllMedicationReminders(
    List<MedicationModel> medications,
  ) async {
    // Cancel all existing medication reminders
    final pendingNotifications = await getPendingNotifications();
    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        try {
          final data = jsonDecode(notification.payload!);
          if (data['type'] == 'medication') {
            await cancelNotification(notification.id);
          }
        } catch (e) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    }

    // Schedule new reminders
    for (final medication in medications) {
      if (medication.isActive) {
        await scheduleMedicationReminders(medication);
      }
    }
  }

  // Check if a specific medication has pending reminders
  Future<bool> hasPendingMedicationReminders(String medicationId) async {
    final pendingNotifications = await getPendingNotifications();

    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        try {
          final data = jsonDecode(notification.payload!);
          if (data['type'] == 'medication' && data['id'] == medicationId) {
            return true;
          }
        } catch (e) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    }
    return false;
  }

  // Get medication reminder count
  Future<int> getMedicationReminderCount(String medicationId) async {
    int count = 0;
    final pendingNotifications = await getPendingNotifications();

    for (final notification in pendingNotifications) {
      if (notification.payload != null) {
        try {
          final data = jsonDecode(notification.payload!);
          if (data['type'] == 'medication' && data['id'] == medicationId) {
            count++;
          }
        } catch (e) {
          debugPrint('Error parsing notification payload: $e');
        }
      }
    }
    return count;
  }

  // Helper methods
  int _generateNotificationId(String id, DateTime scheduledTime) {
    // Create a unique ID based on medication ID and scheduled time
    final idHash = id.hashCode;
    final timeHash = scheduledTime.millisecondsSinceEpoch;
    return (idHash + timeHash).remainder(2147483647); // Max int32 value
  }

  String _getChannelId(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.medication:
        return _medicationChannelId;
      case NotificationChannel.appointment:
        return _appointmentChannelId;
      case NotificationChannel.healthLog:
        return _healthLogChannelId;
      case NotificationChannel.general:
        return _generalChannelId;
    }
  }

  String _getChannelName(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.medication:
        return 'Medication Reminders';
      case NotificationChannel.appointment:
        return 'Appointment Reminders';
      case NotificationChannel.healthLog:
        return 'Health Log Reminders';
      case NotificationChannel.general:
        return 'General Notifications';
    }
  }

  String _getChannelDescription(NotificationChannel channel) {
    switch (channel) {
      case NotificationChannel.medication:
        return 'Notifications for medication reminders';
      case NotificationChannel.appointment:
        return 'Notifications for appointment reminders';
      case NotificationChannel.healthLog:
        return 'Notifications for health log reminders';
      case NotificationChannel.general:
        return 'General app notifications';
    }
  }

  // Test notification
  Future<void> testNotification() async {
    await showImmediateNotification(
      title: 'Test Notification',
      body: 'This is a test notification from MyMedBuddy.',
      channel: NotificationChannel.general,
    );
  }
}

// Notification channel enum
enum NotificationChannel { medication, appointment, healthLog, general }

// Notification data model
class NotificationData {
  final String type;
  final String id;
  final DateTime scheduledTime;
  final Map<String, dynamic>? additionalData;

  NotificationData({
    required this.type,
    required this.id,
    required this.scheduledTime,
    this.additionalData,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'scheduledTime': scheduledTime.toIso8601String(),
    'additionalData': additionalData,
  };

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      type: json['type'],
      id: json['id'],
      scheduledTime: DateTime.parse(json['scheduledTime']),
      additionalData: json['additionalData'],
    );
  }
}

// Notification permission helper
class NotificationPermissionHelper {
  static Future<PermissionStatus> checkPermissionStatus() async {
    final notificationService = NotificationService();
    final isEnabled = await notificationService.areNotificationsEnabled();
    return isEnabled ? PermissionStatus.granted : PermissionStatus.denied;
  }

  static Future<PermissionStatus> requestPermission() async {
    final notificationService = NotificationService();
    final granted = await notificationService.requestPermissions();
    return granted ? PermissionStatus.granted : PermissionStatus.denied;
  }
}

enum PermissionStatus { granted, denied, permanentlyDenied, restricted }

// Notification settings model
class NotificationSettings {
  final bool medicationReminders;
  final bool appointmentReminders;
  final bool healthLogReminders;
  final bool generalNotifications;
  final TimeOfDay dailyReminderTime;
  final int defaultReminderMinutes;

  NotificationSettings({
    this.medicationReminders = true,
    this.appointmentReminders = true,
    this.healthLogReminders = true,
    this.generalNotifications = true,
    this.dailyReminderTime = const TimeOfDay(hour: 20, minute: 0),
    this.defaultReminderMinutes = 30,
  });

  NotificationSettings copyWith({
    bool? medicationReminders,
    bool? appointmentReminders,
    bool? healthLogReminders,
    bool? generalNotifications,
    TimeOfDay? dailyReminderTime,
    int? defaultReminderMinutes,
  }) {
    return NotificationSettings(
      medicationReminders: medicationReminders ?? this.medicationReminders,
      appointmentReminders: appointmentReminders ?? this.appointmentReminders,
      healthLogReminders: healthLogReminders ?? this.healthLogReminders,
      generalNotifications: generalNotifications ?? this.generalNotifications,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      defaultReminderMinutes:
          defaultReminderMinutes ?? this.defaultReminderMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'medicationReminders': medicationReminders,
    'appointmentReminders': appointmentReminders,
    'healthLogReminders': healthLogReminders,
    'generalNotifications': generalNotifications,
    'dailyReminderTime':
        '${dailyReminderTime.hour}:${dailyReminderTime.minute}',
    'defaultReminderMinutes': defaultReminderMinutes,
  };

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final timeParts = json['dailyReminderTime'].split(':');
    return NotificationSettings(
      medicationReminders: json['medicationReminders'] ?? true,
      appointmentReminders: json['appointmentReminders'] ?? true,
      healthLogReminders: json['healthLogReminders'] ?? true,
      generalNotifications: json['generalNotifications'] ?? true,
      dailyReminderTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      defaultReminderMinutes: json['defaultReminderMinutes'] ?? 30,
    );
  }
}
