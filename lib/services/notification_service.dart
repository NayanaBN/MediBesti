import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder_model.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);
  }

  Future<void> scheduleReminders(List<ReminderModel> reminders) async {
    int id = 0;
    await _notifications.cancelAll();

    for (final reminder in reminders) {
      for (final time in reminder.times) {
        final now = DateTime.now();
        final scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
        final adjusted = scheduledDate.isBefore(now)
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate;

        final tzTime = tz.TZDateTime.from(adjusted, tz.local);

        await _notifications.zonedSchedule(
          id++,
          'Medicine Reminder',
          'It\'s time to take: ${reminder.medicineName}',
          tzTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'medibesti_channel',
              'Medicine Reminders',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
