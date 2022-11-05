import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final _notificationPlugin = FlutterLocalNotificationsPlugin();

  Future<void> setup() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        linux: initializationSettingsLinux);
    await _notificationPlugin.initialize(initializationSettings);
  }

  Future<void> displayNotificationForNewMailPieces(int numNotifications) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'usps-informed-delivery', 'notifications-recieved',
            channelDescription:
                'Notifications for USPS Informed Delivery emails.',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Mail Speak');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await _notificationPlugin.show(
        0,
        'New Mail Pieces',
        'You have $numNotifications new mail piece notifications available.',
        notificationDetails);
  }
}
