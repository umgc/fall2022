import '../models/MailPiece.dart';

/// The `MailNotifier` class manages OS notifications based on a set
/// of notification criteria generated on the Notification page of the
/// application.
class MailNotifier {
  /// Check whether the piece of mail matches any notifications, and if
  /// so, generate or update the existing OS notification.
  void notify(MailPiece piece) {
    //todo: scan mail piece for matching notification subscriptions
    //todo: save notification if matched
  }
}