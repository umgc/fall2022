import 'package:summer2022/services/sqlite_database.dart';

import '../models/Notification.dart';
import '../models/NotificationSubscription.dart';

/// The `MailNotifier` class manages OS notifications based on a set
/// of notification criteria generated on the Notification page of the
/// application.
class MailNotifier {
  /// Create a new notification subscription, if one does not already exist.
  Future<bool> createSubscription(NotificationSubscription subscription) async {
    final db = await database;
    final data = {"keyword": subscription.keyword};
    try {
      await db.insert(NOTIFICATION_SUBSCRIPTION_TABLE, data);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Remove a notification subscription, if it exists. Otherwise, do nothing.
  Future<void> removeSubscription(NotificationSubscription subscription) async {
    final db = await database;
    await db.delete(NOTIFICATION_SUBSCRIPTION_TABLE,
        where: "keyword = ?", whereArgs: [subscription.keyword]);
  }

  Future<List<Notification>> getNotifications() async {
    // TODO: Implement this.
    return [];
  }

  /// Clears the notification from the list.
  Future<void> clearNotification(Notification notification) async {
    // TODO: Implement this.
  }

  /// Clears all notifications.
  Future<void> clearAllNotifications() async {
    // TODO: Implement this.
  }

  /// Checks all mail recieved after the provided timestamp against the list of
  /// notification subscriptions. If there are any matches, new notification
  /// objects are created and stored.
  Future<void> updateNotifications(DateTime lastTimestamp) async {
    final db = await database;
    await db.execute("""
      INSERT INTO $NOTIFICATION_TABLE
      SELECT
        mail_piece.id as mail_piece_id,
        subscription.keyword as subscription_keyword
      FROM $MAIL_PIECE_TABLE as mail_piece
      JOIN $NOTIFICATION_SUBSCRIPTION_TABLE as subscription ON 
        mail_piece.image_text LIKE '%' || subscription.keyword || '%'
        OR mail_piece.sender LIKE '%' || subscription.keyword || '%'
      WHERE mail_piece.timestamp > ${lastTimestamp.millisecondsSinceEpoch};
    """);
  }
}
