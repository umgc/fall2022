import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:summer2022/models/MailResponse.dart';

import '../models/Address.dart';
import '../models/MailPiece.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';

/// The `MailFetcher` class requests new mail from a mail server.
class MailFetcher {
  /// Fetch all pieces of mail since the provided timestamp
  /// from `uspsinformeddelivery@email.informeddelivery.usps.com`
  /// with the subject `Your Daily Digest`.
  Future<List<MailPiece>> fetchMail(DateTime lastTimestamp) async {
    List<MailPiece> mailPieces = <MailPiece>[];
    List<String> emails = _getEmails(
        lastTimestamp,
        "uspsinformeddelivery@email.informeddelivery.usps.com",
        "Your Daily Digest");

    // Process each email
    for (var i = 0; i < emails.length; i++) {
      mailPieces.addAll(await _processEmail(emails[i]));
    }

    return mailPieces;
  }

  /// Process an individual email, converting it into a list of MailPieces
  Future<List<MailPiece>> _processEmail(String email) async {
    List<MailPiece> mailPieces = <MailPiece>[];

    // todo: could iterate through the email message differently, but below is just a guide of the general logic
    bool mailUnread = true;
    while (mailUnread) {
      String?
          sender; //todo: check for "Sender" text already listed above the image

      // TODO: Delete this when we get image coming with mail data properly
      // This just provides an example of how to parse and image and will give valid results
      // during OCR conversion
      //var image = await rootBundle.load('assets/mail.test.01.jpg');
      //var buffer = image.buffer;
      //var mailImage = base64.encode(Uint8List.view(buffer));

      String mailImage =
          "This is the actual image object"; //todo: get actual mail image
      DateTime timestamp =
          DateTime.now(); //todo: get timestamp from email object instead

      // Process the mail image
      mailPieces.add(
          await _processMailImage(mailImage, timestamp, sender, mailPieces.length));

      mailUnread =
          false; //todo: use some kind of end-of-file check or iterate through a list instead
    }

    return mailPieces;
  }

  /// Retrieve emails based on a start date, sender filter, and subject filter
  List<String> _getEmails(
      DateTime startDate, String senderFilter, String subjectFilter) {
    List<String> emails = <String>[];
    emails.add(
        "this should actually be an email object"); //todo: log in and grab actual emails using the provided 3 filters
    return emails;
  }

  /// Process an individual mail image, converting it into a MailPiece
  Future<MailPiece> _processMailImage(
      String mailImage, DateTime timestamp, String? sender, int index) async {
    var ocrScanResult = await _getOcrScan(mailImage);

    // Sender text is actually sometimes included in the Email body as text for "partners".
    // We prefer to use this rather than try and deduce it using the image itself.
    if (sender == null || sender.isEmpty) {
      sender = _getOcrSender(ocrScanResult);
    }

    final id = "$sender-$timestamp-$index";
    var text = _getOcrBody(ocrScanResult);
    var mid = _getMID(mailImage);
    //todo: save list of URLs found on the ocrScanResult (including text URLs, barcodes, and QR codes)
    //todo: save list of Emails found on the ocrScanResult
    //todo: save list of Phone Numbers found on the ocrScanResult

    //todo: determine if enough_mail provides an actual ID value to pass as the EmailID,
    //todo: otherwise the date is probably fine since there is only one USPS ID email per day
    final emailId = timestamp.toString();

    return new MailPiece(
        id, emailId, timestamp, sender, text, mid);
  }

  /// Get the MID metadata field from the mail image (supposed to be some kind of metadata as per the customer)
  String _getMID(String mailImage) {
    return "1"; //todo: figure out how to get MID value from the image (not an OCR thing)
  }

  /// Perform OCR scan once on the mail image to get the results for further processing
  Future<String> _getOcrScan(String mailImage) async {
    CloudVisionApi vision = CloudVisionApi();
    MailResponse mailResponse = await vision.search(mailImage);

    return mailResponse.toJson().toString();
  }

  /// Determine the sender of the mail piece based on an OCR scan of the mail image
  String _getOcrSender(String ocrScanResult) {
    Map<String, dynamic> ocrResultMap = jsonDecode(ocrScanResult);
    MailResponse mailResponse = MailResponse.fromJson(ocrResultMap);
    // use OCR scan to determine sender if possible, otherwise return "Unknown Sender" if the scan cannot figure it out
    // TODO: Maybe this should return the address object instead
    return mailResponse.addresses.first.toJson().toString() ?? "Unknown Sender";
  }

  String _getOcrBody(String ocrScanResult) {
    return "Get full text content of scan here"; //todo: pull all text content from OCR scan result
  }
}
