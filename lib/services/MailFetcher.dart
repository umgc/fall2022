import '../models/MailPiece.dart';

/// The `MailFetcher` class requests new mail from a mail server.
class MailFetcher {
  /// Fetch all pieces of mail since the provided timestamp
  /// from `uspsinformeddelivery@email.informeddelivery.usps.com`
  /// with the subject `Your Daily Digest`.
  Stream<MailPiece> fetchMail(DateTime lastTimestamp) {
    List<MailPiece> mailPieces = <MailPiece>[];
    List<String> emails = _getEmails(lastTimestamp, "uspsinformeddelivery@email.informeddelivery.usps.com", "Your Daily Digest");

    // Process each email
    for (var i = 0; i < emails.length; i++) {
      mailPieces.addAll(_processEmail(emails[i]));
    }

    return new Stream.fromIterable(mailPieces);
  }

  /// Process an individual email, converting it into a list of MailPieces
  List<MailPiece> _processEmail(String email) {
    List<MailPiece> mailPieces = <MailPiece>[];

    // todo: could iterate through the email message differently, but below is just a guide of the general logic
    bool mailUnread = true;
    while (mailUnread) {
      String? sender; //todo: check for "Sender" text already listed above the image
      String mailImage = "This is the actual image object"; //todo: get actual mail image
      DateTime timestamp = DateTime.now(); //todo: get timestamp from email object instead

      // Process the mail image
      mailPieces.add(_processMailImage(mailImage, timestamp, sender));

      mailUnread = false; //todo: use some kind of end-of-file check or iterate through a list instead
    }

    return mailPieces;
  }

  /// Retrieve emails based on a start date, sender filter, and subject filter
  List<String> _getEmails(DateTime startDate, String senderFilter, String subjectFilter) {
    List<String> emails = <String>[];
    emails.add("this should actually be an email object"); //todo: log in and grab actual emails using the provided 3 filters
    return emails;
  }

  /// Process an individual mail image, converting it into a MailPiece
  MailPiece _processMailImage(String mailImage, DateTime timestamp, String? sender) {
    var ocrScanResult = _getOcrScan(mailImage);


    //test

    //test 2

    // Sender text is actually sometimes included in the Email body as text for "partners".
    // We prefer to use this rather than try and deduce it using the image itself.
    if (sender == null || sender.isEmpty) {
      sender = _getOcrSender(ocrScanResult);
    }

    var text = _getOcrBody(ocrScanResult);
    var mid = _getMID(mailImage);
    //todo: save list of URLs found on the ocrScanResult (including text URLs, barcodes, and QR codes)
    //todo: save list of Emails found on the ocrScanResult
    //todo: save list of Phone Numbers found on the ocrScanResult

    //todo: determine if enough_mail provides an actual ID value to pass as the EmailID,
    //todo: otherwise the date is probably fine since there is only one USPS ID email per day
    return new MailPiece.fromEmail(timestamp.toString(), timestamp, sender, text, mid);
  }

  /// Get the MID metadata field from the mail image (supposed to be some kind of metadata as per the customer)
  String _getMID(String mailImage) {
    return "1"; //todo: figure out how to get MID value from the image (not an OCR thing)
  }

  /// Perform OCR scan once on the mail image to get the results for further processing
  String _getOcrScan(String mailImage) {
    return "return actual google cloud vision object here"; //todo: perform OCR scan on actual image
  }

  /// Determine the sender of the mail piece based on an OCR scan of the mail image
  String _getOcrSender(String ocrScanResult) {
    return "Unknown Sender"; //todo: use OCR scan to determine sender if possible, otherwise return "Unknown Sender" if the scan cannot figure it out
  }

  String _getOcrBody(String ocrScanResult) {
    return "Get full text content of scan here"; //todo: pull all text content from OCR scan result
  }
}