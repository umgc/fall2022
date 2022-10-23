import 'package:googleapis/gmail/v1.dart';
import 'package:flutter/cupertino.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/email_processing/gmail_api_service.dart';
import 'package:summer2022/utility/user_auth_service.dart';
import 'package:summer2022/services/mail_utility.dart';
import '../models/MailPiece.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:enough_mail/enough_mail.dart';
import '../models/Digest.dart';

/// The `MailFetcher` class requests new mail from a mail server.
class MailFetcher {

  MailFetcher();

  /// Fetch all pieces of mail since the provided timestamp
  /// from `uspsinformeddelivery@email.informeddelivery.usps.com`
  /// with the subject `Your Daily Digest`.
  Future<List<MailPiece>> fetchMail(DateTime lastTimestamp) async {
    List<MailPiece> mailPieces = <MailPiece>[];
    MailUtility mail = new MailUtility();
    try {
      List<MimeMessage> emails = await mail.getEmailsSince(
          lastTimestamp,
          "uspsinformeddelivery@email.informeddelivery.usps.com",
          "Your Daily Digest");

      // Process each email
      for (final email in emails) {
        try {
          mailPieces.addAll(await _processEmail(email));
        } catch (e) {
          print("Unable to process individual email.");
        }
      }
    } catch (e) {
      print("Unable to retrieve email.");
    }

    return mailPieces;
  }

  /// Retrieve emails based on a sender filter, and subject filter when passed in a timeStamp
  Future<Digest> getMailPieceDigest(DateTime timeStamp) async {
    MailUtility mail = new MailUtility();
    Digest digest = Digest(await mail.getEmailOn(timeStamp,"USPSInformeddelivery@email.informeddelivery.usps.com",
        "Your Daily Digest"));
    return digest;
  }

  /// Process an individual email, converting it into a list of MailPieces
  Future<List<MailPiece>> _processEmail(MimeMessage email) async {
    List<MailPiece> mailPieces = <MailPiece>[];

    // Get attachments with metadata and convert them to MailPieces
    final mailPieceAttachments = await _getAttachments(email);
    for (final attachment in mailPieceAttachments) {
      mailPieces.add(await _processMailImage(
          attachment, email.decodeDate()!, mailPieces.length));
    }

    return mailPieces;
  }

  Attachment _grabImage(MimeData data) {
    var attachment = Attachment()
      ..contentID =
          _getHeader(data, "Content-ID").replaceAll('<', '').replaceAll('>', '')
      ..sender =
          "Test Sender" //todo: pull from emailBodyHtml by parsing the HTML
      ..attachment = data
          .decodeMessageData()
          .toString() //These are base64 encoded images with formatting
      ..attachmentNoFormatting = data.decodeMessageData().toString().replaceAll(
          "\r\n", ""); //These are base64 encoded images with formatting

    return attachment;
  }

  /// Retrieve a list of the mail image "attachments" with accompanying metadata
  Future<List<Attachment>> _getAttachments(MimeMessage email) async {
    var mimeParts = email.mimeData!.parts!;
    List<Attachment> attachments = [];

    for (var i = 0; i < mimeParts.length; i++) {
      var mimeTopType = mimeParts[i].contentType!.mediaType.top;

      switch (mimeTopType) {
        case MediaToptype.image:
          //grab the image
          attachments.add(_grabImage(mimeParts[i]));
          break;
        case MediaToptype.multipart:
          // there might be more subparts
          for (var j = 0; j < mimeParts[i].parts!.length; j++) {
            var subPartTopType =
                mimeParts[i].parts![j].contentType!.mediaType.top;
            switch (subPartTopType) {
              case MediaToptype.image:
                attachments.add(_grabImage(mimeParts[i].parts![j]));
                break;
              default:
                // only go two parts deep
                break;
            }
          }
          break;
        default:
          // we only care about the image
          break;
      }
    }
    return attachments;
  }

  /// Get particular header value from a MimeData part
  String _getHeader(MimeData part, String headerName) {
    return part.headersList!
        .where((element) => element.name == headerName)
        .first
        .value
        .toString();
  }


  /// Process an individual mail image, converting it into a MailPiece
  Future<MailPiece> _processMailImage(
      Attachment attachment, DateTime timestamp, int index) async {
    MailResponse ocrScanResult = await _getOcrScan(attachment.attachment);

    // Sender text is actually sometimes included in the Email body as text for "partners".
    // We prefer to use this rather than try and deduce it using the image itself.
    if (attachment.sender.isEmpty) {
      attachment.sender = ocrScanResult.addresses.first.name;
    }

    final id = "${attachment.sender}-$timestamp-$index";
    var text = ocrScanResult.textAnnotations.first.text;
    var mid = attachment
        .contentID; //todo: couldn't determine where MID might be at a first glance, this seemed fitting for now
    //todo: save list of URLs found on the ocrScanResult (including text URLs, barcodes, and QR codes)
    //todo: save list of Emails found on the ocrScanResult
    //todo: save list of Phone Numbers found on the ocrScanResult

    //todo: determine if enough_mail provides an actual ID value to pass as the EmailID,
    //todo: otherwise the date is probably fine since there is only one USPS ID email per day
    final emailId = timestamp.toString();

    return new MailPiece(id, emailId, timestamp, attachment.sender, text!, mid);
  }

  /// Perform OCR scan once on the mail image to get the results for further processing
  Future<MailResponse> _getOcrScan(String mailImage) async {
    CloudVisionApi vision = CloudVisionApi();
    return await vision.search(mailImage);
  }
}