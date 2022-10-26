import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:summer2022/models/MailPiece.dart';

import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/services/mail_fetcher.dart';
import 'package:summer2022/services/mail_notifier.dart';
import 'package:summer2022/services/mailPiece_storage.dart';

@GenerateNiceMocks([
  MockSpec<MailFetcher>(),
  MockSpec<MailNotifier>(),
  MockSpec<MailPieceStorage>()
])
import 'cache_service_test.mocks.dart';

void main() {
  final fetcher = MockMailFetcher();
  final notifier = MockMailNotifier();
  final storage = MockStorage();

  final subject = CacheService(fetcher, storage, notifier);

  final now = DateTime.now();

  test('it processes mail', () async {
    final mailPieces = [
      MailPiece("1", "test-1", now, "test", "some text", "test", "test"),
      MailPiece("2", "test-2", now, "test", "some text", "test", "test"),
      MailPiece("3", "test-3", now, "test", "some text", "test", "test"),
    ];

    when(fetcher.fetchMail(any)).thenAnswer((_) => Future.value(mailPieces));
    when(storage.saveMailPiece(any)).thenAnswer((_) => Future.value(true));
    when(storage.lastTimestamp).thenAnswer((_) => Future.value(now));

    await subject.fetchAndProcessLatestMail();

    verify(storage.saveMailPiece(mailPieces[0]));
    verify(storage.saveMailPiece(mailPieces[1]));
    verify(storage.saveMailPiece(mailPieces[2]));
    verify(notifier.updateNotifications(now));
  });

  test('deletes all cached data from notifier and storage', () async {
    when(storage.deleteAllMailPieces()).thenAnswer((_) => Future.value(true));
    when(notifier.clearAllNotifications())
        .thenAnswer((_) => Future.value(null));
    when(notifier.clearAllSubscriptions())
        .thenAnswer((_) => Future.value(null));

    await subject.clearAllCachedData();

    verify(storage.deleteAllMailPieces());
    verify(notifier.clearAllNotifications());
    verify(notifier.clearAllSubscriptions());
  });
}

class MockStorage extends MockMailPieceStorage {
  @override
  Future<bool> saveMailPiece(MailPiece? piece) {
    return super.saveMailPiece(piece);
  }
}
