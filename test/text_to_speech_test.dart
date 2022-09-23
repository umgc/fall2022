import 'package:enough_mail/enough_mail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/models/Address.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/main.dart';
import 'dart:io' as io;

class FakeFlutterTts extends Fake implements FlutterTts {
  @override
  Future<dynamic> awaitSpeakCompletion(bool? awaitCompletion) {
    return Future.value(true);
  }

  @override
  Future<dynamic> speak(String? text) {
    print(text);
    return Future.value(1);
  }

  @override
  Future<dynamic> setLanguage(String? language) {
    return Future.value(true);
  }

  @override
  Future<dynamic> setSpeechRate(double? rate) {
    return Future.value(true);
  }

  @override
  Future<dynamic> setVolume(double? volume) {
    return Future.value(true);
  }

  @override
  Future<dynamic> setPitch(double? pitch) {
    return Future.value(true);
  }
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;
  AddressObject address1 = AddressObject.fromJson({
    "type": "sender",
    "name": "GEICO",
    "address": "2563 Forest Dr; Annapolis, MD 21401",
    "validated": false
  });
  AddressObject address2 = AddressObject.fromJson({
    "type": "recipient",
    "name": "Deborah Keenan",
    "address": "1006 Morgan Station Dr; Severn, MD 21144-1245",
    "validated": true
  });
  MailResponse mail = MailResponse.fromJson({
    "addresses": [
      {
        "type": "sender",
        "name": "GEICO",
        "address": "2563 Forest Dr; Annapolis, MD 21401",
        "validated": false
      },
      {
        "type": "recipient",
        "name": "Deborah Keenan",
        "address": "1006 Morgan Station Dr; Severn, MD 21144-1245",
        "validated": true
      }
    ],
    "logos": [
      {"name": "GEICO"},
      {"name": "GEICO"}
    ],
    "codes": [
      {"type": "url", "info": "https://geico.com"}
    ]
  });

  late MimeMessage email;

  MimeMessage buildMessage() {
    final builder = MessageBuilder.prepareMultipartAlternativeMessage(
      plainText: 'hello world.',
      htmlText: '<p>hello <b>world</b></p>',
    )
      ..from = [MailAddress('My name', 'sender@domain.com')]
      ..to = [MailAddress('Your name', 'recipient@domain.com')]
      ..subject = 'My first message'
      ..text = 'Hi how are you';
    return builder.buildMimeMessage();
  }

  setUp(() async {
    GlobalConfiguration cfg = GlobalConfiguration();
    await cfg.loadFromAsset("app_settings");
    // tts = FakeFlutterTts();
    email = buildMessage();
  });

  TestWidgetsFlutterBinding.ensureInitialized();

  // group("ReadDigestMail Tests", () {
  //
  //   test("set/getSenderAndRecipient", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     AddressObject returnedAddress1 = AddressObject();
  //     AddressObject returnedAddress2 = AddressObject();
  //     try {
  //       readMail.setSenderAndRecipient([address1, address2]);
  //       var addresses = readMail.getSenderAndRecipient();
  //       returnedAddress1 = addresses[0];
  //       returnedAddress2 = addresses[1];
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //     expect(readMail.sender, address1);
  //     expect(readMail.recipient, address2);
  //     expect(returnedAddress1, address1);
  //     expect(returnedAddress2, address2);
  //   });
  //
  //   test("Read All Digest Info", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestInfo();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Sender Name", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestSenderName();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Recipient Name", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestRecipientName();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Sender Address", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestSenderAddress();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Recipient Address", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestRecipientAddress();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Logos", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestLogos();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Links", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestLinks();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Sender Address Validated", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestSenderAddressValidated();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Digest Recipient Address Validated", () {
  //     String error = '';
  //     ReadDigestMail readMail = ReadDigestMail();
  //     readMail.setCurrentMail(mail);
  //     try {
  //       readMail.readDigestRecipientAddressValidated();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  // });
  //
  // group("ReadMail Tests", () {
  //   test("Read All Email Info", () {
  //     String error = '';
  //     ReadMail readMail = ReadMail();
  //     readMail.setCurrentMail(email);
  //     try {
  //       readMail.readEmailInfo();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Sender", () {
  //     String error = '';
  //     ReadMail readMail = ReadMail();
  //     readMail.setCurrentMail(email);
  //     try {
  //       readMail.readEmailSender();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Subject", () {
  //     String error = '';
  //     ReadMail readMail = ReadMail();
  //     readMail.setCurrentMail(email);
  //     try {
  //       readMail.readEmailSubject();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Text", () {
  //     String error = '';
  //     ReadMail readMail = ReadMail();
  //     readMail.setCurrentMail(email);
  //     try {
  //       readMail.readEmailText();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  //
  //   test("Read Recipients", () {
  //     String error = '';
  //     ReadMail readMail = ReadMail();
  //     readMail.setCurrentMail(email);
  //     try {
  //       readMail.readEmailRecipients();
  //     } catch (e) {
  //       error = e.toString();
  //     }
  //     expect(error, '');
  //   });
  // });
}
