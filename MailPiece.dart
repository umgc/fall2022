import 'dart:core';
import 'package:enough_mail/enough_mail.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/Digest.dart';

class MailPiece {
  String ID; // Unique ID of Image
  String MailID; // Unique ID of Email - made from Email contents hashed
  DateTime Timestamp;
  String Sender;
  String ImageText;
  String MID_ID;
  MailPiece(this.ID, this.MailID, this.Timestamp,
      this.Sender, this.ImageText, this.MID_ID);
}
