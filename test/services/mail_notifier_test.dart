import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/models/NotificationSubscription.dart';
import 'package:summer2022/models/Notification.dart';
import 'package:summer2022/services/mail_notifier.dart';
import 'package:summer2022/services/sqlite_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MailNotifier subject = MailNotifier();

  DateTime now = DateTime.now();
  DateTime lastTimestamp = now.subtract(Duration(days: 1));

  setUpAll(() async {
    await setUpTestDatabase();
  });

  setUp(() async {
    final db = await database;
    // Clear the table.
    await db.execute("""
      DELETE FROM $NOTIFICATION_TABLE;
      DELETE FROM $NOTIFICATION_SUBSCRIPTION_TABLE;
      DELETE FROM $MAIL_PIECE_TABLE;
    """);
  });

  group("when managing subscriptions", () {
    test('it can create a new notification subscription', () async {
      final subscription = NotificationSubscription("test");

      expect(await subject.createSubscription(subscription), true);

      await _expectSubscriptionCount(1);
      await _expectSubscriptionExists(subscription);
    });

    test('it can create multiple subscriptions', () async {
      final subscriptionOne = NotificationSubscription("test-one");
      final subscriptionTwo = NotificationSubscription("test-two");

      expect(await subject.createSubscription(subscriptionOne), true);
      expect(await subject.createSubscription(subscriptionTwo), true);

      await _expectSubscriptionCount(2);
      await _expectSubscriptionExists(subscriptionOne);
      await _expectSubscriptionExists(subscriptionTwo);
    });

    test('it does not create duplicate subscriptions', () async {
      final subscription = NotificationSubscription("test");
      final duplicate = NotificationSubscription("test");

      expect(await subject.createSubscription(subscription), true);
      expect(await subject.createSubscription(duplicate), false);

      await _expectSubscriptionCount(1);
      await _expectSubscriptionExists(subscription);
    });

    test('it can delete a subscription', () async {
      final subscriptionOne = NotificationSubscription("test-one");
      final subscriptionTwo = NotificationSubscription("test-two");

      expect(await subject.createSubscription(subscriptionOne), true);
      expect(await subject.createSubscription(subscriptionTwo), true);

      await _expectSubscriptionCount(2);
      await _expectSubscriptionExists(subscriptionOne);
      await _expectSubscriptionExists(subscriptionTwo);

      await subject.removeSubscription(subscriptionOne);
      await _expectSubscriptionCount(1);
      await _expectSubscriptionDoesNotExist(subscriptionOne);
      await _expectSubscriptionExists(subscriptionTwo);
    });

    test('it can delete a subscription that does not exist', () async {
      final subscription = NotificationSubscription("test");

      // This should not throw an exception.
      await subject.removeSubscription(subscription);
    });

    test('it can retrieve all notifications', () async {
      final subscriptionOne = NotificationSubscription("test-one");
      final subscriptionTwo = NotificationSubscription("test-two");

      expect(await subject.createSubscription(subscriptionOne), true);
      expect(await subject.createSubscription(subscriptionTwo), true);

      final subscriptions = await subject.getSubscriptions();

      expect(subscriptions.length, 2);
      expect(subscriptions, containsAll([subscriptionOne, subscriptionTwo]));
    });

    group("and deleting a subscrition", () {
      test('it deletes associated notifications', () async {
        await _createMailPiece(
            "test-one", "someone", "test something one", now);
        await _createMailPiece(
            "test-two", "someone", "test something two", now);
        final subscriptionOne = NotificationSubscription("test");
        final subscriptionTwo = NotificationSubscription("something");
        await subject.createSubscription(subscriptionOne);
        await subject.createSubscription(subscriptionTwo);

        await subject.updateNotifications(lastTimestamp);

        await _expectNotificationCount(4);
        await _expectNotificationExists("test-one", subscriptionOne.keyword);
        await _expectNotificationExists("test-two", subscriptionOne.keyword);
        await _expectNotificationExists("test-one", subscriptionTwo.keyword);
        await _expectNotificationExists("test-two", subscriptionTwo.keyword);

        await subject.removeSubscription(subscriptionOne);

        await _expectNotificationCount(2);
        await _expectNotificationDoesNotExist(
            "test-one", subscriptionOne.keyword);
        await _expectNotificationDoesNotExist(
            "test-two", subscriptionOne.keyword);
        await _expectNotificationExists("test-one", subscriptionTwo.keyword);
        await _expectNotificationExists("test-two", subscriptionTwo.keyword);
      });
    });
  });

  group("when processing new mail", () {
    test('it does not create a notification without a subscription', () async {
      await _createMailPiece("test", "someone", "test", now);

      await subject.updateNotifications(lastTimestamp);

      await _expectNotificationCount(0);
    });

    test('it can create a notification', () async {
      await _createMailPiece("test", "someone", "test", now);
      final subscription = NotificationSubscription("test");
      await subject.createSubscription(subscription);

      await subject.updateNotifications(lastTimestamp);

      await _expectNotificationCount(1);
      await _expectNotificationExists("test", subscription.keyword);
    });

    test('it can create multiple notifications for different mail pieces',
        () async {
      await _createMailPiece("test-one", "someone", "test one", now);
      await _createMailPiece("test-two", "test", "some image text", now);
      final subscription = NotificationSubscription("test");
      await subject.createSubscription(subscription);

      await subject.updateNotifications(lastTimestamp);

      await _expectNotificationCount(2);
      await _expectNotificationExists("test-one", subscription.keyword);
      await _expectNotificationExists("test-two", subscription.keyword);
    });

    test('it can create multiple notifications for different subscriptions',
        () async {
      await _createMailPiece("test", "someone", "test something", now);
      final subscriptionOne = NotificationSubscription("test");
      final subscriptionSomething = NotificationSubscription("something");
      await subject.createSubscription(subscriptionOne);
      await subject.createSubscription(subscriptionSomething);

      await subject.updateNotifications(lastTimestamp);

      await _expectNotificationCount(2);
      await _expectNotificationExists("test", subscriptionOne.keyword);
      await _expectNotificationExists("test", subscriptionSomething.keyword);
    });

    test('it does not create a notification for past mail pieces', () async {
      await _createMailPiece("test", "someone", "test", lastTimestamp);
      final subscription = NotificationSubscription("test");
      await subject.createSubscription(subscription);

      await subject.updateNotifications(now);

      await _expectNotificationCount(0);
    });
  });

  group('when managing notifications', () {
    setUp(() async {
      await _createMailPiece("test-one", "someone", "test something", now);
      await _createMailPiece("test-two", "someone", "test something", now);
      final subscriptionOne = NotificationSubscription("test");
      final subscriptionSomething = NotificationSubscription("something");
      await subject.createSubscription(subscriptionOne);
      await subject.createSubscription(subscriptionSomething);
      await subject.updateNotifications(lastTimestamp);
      await _expectNotificationCount(4);
    });

    test('it can retrieve all notifications', () async {
      final notifications = await subject.getNotifications();
      expect(notifications.length, 4);
      expect(
          notifications,
          containsAll([
            Notification("test-one", "test",0),
            Notification("test-one", "something",0),
            Notification("test-two", "test",0),
            Notification("test-two", "something",0),
          ]));
    });

    test('it can clear a notification', () async {
      await subject.clearNotification(Notification("test-one", "something",0));
      final notifications = await subject.getNotifications();
      expect(notifications.length, 0);
      expect(
          notifications,
          containsAll([
            Notification("test-one", "test",0),
            Notification("test-two", "test",0),
            Notification("test-two", "something",0),
          ]));
    });

    test('it can clear all notifications', () async {
      await subject.clearAllNotifications();
      final notifications = await subject.getNotifications();
      expect(notifications.length, 0);
    });
  });
}

