import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/exceptions/fetch_mail_exception.dart';
import 'package:summer2022/services/mail_service.dart';

void main() async {
  final search = MailService();

  DateTime now = DateTime.now();

  DateTime today = new DateTime(now.year, now.month, now.day);

  List<MailPiece> mail = <MailPiece>[
    new MailPiece("", "", "", "", "test", today),
    new MailPiece("", "", "", "", "", DateTime.now().add(Duration(days: 1)))
  ];

  test("Search mail by keyword", () {
    String error = '';
    try {
      List<MailPiece> test = search.getMailByKeyword(mail, "test");
      expect(1, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by keyword no match", () {
    String error = '';
    try {
      List<MailPiece> test = search.getMailByKeyword(mail, "testtest");
      expect(0, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by keyword null", () {
    String error = '';
    try {
      List<MailPiece> test = search.getMailByKeyword(mail, null);
      expect(2, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by date range", () {
    String error = '';
    try {
      List<MailPiece> test =
          search.getMailByDate(mail, today.add(Duration(days: -1)), today);
      expect(1, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by single date", () {
    String error = '';
    try {
      List<MailPiece> test = search.getMailByDate(mail, today, today);
      expect(1, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by date range all", () {
    String error = '';
    try {
      List<MailPiece> test =
          search.getMailByDate(mail, today, today.add(Duration(days: 1)));
      expect(2, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by date range none", () {
    String error = '';
    try {
      List<MailPiece> test = search.getMailByDate(
          mail, today.add(Duration(days: -2)), today.add(Duration(days: -1)));
      expect(0, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by date null start", () {
    String error = '';
    try {
      List<MailPiece> test =
          search.getMailByDate(mail, null, today.add(Duration(days: -1)));
      expect(2, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail by date null end", () {
    String error = '';
    try {
      List<MailPiece> test = search.getMailByDate(mail, today, null);
      expect(2, test.length);
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  test("Search mail exception", () {
    String error = '';
    try {
      var test =  search.fetchMail(null, null, null);
      expect(test, throwsA(TypeMatcher<FetchMailException>()));
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });
}
