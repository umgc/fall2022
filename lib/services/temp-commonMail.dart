import '../exceptions/fetch_mail_exception.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:intl/intl.dart';
import '../utility/Keychain.dart';

/// The `MailUtility` class requests new mail from a mail server.
class MailUtility {
  MailUtility();

  /// Retrieve emails based on a start date, sender filter, and subject filter
  Future<List<MimeMessage>> _getEmailsSince(
      DateTime date, String senderFilter, String subjectFilter) async {
    //call the username/password out of keychain only when needed, no need to pass in
    String _username = await Keychain().getUsername();
    String _password = await Keychain().getPassword();
    final client = await _login(_username, _password);

    try {
      //client being null meant something went wrong
      if (client == null) {
        return <MimeMessage>[];
      } else {
        String searchCriteria =
            'FROM ${senderFilter} SINCE ${_formatTargetDateForSearch(date)} SUBJECT "${subjectFilter}"';

        /* these are in the original digest parser
        List<ReturnOption> returnOptions = [];
        ReturnOption option = ReturnOption("all");
        returnOptions.add(option);
        */

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

  /// Retrieve email based on a specific date, sender filter, and subject filter
  Future<MimeMessage> _getEmailOn(
      DateTime date, String senderFilter, String subjectFilter) async {
    //get the client logged in

    //call the username/password out of keychain only when needed, no need to pass in
    String _username = await Keychain().getUsername();
    String _password = await Keychain().getPassword();
    final client = await _login(_username, _password);

    try {
      //client being null meant something went wrong
      if (client == null) {
        return MimeMessage();
      } else {
        String searchCriteria =
            'FROM ${senderFilter} ON ${_formatTargetDateForSearch(date)} SUBJECT "${subjectFilter}"';

        List<ReturnOption> returnOptions = [];
        ReturnOption option = ReturnOption("all");
        returnOptions.add(option);

        final searchResult =
            await client.searchMessages(searchCriteria: searchCriteria);

        //extract sequence id
        int? seqID;
        final matchingSequence = searchResult.matchingSequence;
        if (matchingSequence != null) {
          seqID = matchingSequence.isNotEmpty
              ? matchingSequence.elementAt(0)
              : null;
          // this gets the sequence id of the desired email
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
      await _logout(client);
    }
  }

  Future<bool> getImapClient(_username, _password) async {
    try {
      final client = await _login(_username, _password);
      if (client == null) {
        // print('Unable to discover settings for $email');
        return false;
      } else {
        var loggedIn = client.isLoggedIn;
        await client.logout();
        return loggedIn;
      }
    } on ImapException catch (e) {
      print('IMAP failed with $e');
      return false;
    }
  }

  /// Log in to the IMAP client for email retrieval
  Future<ImapClient?> _login(String _username, String _password) async {
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
        await client.login(_username, _password);
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
