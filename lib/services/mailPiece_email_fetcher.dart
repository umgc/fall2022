import 'package:summer2022/services/mail_utility.dart';
import '../models/Digest.dart';


/// The mail_retrieveByMailPiece class searches for a specific digest email matching a specific date from a mailPiece
class MailPieceEmailFetcher{

  DateTime _timeStamp;

  /// Fetch the email using the mailPiece provided date
  /// from `uspsinformeddelivery@email.informeddelivery.usps.com`
  /// with the subject `Your Daily Digest`.

  //Scott H is trying to add this to mail_fetcher.  No need for separate file.

  MailPieceEmailFetcher(this._timeStamp);

  /// Retrieve emails based on a sender filter, and subject filter. _timeStamp created with constructor
  Future<Digest> getMailPieceDigest() async {
        MailUtility mail = new MailUtility();
        Digest digest = Digest(await mail.getEmailOn(_timeStamp,"USPSInformeddelivery@email.informeddelivery.usps.com",
          "Your Daily Digest"));
        return digest;
  }

}
/*
  /// Retrieve emails based on a sender filter, and subject filter.  _timeStamp created with constructor
  Future<MimeMessage> _getMailPieceEmail(String senderFilter, String subjectFilter) async {

    //get the client logged in
    final client = await _login();

    try {
      //client being null meant something went wrong
      if (client == null) {
        return MimeMessage();
      } else {
        String searchCriteria = 'FROM ${senderFilter} ON ${_formatTargetDateForSearch(_timeStamp!)} SUBJECT "${subjectFilter}"';
        debugPrint(searchCriteria);

        List<ReturnOption> returnOptions = [];
        ReturnOption option = ReturnOption("all");
        returnOptions.add(option);
        final searchResult = await client.searchMessages(searchCriteria: searchCriteria);
        //extract sequence id
        int? seqID;
        final matchingSequence = searchResult.matchingSequence;
        if (matchingSequence != null) {
          seqID = matchingSequence.isNotEmpty ? matchingSequence.elementAt(0) : null;
          // this gets the sequence id of the desired email
        }
        if (seqID != null) {
          //Fetch Email Results
          final fetchedMessage = await client.fetchMessage(seqID, 'BODY.PEEK[]');
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

  /// Log in to the IMAP client for email retrieval
  Future<ImapClient?> _login() async {
    String _username = await Keychain().getUsername();
    String _password = await Keychain().getPassword();

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

   */
