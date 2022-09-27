import 'dart:core';
import 'package:enough_mail/enough_mail.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/Digest.dart';

class MailPiece {
  final String ID; // Unique ID of Image
  final String MailID; // Unique ID of Email - made from Email contents hashed
  final DateTime Timestamp;
  final String Sender;
  final String ImageText;
  final String MID_ID;
  MailPiece(this.ID, this.MailID, this.Timestamp,
      this.Sender, this.ImageText, this.MID_ID);
}

