import 'dart:core';
import 'package:enough_mail/enough_mail.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/Digest.dart';

class MailPiece {
  String? id; // Unique ID of Image
  final String mailId; // Unique ID of Email - made from Email contents hashed
  final DateTime timestamp;
  final String sender;
  final String imageText;
  final String midId;

  MailPiece(this.id, this.mailId, this.timestamp, this.sender, this.imageText,
      this.midId);
  MailPiece.fromEmail(
      this.mailId, this.timestamp, this.sender, this.imageText, this.midId);

  factory MailPiece.fromJson(dynamic json) {
    return MailPiece(
        json['id'] as String,
        json['mailId'] as String,
        json['timeStamp'] as DateTime,
        json['sender'] as String,
        json['imageText'] as String,
        json['midId'] as String
        );
  }
}
