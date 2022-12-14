import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/cupertino.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/models/MailPiece.dart';

class Digest {
  MimeMessage message = MimeMessage();
  List<Attachment> attachments = [];
  List<Link> links = [];
  List<MailPiece> mailPieces = [];

  Digest([MimeMessage? m]) {
    if(m != null) {
      message = m;
    } else {
      message = MimeMessage();
    }
  }

  bool isNull(){
    if(message.mimeData == null) {
      return true;
    } else {
      return false;
    }

  }
}

class Attachment {
  String attachment = "";
  String attachmentNoFormatting = "";
  late MailResponse detailedInformation;
  String contentID = "";
  String sender = "";
}

class Link {
  String link = "";
  String info = "";
}