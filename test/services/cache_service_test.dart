import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:summer2022/models/MailPiece.dart';

import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/services/mail_fetcher.dart';
import 'package:summer2022/services/mail_notifier.dart';
import 'package:summer2022/services/mail_storage.dart';

@GenerateNiceMocks([
  MockSpec<MailFetcher>(),
  MockSpec<MailNotifier>(),
  MockSpec<MailStorage>()
])
import 'mail_processor_test.mocks.dart';

void main() {
  final fetcher = MockMailFetcher();
  final notifier = MockMailNotifier();
  final storage = MockMailStorage();
  final username = "test";
  final password = "test";

  final subject = CacheService(fetcher, storage, notifier, username, password);

  final now = DateTime.now();

  test('it processes mail', () async {
    final mailPieces = [
      MailPiece("1", "test-1", now, "test", "some text", "test"),
      MailPiece("2", "test-2", now, "test", "some text", "test"),
      MailPiece("3", "test-3", now, "test", "some text", "test"),
    ];

    when(fetcher.fetchMail(any, any, any)).thenAnswer((_) => Future.value(mailPieces));
    when(storage.saveMailPiece(any)).thenAnswer((_) => Future.value(true));
    when(storage.lastTimestamp).thenAnswer((_) => Future.value(now));

    await subject.fetchAndProcessLatestMail();

    verify(storage.saveMailPiece(mailPieces[0]));
    verify(storage.saveMailPiece(mailPieces[1]));
    verify(storage.saveMailPiece(mailPieces[2]));
    verify(notifier.updateNotifications(now));
  });
}
