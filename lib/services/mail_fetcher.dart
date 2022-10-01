import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:summer2022/models/MailResponse.dart';

import '../models/Address.dart';
import '../models/MailPiece.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:enough_mail/enough_mail.dart';
import '../models/Digest.dart';
import '../models/MailPiece.dart';
import 'package:intl/intl.dart';

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
    List<MimeMessage> emails = await _getEmails(
        lastTimestamp,
        "uspsinformeddelivery@email.informeddelivery.usps.com",
        "Your Daily Digest");

    // Process each email
    for (final email in emails) {
      mailPieces.addAll(await _processEmail(email));
    }

    return mailPieces;
  }

  /// Process an individual email, converting it into a list of MailPieces
  Future<List<MailPiece>> _processEmail(MimeMessage email) async {
    List<MailPiece> mailPieces = <MailPiece>[];

    // Get attachments with metadata and convert them to MailPieces
    final mailPieceAttachments = await _getAttachments(email);
    for (final attachment in mailPieceAttachments) {
      mailPieces.add(
          _processMailImage(attachment, email.decodeDate()!, mailPieces.length));
    }

    return mailPieces;
  }

  /// Retrieve a list of the mail image "attachments" with accompanying metadata
  Future<List<Attachment>> _getAttachments(MimeMessage email) async {
    var emailBodyHtml = email.mimeData!.parts!.first.toString(); //todo: this is the full email HTML for stripping out the possible sender and "do more with your mail" sections
    List<Attachment> attachments = [];

    for (final part in email.mimeData!.parts!) {
      if (_isContentType(part, "image")) {
        var attachment = Attachment();

        attachment.contentID = _getHeader(part, "Content-ID")
            .replaceAll('<', '').replaceAll('>', '');
        attachment.sender = "Test Sender"; //todo: pull from emailBodyHtml by parsing the HTML
        attachment.attachment = part.decodeMessageData().toString(); //These are base64 encoded images with formatting
        attachment.attachmentNoFormatting = attachment.attachment.toString()
            .replaceAll("\r\n", ""); //These are base64 encoded images with formatting

        attachments.add(attachment);
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
    } finally {
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
