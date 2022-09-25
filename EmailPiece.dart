import 'dart:core';
import 'package:enough_mail/enough_mail.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/Digest.dart';

class EmailPiece {
  String EmailPieceID; // Unique ID of Image
  String EmailID; // Unique ID of Email - made from Email contents hashed
  DateTime EmailPieceTimestamp;
  String EmailPieceSender;
  String EmailPieceImageText;
  String MID_ID;
  EmailPiece(this.EmailPieceID, this.EmailID, this.EmailPieceTimestamp,
      this.EmailPieceSender, this.EmailPieceImageText, this.MID_ID);

  returnEmailPieceID()
  {
    return EmailPieceID;
  }

  returnEmailID()
  {
    return EmailID;
  }

  returnEmailPieceTimeStamp()
  {
    return EmailPieceTimestamp;
  }

  returnEmailPieceSender()
  {
    return EmailPieceSender;
  }

  returnEmailPieceImageText()
  {
    return EmailPieceImageText;
  }

  returnMID_ID()
  {
    return MID_ID;
  }

  setMID_ID(String newMID_ID)
  {
    MID_ID = newMID_ID;
  }
}

