// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   Future<void> initNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

//     // Temporarily comment out scheduling
//     // await scheduleNotifications();

//     // Test with an instant notification
//     await showInstantNotification('App Started', 'Welcome to FitSync!');
//   }

//   Future<void> showInstantNotification(String title, String body) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'fitsync_channel',
//       'FitSync Notifications',
//       channelDescription: 'Notifications for FitSync app',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);

//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       notificationDetails,
//     );
//   }
// }

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Initialize notifications
//   Future<void> initNotifications() async {
//     print('DEBUG: Starting notification initialization...');

//     // Android initialization settings
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     // iOS initialization settings
//     const DarwinInitializationSettings initializationSettingsIOS =
//         DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     // Combine settings for both platforms
//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     // Initialize the plugin
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//     print('DEBUG: Notification plugin initialized.');

//     // Request notification permissions for Android 13+
//     final androidPlugin =
//         _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();
//     await androidPlugin?.requestNotificationsPermission();
//     print('DEBUG: Notification permission requested.');

//     // Skip SCHEDULE_EXACT_ALARM permission request to avoid prompt
//     bool canScheduleExactAlarms = false;

//     // Request permissions for iOS
//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             IOSFlutterLocalNotificationsPlugin>()
//         ?.requestPermissions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//     print('DEBUG: iOS permissions requested.');

//     // Initialize timezone data and schedule notifications
//     try {
//       tz.initializeTimeZones();
//       final location = tz.local;
//       print(
//           'DEBUG: Timezone data initialized. Local timezone: ${location.name}, Current local time: ${tz.TZDateTime.now(location)}');
//       await scheduleNotifications(canScheduleExactAlarms);
//       print('DEBUG: All notifications scheduled successfully.');
//     } catch (e) {
//       print(
//           'DEBUG: Error initializing timezone or scheduling notifications: $e');
//     }

//     // Show an instant notification to confirm initialization
//     await showInstantNotification('App Started', 'Welcome to FitSync!');
//     print('DEBUG: Instant notification shown.');
//   }

//   // Schedule all notifications
//   Future<void> scheduleNotifications(bool canScheduleExactAlarms) async {
//     final location = tz.local;
//     print(
//         'DEBUG: Starting notification scheduling with exact alarms: $canScheduleExactAlarms');

//     // 1. Meal tracking reminders (3 times a day: 8 AM, 1 PM, 6 PM)
//     await _scheduleNotification(
//       id: 1,
//       title: 'Meal Tracking Reminder',
//       body: 'Don’t forget to log your breakfast!',
//       scheduledTime: _nextInstanceOfTime(8),
//       repeat: true,
//       canScheduleExactAlarms: canScheduleExactAlarms,
//     );

//     await _scheduleNotification(
//       id: 2,
//       title: 'Meal Tracking Reminder',
//       body: 'Time to log your lunch!',
//       scheduledTime: _nextInstanceOfTime(13),
//       repeat: true,
//       canScheduleExactAlarms: canScheduleExactAlarms,
//     );

//     await _scheduleNotification(
//       id: 3,
//       title: 'Meal Tracking Reminder',
//       body: 'Log your dinner now!',
//       scheduledTime: _nextInstanceOfTime(18),
//       repeat: true,
//       canScheduleExactAlarms: canScheduleExactAlarms,
//     );

//     // 2. Community interaction reminder (once a day at 10 AM)
//     await _scheduleNotification(
//       id: 4,
//       title: 'Community Check-In',
//       body: 'Join the FitSync community and share your progress!',
//       scheduledTime: _nextInstanceOfTime(10),
//       repeat: true,
//       canScheduleExactAlarms: canScheduleExactAlarms,
//     );

//     // 3. Fitness milestone alert (once a day at 7 PM)
//     await _scheduleNotification(
//       id: 5,
//       title: 'Fitness Milestone',
//       body: 'Congrats! You’re close to your step goal!',
//       scheduledTime: _nextInstanceOfTime(19),
//       repeat: true,
//       canScheduleExactAlarms: canScheduleExactAlarms,
//     );

//     // 4. Health tip (once a day at 9 AM)
//     await _scheduleNotification(
//       id: 6,
//       title: 'Health Tip',
//       body: 'Stay hydrated! Drink water every hour.',
//       scheduledTime: _nextInstanceOfTime(9),
//       repeat: true,
//       canScheduleExactAlarms: canScheduleExactAlarms,
//     );
//   }

//   // Helper method to get next instance of a specific hour today or tomorrow
//   tz.TZDateTime _nextInstanceOfTime(int hour) {
//     final now = tz.TZDateTime.now(tz.local);
//     var scheduled = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//     );
//     if (scheduled.isBefore(now)) {
//       scheduled = scheduled.add(const Duration(days: 1));
//     }
//     return scheduled;
//   }

//   // Helper method to schedule a notification
//   Future<void> _scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required tz.TZDateTime scheduledTime,
//     required bool repeat,
//     required bool canScheduleExactAlarms,
//   }) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'fitsync_channel',
//       'FitSync Notifications',
//       channelDescription: 'Notifications for FitSync app',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const DarwinNotificationDetails iosNotificationDetails =
//         DarwinNotificationDetails();

//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iosNotificationDetails,
//     );

