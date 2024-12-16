import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification plugin
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await notificationsPlugin.initialize(initializationSettings);
  }

  /// Show a notification
  static Future<void> showGiftNotification(
      Map<String, dynamic> giftData) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'gift_notifications',
      'Gift Notifications',
      channelDescription: 'Notifications for pledged gifts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0, // Notification ID
      'New Gift Pledged!',
      '${giftData['name']} has been pledged in your event.',
      platformDetails,
      payload: giftData['id'], // Pass gift ID as payload
    );
  }
}
