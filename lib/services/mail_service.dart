import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:enough_mail/enough_mail.dart';
import 'package:summer2022/exceptions/fetch_mail_exception.dart';
import 'package:summer2022/models/Digest.dart';

/// todo: remove this once mailpiece class is properly implemented
class MailPiece {
  String ID;
  String EmailID;
  DateTime TimeStamp = new DateTime(2022, 1, 1);
  String Sender;
  String MidID;
  String ImageText;

  MailPiece(this.ID, this.EmailID, this.MidID, this.ImageText, this.Sender,
      this.TimeStamp);

  factory MailPiece.fromJson(dynamic json) {
    return MailPiece(
        json['ID'] as String,
        json['EmailID'] as String,
        json['MidID'] as String,
        json['ImageText'] as String,
        json['Sender'] as String,
        json['TimeStamp'] as DateTime);
  }
}

class MailService {
  /// Location of mail data file
  String mailData = "";

  Future<File> get _localFile async {
    return File(mailData);
  }

  /// Retrieves all mail from local cache that matches [keyword] or is within [startDate] and [endDate]
  /// [startDate] and [endDate] should either both have values or both be null
  /// throws a [FetchMailException] error if file retrieval, parsing, or filtering fails
  Future<List> fetchMail(
      String? keyword, DateTime? startDate, DateTime? endDate) async {
    try {
      final jsonMail = await _localFile;

      final mailParsed = await jsonMail.readAsString();

      var mailList = jsonDecode(mailParsed) as List;

      List<MailPiece> mailObjs =
          mailList.map((x) => MailPiece.fromJson(x)).toList();

      List<MailPiece> mail = <MailPiece>[...mailObjs];

      mail = getMailByKeyword(getMailByDate(mail, startDate, endDate), keyword);

      return mail;
    } catch (e) {
      throw new FetchMailException(e.toString());
    }
  }

  /// returns items from [mail] that match [keyword]
  List<MailPiece> getMailByKeyword(List<MailPiece> mail, String? keyword) {
    return mail
        .where((x) =>
            x.Sender.contains(keyword ?? "") ||
            x.ImageText.contains(keyword ?? ""))
        .toList();
  }

  /// returns items from [mail] with a timestamp within [startDate] and [endDate]
  List<MailPiece> getMailByDate(
      List<MailPiece> mail, DateTime? startDate, DateTime? endDate) {
    //if either value is null, both should be null and the filter should not be applied
    if (startDate == null || endDate == null) {
      return mail;
    }

    //set to 1 millisecond before midnight of given day
    DateTime convertedStartDate =
        new DateTime(startDate.year, startDate.month, startDate.day)
            .add(Duration(milliseconds: -1));

    //set to 1 millisecond before midnight of next day
    DateTime convertedEndDate =
        new DateTime(endDate.year, endDate.month, endDate.day)
            .add(Duration(days: 1, milliseconds: -1));

    return mail
        .where((x) =>
            (x.TimeStamp.isAfter(convertedStartDate)) &&
            (x.TimeStamp.isBefore(convertedEndDate)))
        .toList();
  }
}
