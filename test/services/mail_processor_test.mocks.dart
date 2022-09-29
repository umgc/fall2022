// Mocks generated by Mockito 5.3.2 from annotations
// in summer2022/test/services/mail_processor_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:summer2022/models/MailPiece.dart' as _i4;
import 'package:summer2022/models/NotificationSubscription.dart' as _i6;
import 'package:summer2022/services/mail_fetcher.dart' as _i2;
import 'package:summer2022/services/mail_notifier.dart' as _i5;
import 'package:summer2022/services/mail_storage.dart' as _i7;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDateTime_0 extends _i1.SmartFake implements DateTime {
  _FakeDateTime_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [MailFetcher].
///
/// See the documentation for Mockito's code generation for more information.
class MockMailFetcher extends _i1.Mock implements _i2.MailFetcher {
  @override
  _i3.Future<List<_i4.MailPiece>> fetchMail(DateTime? lastTimestamp, String? username, String? password) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchMail,
          [lastTimestamp],
        ),
        returnValue: _i3.Future<List<_i4.MailPiece>>.value(<_i4.MailPiece>[]),
        returnValueForMissingStub:
            _i3.Future<List<_i4.MailPiece>>.value(<_i4.MailPiece>[]),
      ) as _i3.Future<List<_i4.MailPiece>>);
}

/// A class which mocks [MailNotifier].
///
/// See the documentation for Mockito's code generation for more information.
class MockMailNotifier extends _i1.Mock implements _i5.MailNotifier {
  @override
  _i3.Future<bool> createSubscription(
          _i6.NotificationSubscription? subscription) =>
      (super.noSuchMethod(
        Invocation.method(
          #createSubscription,
          [subscription],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
  @override
  _i3.Future<void> removeSubscription(
          _i6.NotificationSubscription? subscription) =>
      (super.noSuchMethod(
        Invocation.method(
          #removeSubscription,
          [subscription],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
  @override
  _i3.Future<void> updateNotifications(DateTime? lastTimestamp) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateNotifications,
          [lastTimestamp],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);
}

/// A class which mocks [MailStorage].
///
/// See the documentation for Mockito's code generation for more information.
class MockMailStorage extends _i1.Mock implements _i7.MailStorage {
  @override
  _i3.Future<DateTime> get lastTimestamp => (super.noSuchMethod(
        Invocation.getter(#lastTimestamp),
        returnValue: _i3.Future<DateTime>.value(_FakeDateTime_0(
          this,
          Invocation.getter(#lastTimestamp),
        )),
        returnValueForMissingStub: _i3.Future<DateTime>.value(_FakeDateTime_0(
          this,
          Invocation.getter(#lastTimestamp),
        )),
      ) as _i3.Future<DateTime>);
  @override
  _i3.Future<bool> saveMailPiece(_i4.MailPiece? piece) => (super.noSuchMethod(
        Invocation.method(
          #saveMailPiece,
          [piece],
        ),
        returnValue: _i3.Future<bool>.value(false),
        returnValueForMissingStub: _i3.Future<bool>.value(false),
      ) as _i3.Future<bool>);
}
