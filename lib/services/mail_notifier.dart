import 'package:summer2022/services/notification_service.dart';
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
      print(data);
      print("creating subscription");
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

  /// Retrieve all notification subscriptions from the database.
  Future<List<NotificationSubscription>> getSubscriptions() async {
    final db = await database;
    final result = await db.query(NOTIFICATION_SUBSCRIPTION_TABLE);
    return result
        .map((row) => NotificationSubscription(row["keyword"] as String))
        .toList();
  }

  /// Retrieve all notifications from the database.
  Future<List<Notification>> getNotifications() async {
    final db = await database;
    final result = await db.query(
        NOTIFICATION_TABLE,
        columns: ['mail_piece_id', 'subscription_keyword', 'isCleared'],
        where: 'isCleared = 0',
        );
    return result
        .map((row) => Notification(row["mail_piece_id"] as String,
            row["subscription_keyword"] as String,
          row["isCleared"] as int))
        .toList();
  }

  /// Clears the notification from the list.
  Future<void> clearNotification(Notification notification) async {
    final db = await database;
    await db.update(
      NOTIFICATION_TABLE,
      {
        'isCleared': 1
      },
      where: 'mail_piece_id = ?',
      whereArgs: [notification.mailPieceId],
    );
    final result = await db.query(NOTIFICATION_TABLE);
   print('Result after isCleared is set: $result');
  }

  /// Clears all notifications.
  Future<void> clearAllNotifications() async {
    final db = await database;

    final updatedValue = {
      'isCleared': 1
    };
    await db.update(NOTIFICATION_TABLE, updatedValue);
  }

  /// Clears all notification subscriptions
  Future<void> clearAllSubscriptions() async {
    final db = await database;
    await db.delete(NOTIFICATION_SUBSCRIPTION_TABLE);
  }

  /// Checks all mail received after the provided timestamp against the list of
  /// notification subscriptions. If there are any matches, new notification
  /// objects are created and stored.
  Future<int> updateNotifications(DateTime lastTimestamp) async {
    final db = await database;
    print("query section");
    await db.execute('''
      INSERT INTO $NOTIFICATION_TABLE 
      SELECT
      DISTINCT
        mail_piece.id as mail_piece_id,
        subscription.keyword as subscription_keyword,
        0 as isCleared
      FROM $MAIL_PIECE_TABLE as mail_piece
      JOIN $NOTIFICATION_SUBSCRIPTION_TABLE as subscription ON 
        mail_piece.image_text LIKE '%' || subscription.keyword || '%'
        OR mail_piece.sender LIKE '%' || subscription.keyword || '%'
      WHERE NOT EXISTS (SELECT mail_piece_id FROM $NOTIFICATION_TABLE t1
                                              WHERE t1.mail_piece_id=mail_piece.id)
      AND mail_piece.timestamp > ${lastTimestamp.millisecondsSinceEpoch} limit 10 
''');
    final result = await db.rawQuery("""
      SELECT COUNT(*) as count
      FROM $NOTIFICATION_TABLE
      JOIN $MAIL_PIECE_TABLE ON mail_piece_id = id
      WHERE timestamp > ${lastTimestamp.millisecondsSinceEpoch};
    """);

    return result[0]["count"] as int;
  }
}
