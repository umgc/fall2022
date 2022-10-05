import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:summer2022/models/Code.dart';
import 'package:summer2022/image_processing/barcode_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:summer2022/image_processing/usps_address_verification.dart';

class DigestEmailParser {
  String _userName = ''; // Add your credentials
  String _password = ''; // Add your credentials
  DateTime? _targetDate;

  Future<Digest> createDigest(String userName, String password,
      [DateTime? targetDate]) async {
    try {
      _userName = userName;
      _password = password;
      _targetDate = targetDate;
      Digest digest = Digest(await _getDigestEmail());

        if (!digest.isNull()) {
        digest.attachments = await _getAttachments(digest.message);
        digest.links = _getLinks(digest.message);
      }
      return digest;
    } catch (e) {
      rethrow;
    }
  }

  Future<MimeMessage> _getDigestEmail() async {
    final client = ImapClient(isLogEnabled: true);
    try {
      DateTime targetDate = _targetDate ?? DateTime.now();
      //Retrieve the imap server config
      var config = await Discover.discover(_userName, isLogEnabled: false);
      if (config == null) {
        return MimeMessage();
      } else {
        var imapServerConfig = config.preferredIncomingImapServer;
        await client.connectToServer(
            imapServerConfig!.hostname as String, imapServerConfig.port as int,
            isSecure: imapServerConfig.isSecureSocket);
        await client.login(_userName, _password);
        await client.selectInbox();
        //Search for sequence id of the Email
        String searchCriteria =
            'FROM USPSInformeddelivery@email.informeddelivery.usps.com ON ${_formatTargetDateForSearch(targetDate)} SUBJECT "Your Daily Digest"';
        List<ReturnOption> returnOptions = [];
        ReturnOption option = ReturnOption("all");
        returnOptions.add(option);
        final searchResult = await client.searchMessages(
            searchCriteria: searchCriteria);
        //extract sequence id
        int? seqID;
        final matchingSequence = searchResult.matchingSequence;
        if (matchingSequence != null) {
          seqID = matchingSequence.isNotEmpty
              ? matchingSequence.elementAt(0)
              : null; // this gets the sequence id of the desired email
        }
        if (seqID != null) {
          //Fetch Email Results
          final fetchedMessage =
              await client.fetchMessage(seqID, 'BODY.PEEK[]');
          return fetchedMessage.messages.first;
        }
        return MimeMessage();
      }
    } catch (e) {
      rethrow;
    } finally {
      if (client.isLoggedIn) {
        await client.logout();
      }
    }
  }


}
