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

  CacheService(this._fetcher, this._storage, this._notifier);

  /// Builds a default CacheService and uses it to fetch the latest mail.
  static Future<void> updateMail(String? username, String? password) async {
    await CacheService(MailFetcher(username, password), MailStorage(), MailNotifier())
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
}
