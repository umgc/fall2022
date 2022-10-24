import 'dart:typed_data';

import 'package:googleapis/gmail/v1.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:summer2022/utility/user_auth_service.dart';

// https://medium.com/@dexcell/dart-singleton-async-cb605a10fd60

class GmailApiService {
  final _client = UserAuthService().googleClient;

  static GmailApi? _api;
  Future<GmailApi> get api async {
    if (_api != null) return _api!;

    _api = GmailApi(await _client);
    return _api!;
  }

  Future<List<MimeMessage>> fetchMail(Map<String, String> query) async {
    List<MimeMessage> retval = [];
    var gmailApi = await api;

    // Build query to search emails
    var parsedQuery = "";
    query.forEach((key, value) {
      parsedQuery += key + value + " ";
    });
    var userId = await UserAuthService().googleUserId;
    ListMessagesResponse res =
        await gmailApi.users.messages.list(userId, q: parsedQuery);
    List<Message> listMsg = res.messages!;

    // parse individual emails matching query
    for (var i = 0; i < listMsg.length; i++) {
      Message rawMsg = await gmailApi.users.messages
          .get(userId, listMsg[i].id!, format: "raw");
      retval.add(
          MimeMessage.parseFromData(Uint8List.fromList(rawMsg.rawAsBytes)));
    }
    return retval;
  }
}
