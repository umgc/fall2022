import 'package:enough_mail/enough_mail.dart';

class Client {
  Client();

  Future<bool> getImapClient(String username, String password) async {
    final client = ImapClient(isLogEnabled: false);
    var config = await Discover.discover(username, isLogEnabled: false);
    if (config == null) {
      // print('Unable to discover settings for $email');
      return false;
    } else {
      var imapServerConfig = config.preferredIncomingImapServer;
      try {
        await client.connectToServer(
            imapServerConfig!.hostname as String, imapServerConfig.port as int,
            isSecure: imapServerConfig.isSecureSocket);
        await client.login(username, password);
        var loggedIn = client.isLoggedIn;
        await client.logout();
        return loggedIn;
      } on ImapException catch (e) {
        print('IMAP failed with $e');
        return false;
      }
    }
  }

/* Derived from enough_mail*/
  Future<ServerConfig?> getServerConfigFromEmail(String email) async {
    var config = await Discover.discover(email, isLogEnabled: false);
    if (config == null) {
      // print('Unable to discover settings for $email');
      return null;
    } else {
      // print('Settings for $email:');
      for (var provider in config.emailProviders!) {
        print(provider.preferredIncomingServer);
        return provider.preferredIncomingServer;
      }
    }
  }
}
