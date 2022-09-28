import '../models/MailPiece.dart';
import 'MailFetcher.dart';
import 'MailNotifier.dart';
import 'MailStorage.dart';

class CacheService {

  final MailNotifier _notifier;
  final MailStorage _storage;
  final MailFetcher _fetcher;

  // Default constructor
  CacheService(this._fetcher, this._storage, this._notifier) {  }

  /// Fetches mail since the last time a piece of mail was received, and then
  /// stores and processes that mail, making it available to the application and
  /// updating notifications.
  void fetchAndProcessLatestMail() {
    _fetcher.fetchMail(_storage.LastTimestamp).listen(_processPiece);
  }

  /// Process an individual piece of mail, storing it and and updating any
  /// notifications.
  void _processPiece(MailPiece piece) {
    if (_storage.save(piece)) {
      _notifier.notify(piece);
    }
  }
}