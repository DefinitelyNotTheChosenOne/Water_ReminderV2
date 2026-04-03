import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'water_reminder_channel';
  static const String channelName = 'Water Reminders';
  static const String channelDesc = 'Notifications to drink water';

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.actionId == 'id_drank') {
          // Handle drank action
        }
      },
    );

    // Request permissions for Android 13+
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    // Create the silent background channel
    const AndroidNotificationChannel bgChannel = AndroidNotificationChannel(
      'water_reminder_bg_channel',
      'Background Timer',
      description: 'Used for silent countdown tracking',
      importance: Importance.low, // SILENT BUT VISIBLE
      enableVibration: false,
      playSound: false,
      showBadge: false,
    );

    await androidImplementation?.createNotificationChannel(bgChannel);
  }

  Future<void> requestExactAlarmsPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotification(int intervalMinutes) async {
    try {
      await _notificationsPlugin.cancelAll();

      const androidNotificationDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction('id_drank', 'I Drank',
              showsUserInterface: true),
          AndroidNotificationAction('id_dismiss', 'Dismiss'),
        ],
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        categoryIdentifier: 'water_category',
      );

      const notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      RepeatInterval finalInterval;
      if (intervalMinutes < 60) {
        finalInterval = RepeatInterval.everyMinute;
      } else if (intervalMinutes < 1440) {
        finalInterval = RepeatInterval.hourly;
      } else {
        finalInterval = RepeatInterval.daily;
      }

      // Try scheduling with EXACT timing first. 
      // If it fails (due to missing permissions on Android 12+), 
      // we fallback to INEXACT which is safer and prevents force closes.
      try {
        await _notificationsPlugin.periodicallyShow(
          0,
          'Drink Water!',
          'Staying hydrated keeps you healthy. 💧',
          finalInterval,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        debugPrint('Exact scheduling failed, falling back to inexact: $e');
        await _notificationsPlugin.periodicallyShow(
          0,
          'Drink Water!',
          'Staying hydrated keeps you healthy. 💧',
          finalInterval,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (e) {
      debugPrint('Notification scheduling failed completely: $e');
    }
  }

  Future<void> showInstantNotification(String title, String body) async {
    try {
      const androidNotificationDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
      );
    } catch (e) {
      debugPrint('Instant notification failed: $e');
    }
  }

  Future<void> stopNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
