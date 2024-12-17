import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialization for local notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
    print("NotificationHelper initialized successfully.");
  }

  // Show notification for pledged gifts
  static Future<void> showGiftNotification(
      Map<String, dynamic> giftData) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'pledged_gift_channel', // Channel ID
      'Pledged Gifts', // Channel name
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // Extract details from the gift data
    final friendName = giftData['friend_name'] ?? 'A friend'; // Friend's name
    final giftName = giftData['name'] ?? 'a gift'; // Gift name
    final eventName =
        giftData['event_name'] ?? 'an event'; // Event name (optional)

    // Show the notification
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique notification ID
      "Pledged Gift: $giftName", // Notification title
      "$friendName has pledged $giftName for your event!", // Notification body
      notificationDetails,
    );
    print("Notification shown: $giftName pledged by $friendName");
  }

  // Optional: Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    print("All notifications have been cancelled.");
  }
}
