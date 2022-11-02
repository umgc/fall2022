import 'package:googleapis/gmail/v1.dart';
import 'package:flutter/cupertino.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/email_processing/gmail_api_service.dart';
import 'package:summer2022/utility/user_auth_service.dart';
import 'package:summer2022/services/mail_utility.dart';
import '../models/Code.dart';
import '../models/MailPiece.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:enough_mail/enough_mail.dart';
import '../models/Digest.dart';
import 'package:intl/intl.dart';
import 'package:html/parser.dart';

import '../utility/linkwell.dart';

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
          debugPrint("Attempting to process email from " +
              email.decodeDate()!.toString());
          mailPieces.addAll(await processEmail(email));
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
    Digest digest = Digest(await mail.getEmailOn(
        timeStamp,
        "USPSInformeddelivery@email.informeddelivery.usps.com",
        "Your Daily Digest"));
    return digest;
  }

  /// Process an individual email, converting it into a list of MailPieces
  Future<List<MailPiece>> processEmail(MimeMessage email) async {
    List<MailPiece> mailPieces = <MailPiece>[];

    // Get attachments with metadata and convert them to MailPieces
    final mailPieceAttachments = await _getAttachments(email);

    mailPieces = await Future.wait([
    for (final attachment in mailPieceAttachments)
       _processMailImage(email, attachment, email.decodeDate()!, mailPieces.length)
    ]);

    debugPrint("Finished processing " +
        mailPieceAttachments.length.toString() +
        " mailpieces for email on " +
        email.decodeDate()!.toString());

    return mailPieces;
  }

  Attachment _grabImage(MimeData data) {
    var attachment = Attachment()
      ..contentID =
          _getHeader(data, "Content-ID").replaceAll('<', '').replaceAll('>', '')
      ..sender = '' //Sender gets set in _processMailImage
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

  /**
   * @param full = the full string you wish to parse
   * @param sub = the substring you are searching for
   * @retval = list of starting indicies of all sub matches
   */
  List<int> _parseForAllStartingPoints(String full, String sub) {
    List<int> startingPositions = [];
    int index = 0;

    while (index != -1) {
      index = full.indexOf(sub, index);

      if (index != -1) {
        startingPositions.add(index);
        index += sub.length;
      }
    }
    return startingPositions;
  }

  /// Process an individual mail image, converting it into a MailPiece
  Future<MailPiece> _processMailImage(MimeMessage email, Attachment attachment,
      DateTime timestamp, int index) async {
    MailResponse ocrScanResult = await _getOcrScan(attachment.attachment);

    // If sender is not stored in metadata
    if (email.sender == null) {

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
                  'img[src*=\'${attachment.contentID}\']');

              int scanImgPos = doc.querySelectorAll('*').indexOf(
                  scannedMailPieceItems![0]);

              var fromItems = doc.querySelectorAll("strong");

              for (int z = 0; z < fromItems.length; z++) {
                int fromSenderPos = doc.querySelectorAll('*')
                    .indexOf(fromItems[z]);
                if ((scanImgPos < (fromSenderPos + 15)) &&
                    (scanImgPos > fromSenderPos)) {
                  String? sender = parse(doc
                      .querySelectorAll('*')
                      .elementAt(fromSenderPos)
                      .parent
                      ?.text).documentElement?.text.toString().substring(
                      5); //remove "From "
                  debugPrint("Mailpiece: " + attachment.contentID + " has this sender: " + sender!);

                  attachment.sender = sender;
                  break;
                }
              }
            } //end if "text/html"
            break;
          } //end elements y looop

        } //end if "multipart
        break;
      } //end element x loop

      /* skip this code, has errors
      //get full html string of the email
      String fullHtml = email.mimeData!.parts!.first.toString();
      List<int> matchIndicies =
          _parseForAllStartingPoints(fullHtml, 'From</strong>');

      if (matchIndicies.isNotEmpty) {
        // Find all potential cid's in html, try to match one to the attachment
        // TODO: A more efficient solution where you cache so you only search each html string once
        for (int i in matchIndicies) {
          int cidStart = fullHtml.indexOf('cid', i) + 4;
          String parsedCid =
              fullHtml.substring(cidStart, fullHtml.indexOf("\"", cidStart));

          //Parsing the html gives us some delimiters, so must get rid of
          var parts = parsedCid.split("=");
          var getRidOfStrangeWhiteSpace = parts[1].trim();
          parsedCid = parts[0] + getRidOfStrangeWhiteSpace;

          if (attachment.contentID == parsedCid) {
            attachment.sender = fullHtml
                .substring(i + 13, fullHtml.indexOf('</td>', i + 13))
                .trim();
            break;
          }
        }
      }
      */

    } else {
      if (email.sender!.hasPersonalName) {
        attachment.sender = email.sender!.personalName.toString();
      } else {
        attachment.sender = email.sender!.email;
      }
    }

    // If no sender text included in email, use OCR results
    // This code is a bit messy because there's no way to check if those objects = null
    if (attachment.sender.isEmpty) {
      try {
        if (ocrScanResult.addresses.first.name.isNotEmpty) {
          attachment.sender = ocrScanResult.addresses.first.name;
        }
      } catch (e) {
        debugPrint("No addresses detected for this attachment");

        try {
          if (ocrScanResult.logos.first.getName.isNotEmpty) {
            attachment.sender = ocrScanResult.logos.first.getName;
          }
        } catch (e) {
          debugPrint("No logos detected for this attachment");
          attachment.sender = "Unknown Sender";
        }
      }
    }

    final id = "${attachment.sender}-$timestamp-$index";
    var text = ocrScanResult.textAnnotations.first.text;
    var scanImgCID = attachment
        .contentID; //todo: couldn't determine where MID might be at a first glance, this seemed fitting for now
    //todo: save list of URLs found on the ocrScanResult (including text URLs, barcodes, and QR codes)
    //todo: save list of Emails found on the ocrScanResult
    //todo: save list of Phone Numbers found on the ocrScanResult

    List<CodeObject> codeObj = ocrScanResult.codes;
    var links = <String>[];
    var emailList = <String>[];
    var phoneList = <String>[];

    for (int i = 0; i < codeObj.length; i++) {
      if (codeObj[i].getType == 'qr') {
        links.add(codeObj[i].getInfo.toString());
      }
    }


    LinkWell linkWell = LinkWell(text!);

    List<dynamic> linkWellLinks = linkWell.links;
    List<dynamic> linkWellPhone = linkWell.phone;    for (final link in linkWellLinks) {
      if (link.toString().contains('@')) {
        emailList.add(link);
      } else {
        links.add(link);
      }
    }

    for (final phone in linkWellPhone) {
      print(phone.toString());
      phoneList.add(phone);
    }

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

            if (scanImgCID.contains("ra_0_") ) { //start code for ride along processing

              //first step is to get all elements that are image, and have alt text 'scanned image of your mail piece'.
              var rideAlongItems = doc.querySelectorAll(
                  'img[alt*=\'ride along content for your mail piece\']');

              int matchingIndex = -1;
              for (int i = 0; i < rideAlongItems.length; i++) {
                if (rideAlongItems[i]
                    .attributes
                    .toString()
                    .contains(scanImgCID)) {
                  matchingIndex = i;
                  break;
                }
              }

              //print debug error that the scanImgCID didn't find a match.
              if (matchingIndex == -1) {
                debugPrint("For mailPiece " +
                    scanImgCID +
                    " there was no associated ID.");
                break;
              }

              //next, get a list of items that have the tracking link.  All ride alongs have a tracking link.
              var trackingItems = doc.querySelectorAll(
                  'a[originalsrc*=\'informeddelivery.usps.com/tracking\']');

              //need a counter for times the reminder mailPiece with image was found
              int trackingCount = 0;
              //find a reminder with the image tag, this eliminates the duplicate tag with the "Set a Reminder" text
              for (int i = 0; i < trackingItems.length; i++) {
                if (trackingItems[i].innerHtml.toString().contains("img")) {
                  //we want to get the mailPieceID of the matching mailPiece.  Will help with getting other items
                  if (trackingCount == matchingIndex) {
                    var regex = RegExp(
                        r'mailpiece=\d*\&'); //finds the string mailpieceId=digits to "
                    var regexNum = RegExp(r'\d+'); //get numbers only

                    var mpID1 =
                    regex.firstMatch(trackingItems[i].outerHtml.toString());

                    mailPieceId = regexNum
                        .firstMatch(mpID1![0]!.toString())![0]!
                        .toString();

                    debugPrint("Date: " +
                        DateFormat('yyyy/MM/dd').format(timestamp) +
                        "; scanImgCID: " +
                        scanImgCID +
                        "; has matching USPS-ID: " +
                        mailPieceId);

                    //break out of for after finding correct mailPiece
                    break;
                  }
                  trackingCount++;
                }
              } //end for loop for trackingItems
            } else { //start code for normal mailpiece

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
                debugPrint("For mailPiece " +
                    scanImgCID +
                    " there was no associated ID.");
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

                    var mpID1 =
                    regex.firstMatch(reminderItems[i].outerHtml.toString());

                    mailPieceId = regexNum
                        .firstMatch(mpID1![0]!.toString())![0]!
                        .toString();

                    debugPrint("Date: " +
                        DateFormat('yyyy/MM/dd').format(timestamp) +
                        "; scanImgCID: " +
                        scanImgCID +
                        "; has matching USPS-ID: " +
                        mailPieceId);

                    //break out of for after finding correct mailPiece
                    break;
                  }
                  reminderCount++;
                }
              }//end for loop for reminderItems
            } //end else for normal mailpiece process
            break;
          } //end if 'text/html'
        } //end for loop for element y parts
        break;
      } //end if multipart
    } //end for loop for element x parts

    return new MailPiece(id, emailId, timestamp, attachment.sender, text!,
        scanImgCID, mailPieceId, links, emailList, phoneList);
  } //end _processMailImage

  /// Perform OCR scan once on the mail image to get the results for further processing
  Future<MailResponse> _getOcrScan(String mailImage) async {
    CloudVisionApi vision = CloudVisionApi();
    return await vision.search(mailImage);
  }
}
