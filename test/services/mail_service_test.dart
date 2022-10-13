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

  MailPiece mail = new MailPiece("", "", today, "", "test", "");

  setUpAll(() async {
    await setUpTestDatabase();
  });

  setUp(() async {
    final db = await database;
    // Clear the table.
    await db.execute("""
      DELETE FROM $MAIL_PIECE_TABLE;
    """);

    final data = {
      "id": mail.id,
      "email_id": mail.emailId,
      "sender": mail.sender,
      "image_text": mail.imageText,
      "timestamp": mail.timestamp.millisecondsSinceEpoch,
      "midId": mail.midId
    };
    try {
      await db.insert(MAIL_PIECE_TABLE, data);
      return true;
    } catch (_) {
      return false;
    }
  });

  test("Search mail by keyword", () async{
    var mailSearch = new MailSearchParameters("test", null, today);
    var test = await search.fetchMail(mailSearch);
    expect(1, test.length);
  });

  test("Search mail by keyword no match", () async{
    var mailSearch = new MailSearchParameters("testtest", null, today);
    var test = await search.fetchMail(mailSearch);
    expect(0, test.length);
  });

  test("Search mail by keyword null", () async{
    var mailSearch = new MailSearchParameters(null, null, null);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date range", () async{
    var mailSearch = new MailSearchParameters(null, today.add(Duration(days: -1)), today);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by single date", () async{
    var mailSearch = new MailSearchParameters(null, today, today);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date range start today", () async{
    var mailSearch = new MailSearchParameters(null, today, today.add(Duration(days: 1)));
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date range none", () async{
    var mailSearch = new MailSearchParameters(null, today.add(Duration(days: -3)), today.add(Duration(days: -2)));
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 0);
  });

  test("Search mail by date null start", () async {
    var mailSearch = new MailSearchParameters(null, null, today);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail by date null end", () async {
    var mailSearch = new MailSearchParameters(null, today, null);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });

  test("Search mail exception",  () async {
    var mailSearch = new MailSearchParameters(null, null, null);
    var test = await search.fetchMail(mailSearch);
    expect(test.length, 1);
  });
}
