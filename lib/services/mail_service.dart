import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:fall2022/exceptions/fetch_mail_exception.dart';
import 'package:fall2022/models/Digest.dart';
import 'package:fall2022/utility/ComparisonHelpers.dart';

import '../models/MailPiece.dart';

class MailService {
  /// Location of mail data file
  /// todo: set file path in config and pull value from there
  String mailData = "";

  /// Mail data file
  File localFile = new File("");

  /// MailService constructor
  MailService() {
    localFile = File(mailData);
  }

  /// Retrieves all mail from local cache that matches [keyword] or is within [startDate] and [endDate]
  /// [startDate] and [endDate] should either both have values or both be null
  /// throws a [FetchMailException] error if file retrieval, parsing, or filtering fails
  Future<List> fetchMail(
      String? keyword, DateTime? startDate, DateTime? endDate) async {
    try {
      final jsonMail = localFile;

      final mailParsed = await jsonMail.readAsString();

      var mailList = jsonDecode(mailParsed) as List;

      return mailList
          .map((x) => MailPiece.fromJson(x))
          .where((x) => matchesKeyword(x, keyword))
          .where((x) => isWithinDateRange(x, startDate, endDate))
          .toList();
    } catch (e) {
      throw new FetchMailException(e.toString());
    }
  }

  /// returns true if [mail] mail has a sender or imageText value that matches [keyword]
  bool matchesKeyword(MailPiece mail, String? keyword) {
    return mail.sender.containsIgnoreCase(keyword ?? "") ||
        mail.imageText.containsIgnoreCase(keyword ?? "");
  }

  /// returns true if [mail] has a timestamp within [startDate] and [endDate]
  bool isWithinDateRange(
      MailPiece mail, DateTime? startDate, DateTime? endDate) {
    //if either value is null, both should be null and the filter should not be applied
    if (startDate == null || endDate == null) {
      return true;
    }

    //set to 1 millisecond before midnight of given day
    DateTime convertedStartDate =
        new DateTime(startDate.year, startDate.month, startDate.day)
            .add(Duration(milliseconds: -1));

    //set to 1 millisecond before midnight of next day
    DateTime convertedEndDate =
        new DateTime(endDate.year, endDate.month, endDate.day)
            .add(Duration(days: 1, milliseconds: -1));

    return mail.timestamp.isAfter(convertedStartDate) &&
        mail.timestamp.isBefore(convertedEndDate);
  }
}
