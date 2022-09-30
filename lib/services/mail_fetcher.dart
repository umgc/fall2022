import 'package:enough_mail/enough_mail.dart';
import '../models/Digest.dart';
import '../models/MailPiece.dart';
import 'package:intl/intl.dart';

/// The `MailFetcher` class requests new mail from a mail server.
class MailFetcher {
  /// Fetch all pieces of mail since the provided timestamp
  /// from `uspsinformeddelivery@email.informeddelivery.usps.com`
  /// with the subject `Your Daily Digest`.
  Future<List<MailPiece>> fetchMail(DateTime lastTimestamp, String? username, String? password) async {
    List<MailPiece> mailPieces = <MailPiece>[];
    List<MimeMessage> emails = await _getEmails(
        lastTimestamp, username!, password!,
        "uspsinformeddelivery@email.informeddelivery.usps.com",
        "Your Daily Digest");

    // Process each email
    for (var i = 0; i < emails.length; i++) {
      mailPieces.addAll(await _processEmail(emails[i]));
    }

    return mailPieces;
  }

  /// Process an individual email, converting it into a list of MailPieces
  Future<List<MailPiece>> _processEmail(MimeMessage email) async {
    List<MailPiece> mailPieces = <MailPiece>[];

    // Get attachments with metadata and convert them to MailPieces
    var mailPieceAttachments = await _getAttachments(email);
    for (int i = 0; i < mailPieceAttachments.length; i++) {
      mailPieces.add(
          _processMailImage(mailPieceAttachments[i], email.decodeDate()!, mailPieces.length));
    }

    return mailPieces;
  }

  /// Retrieve a list of the mail image "attachments" with accompanying metadata
  Future<List<Attachment>> _getAttachments(MimeMessage email) async {
    var emailBodyHtml = email.mimeData!.parts!.elementAt(0).toString(); //todo: this is the full email HTML for stripping out the possible sender and "do more with your mail" sections

    try {
      List<Attachment> list = [];
      for (int x = 0; x < email.mimeData!.parts!.length; x++) {
        if (email.mimeData!.parts!
            .elementAt(x)
            .contentType
            ?.value
            .toString()
            .contains("image") ??
            false) {
          var attachment = Attachment();
          attachment.contentID = email.mimeData!.parts!.elementAt(x).headersList!.where((element) => element.name == "Content-ID").first.value.toString().replaceAll('<', '').replaceAll('>', '');
          attachment.sender = "Test Sender"; //todo: pull from emailBodyHtml by parsing the HTML
          attachment.attachment = email.mimeData!.parts!
              .elementAt(x)
              .decodeMessageData()
              .toString(); //These are base64 encoded images with formatting
          attachment.attachmentNoFormatting = attachment.attachment
              .toString()
              .replaceAll(
              "\r\n", ""); //These are base64 encoded images with formatting
          list.add(attachment);
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  /// Retrieve emails based on a start date, sender filter, and subject filter
  Future<List<MimeMessage>> _getEmails(DateTime startDate, String username, String password, String senderFilter, String subjectFilter) async {
    final client = ImapClient(isLogEnabled: true);
    try {
      //Retrieve the imap server config
      var config = await Discover.discover(username, isLogEnabled: false);
      if (config == null) {
        return <MimeMessage>[];
      } else {
        var imapServerConfig = config.preferredIncomingImapServer;
        await client.connectToServer(
            imapServerConfig!.hostname as String, imapServerConfig.port as int,
            isSecure: imapServerConfig.isSecureSocket);
        await client.login(username, password);
        await client.selectInbox();

        String searchCriteria = 'FROM ${senderFilter} SUBJECT "${subjectFilter}"'; //todo: figure out the syntax for "Date After"

        List<ReturnOption> returnOptions = [];
        ReturnOption option = ReturnOption("all");
        returnOptions.add(option);

        final searchResult = await client.searchMessages(
            searchCriteria: searchCriteria);
        final matchingSequence = searchResult.matchingSequence;
        if (matchingSequence != null) {
          return (await client.fetchMessages(matchingSequence, 'BODY.PEEK[]')).messages;
        }
        return <MimeMessage>[];
      }
    } catch (e) {
      rethrow;
    } finally {
      if (client.isLoggedIn) {
        await client.logout();
      }
    }
  }

  String _formatTargetDateForSearch(DateTime date) {
    final DateFormat format = DateFormat('dd-MMM-yyyy');
    return format.format(date);
  }

  /// Process an individual mail image, converting it into a MailPiece
  MailPiece _processMailImage(
      Attachment attachment, DateTime timestamp, int index) {
    var ocrScanResult = _getOcrScan(attachment.attachment);

    // Sender text is actually sometimes included in the Email body as text for "partners".
    // We prefer to use this rather than try and deduce it using the image itself.
    if (attachment.sender.isEmpty) {
      attachment.sender = _getOcrSender(ocrScanResult);
    }

    final id = "${attachment.sender}-$timestamp-$index";
    var text = _getOcrBody(ocrScanResult);
    var mid = attachment.contentID; //todo: couldn't determine where MID might be at a first glance, this seemed fitting for now
    //todo: save list of URLs found on the ocrScanResult (including text URLs, barcodes, and QR codes)
    //todo: save list of Emails found on the ocrScanResult
    //todo: save list of Phone Numbers found on the ocrScanResult

    //todo: determine if enough_mail provides an actual ID value to pass as the EmailID,
    //todo: otherwise the date is probably fine since there is only one USPS ID email per day
    final emailId = timestamp.toString();

    return new MailPiece(
        id, emailId, timestamp, attachment.sender, text, mid);
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
