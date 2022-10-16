import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/models/MailResponse.dart';

import 'mail_fetcher.dart';
import 'mail_notifier.dart';
import 'mail_storage.dart';

/// The `CacheService` is the mechanism the application uses to ingest new
/// pieces of mail. This should be configured to run on start-up and scheduled
/// to run periodically.
class CacheService {
  late MailFetcher _fetcher;
  late MailStorage _storage;
  late MailNotifier _notifier;

  static CacheService? _instance = null;

  CacheService(this._fetcher, this._storage, this._notifier);

  static CacheService getInstance(String? username, String? password) {
    if (_instance == null) {
      _instance = CacheService(
          MailFetcher(username, password), MailStorage(), MailNotifier());
    }
    return _instance!;
  }

  /// Builds a default CacheService and uses it to fetch the latest mail.
  static Future<void> updateMail(String? username, String? password) async {
    await CacheService.getInstance(username, password)
        .fetchAndProcessLatestMail();
  }

  /// Fetches mail since the last time a piece of mail was received, and then
  /// stores and processes that mail, making it available to the application and
  /// updating notifications.
  Future<void> fetchAndProcessLatestMail() async {
    final lastTimestamp = await _storage.lastTimestamp;
    for (final piece in await _fetcher.fetchMail(lastTimestamp)) {
      await _storage.saveMailPiece(piece);
    }
    await _notifier.updateNotifications(lastTimestamp);
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
    await MailStorage().saveMailPiece(piece);
  }

  static Future<void> clearEverything() async {
    await CacheService.getInstance(null, null).clearAllCachedData();
  }

  Future<void> clearAllCachedData() async {
    _storage.deleteAllMailPieces();
    _notifier.clearAllNotifications();
    _notifier.clearAllSubscriptions();
  }
}