//
// Helper functions
//

Future<void> _expectSubscriptionCount(int count) async {
  final db = await database;
  final results = await db.query(NOTIFICATION_SUBSCRIPTION_TABLE);
  expect(results.length, count);
}

Future<void> _expectSubscriptionExists(
    NotificationSubscription subscription) async {
  final db = await database;
  final results = await db.query(NOTIFICATION_SUBSCRIPTION_TABLE,
      where: "keyword = ?", whereArgs: [subscription.keyword]);
  expect(results.length, 1);
  expect(results[0]["keyword"], subscription.keyword);
}

Future<void> _expectSubscriptionDoesNotExist(
    NotificationSubscription subscription) async {
  final db = await database;
  final results = await db.query(NOTIFICATION_SUBSCRIPTION_TABLE,
      where: "keyword = ?", whereArgs: [subscription.keyword]);
  expect(results.length, 0);
}

Future<void> _createMailPiece(
    String id, String sender, String imageText, DateTime timestamp) async {
  final db = await database;
  final data = {
    "id": id,
    "email_id": "some-email-id",
    "sender": sender,
    "image_text": imageText,
    "timestamp": timestamp.millisecondsSinceEpoch
  };
  await db.insert(MAIL_PIECE_TABLE, data);
}

Future<void> _expectNotificationCount(int count) async {
  final db = await database;
  final results = await db.query(NOTIFICATION_TABLE);
  expect(results.length, count);
}

Future<void> _expectNotificationExists(
    String mail_piece_id, String subscription_keyword) async {
  final db = await database;
  final results = await db.query(NOTIFICATION_TABLE,
      where: "mail_piece_id = ? AND subscription_keyword = ?",
      whereArgs: [mail_piece_id, subscription_keyword]);
  expect(results.length, 1);
}

Future<void> _expectNotificationDoesNotExist(
    String mail_piece_id, String subscription_keyword) async {
  final db = await database;
  final results = await db.query(NOTIFICATION_TABLE,
      where: "mail_piece_id = ? AND subscription_keyword = ?",
      whereArgs: [mail_piece_id, subscription_keyword]);
  expect(results.length, 0);
}
