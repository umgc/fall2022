import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/models/MailResponse.dart';

import 'mail_fetcher.dart';
import 'mail_notifier.dart';
import 'mailPiece_storage.dart';
import 'notification_service.dart';

/// The `CacheService` is the mechanism the application uses to ingest new
/// pieces of mail. This should be configured to run on start-up and scheduled
/// to run periodically.
class CacheService {
  late MailFetcher _fetcher;
  late MailPieceStorage _storage;
  late MailNotifier _notifier;

  static CacheService? _instance = null;

  CacheService(this._fetcher, this._storage, this._notifier);

  static CacheService getInstance() {
    if (_instance == null) {
      _instance =
          CacheService(MailFetcher(), MailPieceStorage(), MailNotifier());
    }
    return _instance!;
  }

  /// Builds a default CacheService and uses it to fetch the latest mail.
  static Future<void> updateMail({bool displayNotification = false}) async {
    final numNotifications =
        await CacheService.getInstance().fetchAndProcessLatestMail();

    if (displayNotification && numNotifications > 0) {
      final notificationService = NotificationService();
      await notificationService.setup();
      notificationService.displayNotificationForNewMailPieces(numNotifications);
    }
  }

  /// Fetches mail since the last time a piece of mail was received, and then
  /// stores and processes that mail, making it available to the application and
  /// updating notifications.
  Future<int> fetchAndProcessLatestMail() async {
    final lastTimestamp = await _storage.lastTimestamp;
    for (final piece in await _fetcher.fetchMail(lastTimestamp)) {
      await _storage.saveMailPiece(piece);
    }
    return await _notifier.updateNotifications(lastTimestamp);
  }

  static Future<void> processUploadedMailPiece(MailResponse mail) async {
    final timestamp = DateTime.now();
    final sender = mail.addresses.isNotEmpty
        ? mail.addresses.first.name
        : "Unknown Sender";
    final id = "$sender-$timestamp";
    final text = mail.textAnnotations.isNotEmpty
        ? mail.textAnnotations.first.text ?? ""
        : "";
    final piece = MailPiece(id, "", timestamp, sender, text, "");
    await MailPieceStorage().saveMailPiece(piece);
  }

  static Future<void> clearEverything() async {
    await CacheService.getInstance().clearAllCachedData();
  }

  Future<void> clearAllCachedData() async {
    await _storage.deleteAllMailPieces();
    await _notifier.clearAllNotifications();
    await _notifier.clearAllSubscriptions();
  }
}