//     print(
//         'DEBUG: Scheduling notification - ID: $id, Title: $title, Time: $scheduledTime, Repeat: $repeat, Exact: $canScheduleExactAlarms');

//     try {
//       if (repeat) {
//         await _flutterLocalNotificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           scheduledTime,
//           notificationDetails,
//           androidScheduleMode: canScheduleExactAlarms
//               ? AndroidScheduleMode.exactAllowWhileIdle
//               : AndroidScheduleMode.inexact,
//           matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
//         );
//       } else {
//         await _flutterLocalNotificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           scheduledTime,
//           notificationDetails,
//           androidScheduleMode: canScheduleExactAlarms
//               ? AndroidScheduleMode.exactAllowWhileIdle
//               : AndroidScheduleMode.inexact,
//         );
//       }
//       print('DEBUG: Notification with ID $id scheduled successfully.');
//     } catch (e) {
//       print('DEBUG: Error scheduling notification with ID $id: $e');
//     }
//   }

//   // Show an instant notification
//   Future<void> showInstantNotification(String title, String body) async {
//     const AndroidNotificationDetails androidNotificationDetails =
//         AndroidNotificationDetails(
//       'fitsync_channel',
//       'FitSync Notifications',
//       channelDescription: 'Notifications for FitSync app',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidNotificationDetails);

//     print('DEBUG: Showing instant notification - Title: $title, Body: $body');
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       notificationDetails,
//     );
//     print('DEBUG: Instant notification shown successfully.');
//   }
// }

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initNotifications() async {
    print('DEBUG: Starting notification initialization...');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print('DEBUG: Notification plugin initialized.');

    final androidPlugin =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    print('DEBUG: Notification permission requested.');

    bool canScheduleExactAlarms = false;

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    print('DEBUG: iOS permissions requested.');

    try {
      tz.initializeTimeZones();
      final location = tz.local;
      print(
          'DEBUG: Timezone data initialized. Local timezone: \${location.name}, Current local time: \${tz.TZDateTime.now(location)}');
      await scheduleNotifications(canScheduleExactAlarms);
      print('DEBUG: All notifications scheduled successfully.');
    } catch (e) {
      print(
          'DEBUG: Error initializing timezone or scheduling notifications: \$e');
    }

    await showInstantNotification('App Started', 'Welcome to FitSync!');
    print('DEBUG: Instant notification shown.');
  }

  Future<void> scheduleNotifications(bool canScheduleExactAlarms) async {
    final location = tz.local;
    print(
        'DEBUG: Starting notification scheduling with exact alarms: \$canScheduleExactAlarms');

    await _scheduleNotification(
      id: 1,
      title: 'Meal Tracking Reminder',
      body: 'Don’t forget to log your breakfast!',
      scheduledTime: _nextInstanceOfTime(8),
      repeat: true,
      canScheduleExactAlarms: canScheduleExactAlarms,
    );

    await _scheduleNotification(
      id: 2,
      title: 'Meal Tracking Reminder',
      body: 'Time to log your lunch!',
      scheduledTime: _nextInstanceOfTime(13),
      repeat: true,
      canScheduleExactAlarms: canScheduleExactAlarms,
    );

    await _scheduleNotification(
      id: 3,
      title: 'Meal Tracking Reminder',
      body: 'Log your dinner now!',
      scheduledTime: _nextInstanceOfTime(18),
      repeat: true,
      canScheduleExactAlarms: canScheduleExactAlarms,
    );

    await _scheduleNotification(
      id: 4,
      title: 'Community Check-In',
      body: 'Join the FitSync community and share your progress!',
      scheduledTime: _nextInstanceOfTime(10),
      repeat: true,
      canScheduleExactAlarms: canScheduleExactAlarms,
    );

    await _scheduleNotification(
      id: 5,
      title: 'Fitness Milestone',
      body: 'Congrats! You’re close to your step goal!',
      scheduledTime: _nextInstanceOfTime(19),
      repeat: true,
      canScheduleExactAlarms: canScheduleExactAlarms,
    );

    await _scheduleNotification(
      id: 6,
      title: 'Health Tip',
      body: 'Stay hydrated! Drink water every hour.',
      scheduledTime: _nextInstanceOfTime(9),
      repeat: true,
      canScheduleExactAlarms: canScheduleExactAlarms,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
    required bool repeat,
    required bool canScheduleExactAlarms,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'fitsync_channel',
      'FitSync Notifications',
      channelDescription: 'Notifications for FitSync app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    print(
        'DEBUG: Scheduling notification - ID: \$id, Title: \$title, Time: \$scheduledTime, Repeat: \$repeat, Exact: \$canScheduleExactAlarms');

    try {
      if (repeat) {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTime,
          notificationDetails,
          androidScheduleMode: canScheduleExactAlarms
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexact,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } else {
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          scheduledTime,
          notificationDetails,
          androidScheduleMode: canScheduleExactAlarms
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexact,
        );
      }
      print('DEBUG: Notification with ID \$id scheduled successfully.');
    } catch (e) {
      print('DEBUG: Error scheduling notification with ID \$id: \$e');
    }
  }

  Future<void> showInstantNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'fitsync_channel',
      'FitSync Notifications',
      channelDescription: 'Notifications for FitSync app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    print('DEBUG: Showing instant notification - Title: \$title, Body: \$body');
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
    print('DEBUG: Instant notification shown successfully.');
  }
}
