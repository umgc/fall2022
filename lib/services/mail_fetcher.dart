import 'package:flutter/cupertino.dart';
import 'package:summer2022/models/MailResponse.dart';
import '../exceptions/fetch_mail_exception.dart';
import '../models/MailPiece.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:enough_mail/enough_mail.dart';
import '../models/Digest.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

/// The `MailFetcher` class requests new mail from a mail server.
class MailFetcher {
  late String? _username;
  late String? _password;

  MailFetcher(this._username, this._password);

  /// Fetch all pieces of mail since the provided timestamp
  /// from `uspsinformeddelivery@email.informeddelivery.usps.com`
  /// with the subject `Your Daily Digest`.
  Future<List<MailPiece>> fetchMail(DateTime lastTimestamp) async {
    List<MailPiece> mailPieces = <MailPiece>[];
    try {
      List<MimeMessage> emails = await _getEmails(
          lastTimestamp,
          "uspsinformeddelivery@email.informeddelivery.usps.com",
          "Your Daily Digest");

      // Process each email
      for (final email in emails) {
        try {
          debugPrint("Attempting to process email from " + email.decodeDate()!.toString());
          mailPieces.addAll(await _processEmail(email));
        } catch(e) {
          print("Unable to process individual email.");
        }
      }
    } catch(e) {
      print("Unable to retrieve email.");
    }

    return mailPieces;
  }

  /// Process an individual email, converting it into a list of MailPieces
  Future<List<MailPiece>> _processEmail(MimeMessage email) async {
    List<MailPiece> mailPieces = <MailPiece>[];

    // Get attachments with metadata and convert them to MailPieces
    final mailPieceAttachments = await _getAttachments(email);
    for (final attachment in mailPieceAttachments) {

      MailPiece mp = await _processMailImage(email, attachment, email.decodeDate()!, mailPieces.length);

      mailPieces.add(mp);
    }

    debugPrint("Finished processing " + mailPieceAttachments.length.toString() +
          " mailpieces for email on " + email.decodeDate()!.toString());

    return mailPieces;
  }

  /// Retrieve a list of the mail image "attachments" with accompanying metadata
  Future<List<Attachment>> _getAttachments(MimeMessage email) async {
    var mimeParts = email.mimeData!.parts!.first;
    List<Attachment> attachments = [];

    if (mimeParts.parts != null) {
      var emailHtml = mimeParts.parts!.first.toString(); //todo: this is the full email HTML for stripping out the possible sender and "do more with your mail" sections

      //for each part in the email html, look for parts with image. this becomes an attachment.
      for (final part in mimeParts.parts!) {
        if (_isContentType(part, "image")) {

          if ( !_getHeader(part, "Content-ID").contains("ra_") ) {
              var attachment = Attachment();

              attachment.contentID = _getHeader(part, "Content-ID")
                  .replaceAll('<', '').replaceAll('>', '');
              attachment.sender =
              "Test Sender"; //todo: pull from emailBodyHtml by parsing the HTML

              attachment.attachment = part.decodeMessageData()
                  .toString(); //These are base64 encoded images with formatting

              //The daily digest emails have base64 encoded images with formatting
              //that needs to be removed for google vision to interpret
              attachment.attachmentNoFormatting = attachment.attachment.toString()
                  .replaceAll(
              "\r\n", "");

              attachments.add(attachment);
          }
        }
      }
    }
    return attachments;
  }

  /// Get particular header value from a MimeData part
  String _getHeader(MimeData part, String headerName) {
    return part.headersList!.where((element) => element.name == headerName).first.value.toString();
  }

  /// Check if MimeData part is of a specified content type
  bool _isContentType(MimeData part, String contentType) {
    return part.contentType?.value.toString().contains(contentType) ?? false;
  }

  /// Retrieve emails based on a start date, sender filter, and subject filter
  Future<List<MimeMessage>> _getEmails(DateTime startDate, String senderFilter, String subjectFilter) async {
    final client = await _login();
    try {
      if (client == null) {
        return <MimeMessage>[];
      } else {
        // Note that the IMAP spec ignores time, so we will always get emails from the same day if multiple checks are done
        String searchCriteria = 'FROM ${senderFilter} SINCE ${_formatTargetDateForSearch(startDate)} SUBJECT "${subjectFilter}"';
        final searchResult = await client.searchMessages(searchCriteria: searchCriteria);

        if (searchResult.matchingSequence != null) {
          return (await client.fetchMessages(
              searchResult.matchingSequence!, 'BODY.PEEK[]')).messages;
        }
        return <MimeMessage>[];
      }
    } catch(e) {
      throw new FetchMailException(e.toString());
    }
    finally {
      _logout(client);
    }
  }

  /// Log in to the IMAP client for email retrieval
  Future<ImapClient?> _login() async {
    ImapClient? client = null;
    try {
      client = ImapClient(isLogEnabled: true);
      var config = await Discover.discover(_username!, isLogEnabled: false);
      if (config == null) {
        return null;
      } else {
        var imapServerConfig = config.preferredIncomingImapServer;
        await client.connectToServer(
            imapServerConfig!.hostname as String, imapServerConfig.port as int,
            isSecure: imapServerConfig.isSecureSocket);
        await client.login(_username!, _password!);
        await client.selectInbox();
        return client;
      }
    } catch (e) {
      return null;
    }
  }

