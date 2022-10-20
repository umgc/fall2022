import 'package:googleapis/gmail/v1.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/email_processing/gmail_api_service.dart';
import 'package:summer2022/utility/user_auth_service.dart';
import '../exceptions/fetch_mail_exception.dart';
import '../models/MailPiece.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:enough_mail/enough_mail.dart';
import '../models/Digest.dart';
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
    try {
      List<MimeMessage> emails = await _getEmails(
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

  Future<List<MimeMessage>> _fetchMailFromGoogle(
      DateTime startDate, String senderFilter, String subjectFilter) async {
    //https://developers.google.com/gmail/api/reference/rest/v1/users.messages/list
    // use same query format as gmail search bar
    // must allow for at least a day buffer if searching for specific date (limitation of the gmail api)
    final dateFormatter = DateFormat('yyyy/MM/dd');
    String after =
        dateFormatter.format(startDate.subtract(const Duration(days: 1)));
    String before =
        dateFormatter.format(startDate.add(const Duration(days: 2)));
    Map<String, String> queryDict = {
      'from:': senderFilter,
      'subject:': subjectFilter,
      'after:': after,
      'before:': before
    };
    return GmailApiService().fetchMail(queryDict);
  }

  /// Retrieve emails based on a start date, sender filter, and subject filter
  Future<List<MimeMessage>> _getEmails(
      DateTime startDate, String senderFilter, String subjectFilter) async {
    //Check if we are signed into google, otherwise use provided username/password
    bool isSignedIntoGoogle = await UserAuthService().isSignedIntoGoogle;
    if (isSignedIntoGoogle) {
      return await _fetchMailFromGoogle(startDate, senderFilter, subjectFilter);
    }

    final client = await _login();
    try {
      if (client == null) {
        return <MimeMessage>[];
      } else {
        // Note that the IMAP spec ignores time, so we will always get emails from the same day if multiple checks are done
        String searchCriteria =
            'FROM ${senderFilter} SINCE ${_formatTargetDateForSearch(startDate)} SUBJECT "${subjectFilter}"';
        final searchResult =
            await client.searchMessages(searchCriteria: searchCriteria);

        if (searchResult.matchingSequence != null) {
          return (await client.fetchMessages(
                  searchResult.matchingSequence!, 'BODY.PEEK[]'))
              .messages;
        }
        return <MimeMessage>[];
      }
    } catch (e) {
      throw new FetchMailException(e.toString());
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
