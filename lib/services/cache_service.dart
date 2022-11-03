import 'dart:io';

import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/utility/linkwell.dart';

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
    
    await Future.wait([
    for (final piece in await _fetcher.fetchMail(lastTimestamp))
       _storage.saveMailPiece(piece)
    ]);

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
    var links = <String>[];
    var phoneList = <String>[];
    var email = <String>[];

    for (final code in mail.codes) {
      if (code.getType == 'qr') {
        links.add(code.getInfo);
      } else if (code.getType == 'phone') {
        phoneList.add(code.getInfo);
      } else if (code.getType == 'email') {
        email.add(code.getType );
      }
    }

   // String bs = "https://www.google.com hello world 3019990000 or 301-123-1234 and (212)-999-9999";
    LinkWell linkWell = LinkWell(text);

    List<dynamic> linkWellLinks = linkWell.links;
    List<dynamic> linkWellPhone = linkWell.phone;
    for (final link in linkWellLinks) {
      if (link.toString().contains('@')) {
        email.add(link);
      } else {
        links.add(link);
      }
    }

    for (final phone in linkWellPhone) {
      print(phone.toString());
      phoneList.add(phone);
    }
    
    final piece = MailPiece(id, "", timestamp, sender, text, "", "",  links, email, phoneList);
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