  Future _logout(ImapClient? client) async {
    if (client != null && client.isLoggedIn) {
      client.logout();
    }
  }

  /// Format the DateTime object as the format expected by IMAP
  String _formatTargetDateForSearch(DateTime date) {
    final DateFormat format = DateFormat('dd-MMM-yyyy');
    return format.format(date);
  }

  /// Process an individual mail image, converting it into a MailPiece
  Future<MailPiece> _processMailImage(MimeMessage email,
      Attachment attachment, DateTime timestamp, int index) async {
    MailResponse ocrScanResult = await _getOcrScan(attachment.attachment);

    // Sender text is actually sometimes included in the Email body as text for "partners".
    // We prefer to use this rather than try and deduce it using the image itself.
    if (attachment.sender.isEmpty) {
      attachment.sender = ocrScanResult.addresses.first.name;
    }

    final id = "${attachment.sender}-$timestamp-$index";
    var text = ocrScanResult.textAnnotations.first.text;
    var scanImgCID = attachment.contentID; //todo: couldn't determine where MID might be at a first glance, this seemed fitting for now
    //todo: save list of URLs found on the ocrScanResult (including text URLs, barcodes, and QR codes)
    //todo: save list of Emails found on the ocrScanResult
    //todo: save list of Phone Numbers found on the ocrScanResult

    //todo: determine if enough_mail provides an actual ID value to pass as the EmailID,
    //todo: otherwise the date is probably fine since there is only one USPS ID email per day
    final emailId = timestamp.toString();


    //this section of code finds the USPS mailpiece ID in the email associated with the
    //image CID.  Useful in getting links per mailpiece.

    String mailPieceId = "";
    //based on test account, need to get 2nd level of parts to find image.  search in text/html part first
    for (int x = 0; x < email.mimeData!.parts!.length; x++) {

      if (email.mimeData!.parts!
          .elementAt(x)
          .contentType
          ?.value
          .toString()
          .contains("multipart") ??
          false) {
        for (int y = 0;
        y < email.mimeData!.parts!.elementAt(x).parts!.length;
        y++) {
          if (email.mimeData!.parts!
              .elementAt(x)
              .parts!
              .elementAt(y)
              .contentType
              ?.value
              .toString()
              .contains("text/html") ??
              false) {
            //get the parts into an html document to make it searchable.
            //need to decode Text into 'quoted-printable' type to see all the link text values
            var doc = parse(email.mimeData!.parts!
                .elementAt(x)
                .parts!
                .elementAt(y)
                .decodeText(
                ContentTypeHeader('text/html'), 'quoted-printable'));

            //first step is to get all elements that are image, and have alt text 'scanned image of your mail piece'.
            var scannedMailPieceItems = doc.querySelectorAll(
                'img[alt*=\'Scanned image of your mail piece\']');

            //scan through the mailpiece images to figure out which index matches the mailPiece Id.
            //this will be used to find the corresponding reminder link.
            int matchingIndex = -1;
            for (int i = 0; i < scannedMailPieceItems.length; i++) {
              if (scannedMailPieceItems[i]
                  .attributes
                  .toString()
                  .contains(scanImgCID)) {
                matchingIndex = i;
                break;
              }
            }

            //print debug error that the scanImgCID didn't find a match.
            if (matchingIndex == -1) {
              debugPrint("For mailPiece " + scanImgCID + " there was no associated ID.");
              break;
            }

            //next, get a list of items that have the reminder link.  They all have the reminder link.
            var reminderItems = doc.querySelectorAll(
                'a[originalsrc*=\'informeddelivery.usps.com/box/pages/reminder\']');

            //need a counter for times the reminder mailPiece with image was found
            int reminderCount = 0;
            //find a reminder with the image tag, this eliminates the duplicate tag with the "Set a Reminder" text
            for (int i = 0; i < reminderItems.length; i++) {
              if (reminderItems[i].innerHtml.toString().contains("img")) {
                //we want to get the mailPieceID of the matching mailPiece.  Will help with getting other items
                if (reminderCount == matchingIndex) {
                  var regex = RegExp(
                      r'mailpieceId=\d*\"'); //finds the string mailpieceId=digits to "
                  var regexNum = RegExp(r'\d+'); //get numbers only

                  var mpID1 = regex.firstMatch(
                      reminderItems[i].outerHtml.toString());

                  mailPieceId = regexNum.firstMatch(mpID1![0]!.toString())![0]!
                      .toString();

                  debugPrint("Date: " + DateFormat('yyyy/MM/dd').format(timestamp) + "; mailPieceCID: " + scanImgCID + "; has matching USPS-ID: " + mailPieceId);

                  //break out of for after finding correct mailPiece
                  break;
                }
                reminderCount++;
              }
            }
          }
        }
      }
    }

    return new MailPiece(
        id, emailId, timestamp, attachment.sender, text!, scanImgCID, mailPieceId);
  }

  /// Perform OCR scan once on the mail image to get the results for further processing
  Future<MailResponse> _getOcrScan(String mailImage) async {
    CloudVisionApi vision = CloudVisionApi();
    return await vision.search(mailImage);
  }
}
