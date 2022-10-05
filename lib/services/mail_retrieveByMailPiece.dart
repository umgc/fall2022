import 'package:flutter/cupertino.dart';

import '../models/Digest.dart';
import '../models/MailPiece.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:intl/intl.dart';

/// The mail_retrieveByMailPiece class searches for a specific digest email matching a specific date from a mailPiece
class MailPieceEmailFetcher{
  late String _username;
  late String _password;
  late MailPiece _mailPiece;
  late DateTime _timeStamp;

  /// Fetch the email using the mailPiece provided date
  /// from `uspsinformeddelivery@email.informeddelivery.usps.com`
  /// with the subject `Your Daily Digest`.

  Future<Digest> getMailPieceEmail(String userName, String password, MailPiece m) async {
    _username = userName;
    _password = password;
    _mailPiece = m;
    _timeStamp = m.timestamp;
    try {
        Digest digest = Digest(await _getMailPieceEmail(_timeStamp, "uspsinformeddelivery@email.informeddelivery.usps.com",
          "Your Daily Digest"));
        return digest;
    } catch(e)
    {
      debugPrint(e.toString());
    }
  }

  /// Retrieve emails based on a start date, sender filter, and subject filter
  Future<MimeMessage> _getMailPieceEmail(DateTime timeStamp, String senderFilter, String subjectFilter) async {

    //get the client logged in
    final client = await _login();

    try {
      //client being null meant something went wrong
      if (client == null) {
        return MimeMessage();
      } else {
        String searchCriteria = 'FROM ${senderFilter} ON ${_formatTargetDateForSearch(timeStamp)} SUBJECT "${subjectFilter}"';
        final searchResult = await client.searchMessages(searchCriteria: searchCriteria);

        if (searchResult.matchingSequence != null) {
          return (await client.fetchMessages(
              searchResult.matchingSequence!, 'BODY.PEEK[]')).messages.first;
        }
        return MimeMessage();
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

}
