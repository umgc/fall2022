import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/exceptions/fetch_mail_exception.dart';
import 'package:summer2022/services/mail_service.dart';

void main() async {
  final search = MailService();

  DateTime today = DateTime.now();

  MailPieceTemp mail = new MailPieceTemp("", "", "", "", "test", today);

  test("Search mail by keyword", () {
    bool result = search.matchesKeyword(mail, "test");
    expect(true, result);
  });

  test("Search mail by keyword no match", () {
    bool result = search.matchesKeyword(mail, "testtest");
    expect(false, result);
  });

  test("Search mail by keyword null", () {
    bool result = search.matchesKeyword(mail, null);
    expect(true, result);
  });

  test("Search mail by date range", () {
    bool result =
        search.isWithinDateRange(mail, today.add(Duration(days: -1)), today);
    expect(true, result);
  });

  test("Search mail by single date", () {
    bool result = search.isWithinDateRange(mail, today, today);
    expect(true, result);
  });

  test("Search mail by date range", () {
    bool result =
        search.isWithinDateRange(mail, today, today.add(Duration(days: 1)));
    expect(true, result);
  });

  test("Search mail by date range none", () {
    bool result = search.isWithinDateRange(
        mail, today.add(Duration(days: -2)), today.add(Duration(days: -1)));
    expect(false, result);
  });

  test("Search mail by date null start", () {
    bool result =
        search.isWithinDateRange(mail, null, today.add(Duration(days: -1)));
    expect(true, result);
  });

  test("Search mail by date null end", () {
    bool result = search.isWithinDateRange(mail, today, null);
    expect(true, result);
  });

  test("Search mail exception", () {
    var test = search.fetchMail(null, null, null);
    expect(test, throwsA(TypeMatcher<FetchMailException>()));
  });
}
