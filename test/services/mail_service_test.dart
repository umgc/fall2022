import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/exceptions/fetch_mail_exception.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/models/MailSearchParameters.dart';
import 'package:summer2022/services/mail_service.dart';
import 'package:summer2022/services/sqlite_database.dart';

void main() async {
  final search = MailService();

  DateTime now = DateTime.now();
  DateTime today = new DateTime(now.year, now.month, now.day);

  var mailPieces = <MailPiece>[
    new MailPiece("", "", today, "sender", "test", "", ""),
    new MailPiece("", "", today, "empty", "empty", "", "")
  ];

  setUpAll(() async {
    await setUpTestDatabase();
  });

  setUp(() async {
    final db = await database;
    // Clear the table.
    await db.execute("""
      DELETE FROM $MAIL_PIECE_TABLE;
    """);

    try {
      for (var mail in mailPieces) {
        await db.insert(MAIL_PIECE_TABLE, {
          "id": mail.id,
          "email_id": mail.emailId,
          "sender": mail.sender,
          "image_text": mail.imageText,
          "timestamp": mail.timestamp.millisecondsSinceEpoch,
          "scanImgCID": mail.scanImgCID,
          "uspsMID": mail.uspsMID,
        });
      }

      return true;
    } catch (_) {
      return false;
    }
  });

  test("Search mail by keyword", () async {
    var mailSearch = new MailSearchParameters(keyword: "test", endDate: today);
    var test = await search.fetchMail(mailSearch);
    expect(1, test.length);
  });

  test("Search mail by keyword no match", () async {
    var mailSearch =
        new MailSearchParameters(keyword: "testtest", endDate: today);
    var test = await search.fetchMail(mailSearch);
    expect(0, test.length);
  });

  test("Search mail by keyword null", () async {
    var mailSearch = new MailSearchParameters();
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date range", () async {
    var mailSearch = new MailSearchParameters(
        startDate: today.add(Duration(days: -1)), endDate: today);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by single date", () async {
    var mailSearch = new MailSearchParameters(startDate: today, endDate: today);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date range start today", () async {
    var mailSearch = new MailSearchParameters(
        startDate: today, endDate: today.add(Duration(days: 1)));
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date range none", () async {
    var mailSearch = new MailSearchParameters(
        startDate: today.add(Duration(days: -3)),
        endDate: today.add(Duration(days: -2)));
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 0);
  });

  test("Search mail by date null start", () async {
    var mailSearch = new MailSearchParameters(endDate: today);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date null end", () async {
    var mailSearch = new MailSearchParameters(startDate: today);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail exception", () async {
    var mailSearch = new MailSearchParameters();
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail sender", () async {
    var mailSearch = new MailSearchParameters(senderKeyword: "sender");
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail body", () async {
    var mailSearch = new MailSearchParameters(mailBodyKeyword: "test");
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail sender and body no results", () async {
    var mailSearch = new MailSearchParameters(
        senderKeyword: "sender", mailBodyKeyword: "no match");
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 0);
  });

  test("Search mail sender and body", () async {
    var mailSearch = new MailSearchParameters(
        senderKeyword: "sender", mailBodyKeyword: "test");
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });
}
