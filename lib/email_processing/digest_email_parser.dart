import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:enough_mail/enough_mail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:summer2022/models/Code.dart';
import 'package:summer2022/image_processing/barcode_scanner.dart';
import 'package:summer2022/image_processing/usps_address_verification.dart';
import 'package:summer2022/services/mail_fetcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';

class DigestEmailParser {
  CloudVisionApi vision = CloudVisionApi();
  BarcodeScannerApi? _barcodeScannerApi;

  Future<Digest> createDigest(String userName, String password) async {
    try {
      Digest digest = Digest(await _getDigestEmail(userName, password));

        if (!digest.isNull()) {
          var fetcher = MailFetcher();
          digest.attachments = await _getAttachments(digest.message);
          digest.links = _getLinks(digest.message);
          digest.mailPieces = await fetcher.processEmail(digest.message);
        }
      return digest;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Attachment>> _getAttachments(MimeMessage m) async {
    try {
      await deleteImageFiles();
      List<Attachment> list = [];
      for (int x = 0; x < m.mimeData!.parts!.length; x++) {
        var firstLevel = m.mimeData!.parts!.elementAt(x);
        if (firstLevel.contentType?.value.toString().contains("image") ?? false) {
          var attachment = Attachment();
          attachment.attachment = firstLevel
              .decodeMessageData()
              .toString(); //These are base64 encoded images with formatting
          attachment.attachmentNoFormatting = attachment.attachment
              .toString()
              .replaceAll(
              "\r\n", ""); //These are base64 encoded images with formatting
          attachment.detailedInformation = await processImage(attachment.attachmentNoFormatting); //process image defined below
          list.add(attachment); //add attachment to list of attachments
        }
        if (firstLevel.parts != null && firstLevel.parts!.isNotEmpty) {
          for (int y = 0; y < firstLevel!.parts!.length; y++) {
            if (firstLevel!.parts!.elementAt(y).contentType?.value.toString().contains("image") ?? false) {
              var attachment = Attachment();
              attachment.attachment = firstLevel.parts!
                  .elementAt(y)
                  .decodeMessageData()
                  .toString(); //These are base64 encoded images with formatting
              attachment.attachmentNoFormatting = attachment.attachment
                  .toString()
                  .replaceAll(
                  "\r\n",
                  ""); //These are base64 encoded images with formatting
              attachment.detailedInformation = await processImage(attachment.attachmentNoFormatting); //process image defined below
              list.add(attachment); //add attachment to list of attachments
            }
          }
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  List<Link> _getLinks(MimeMessage m) {
    try {
      List<Link> list = [];
      RegExp linkExp = RegExp(
          r"(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])");
      String text = m.decodeTextPlainPart() ?? ""; //get body text of email
      //remove encoding to make text easier to interpret
      text = text.replaceAll('\r\n', " ");
      text = text.replaceAll('<', " ");
      text = text.replaceAll('>', " ");
      text = text.replaceAll(']', " ");
      text = text.replaceAll('[', " ");

      while (linkExp.hasMatch(text)) {
        var match = linkExp.firstMatch(text)?.group(0);
        Link link = Link();
        link.link = match.toString();
        link.info = text
            .split(match.toString())[0]
            .toString()
            .split('.')
            .last
            .toString()
            .trim(); //attempt to get information about the link
        list.add(link);
        text = text.substring(text.indexOf(match.toString()) +
            match
                .toString()
                .length); //remove the found link and continue searching
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<MimeMessage> _getDigestEmail(String username, String password) async {
    final client = ImapClient(isLogEnabled: true);
    try {
      //Retrieve the imap server config
      var config = await Discover.discover(username, isLogEnabled: false);
      if (config == null) {
        return MimeMessage();
      } else {
        var imapServerConfig = config.preferredIncomingImapServer;
        await client.connectToServer(
            imapServerConfig!.hostname as String, imapServerConfig.port as int,
            isSecure: imapServerConfig.isSecureSocket);
        await client.login(username, password);
        await client.selectInbox();

        String searchCriteria = 'FROM USPSInformeddelivery@email.informeddelivery.usps.com SUBJECT "Your Daily Digest"';
        final searchResult = await client.searchMessages(searchCriteria: searchCriteria);
        MessageSequence? matchingSequence = searchResult.matchingSequence;

        if (matchingSequence != null) {
          final messages = await client.fetchMessages(
              matchingSequence, 'BODY.PEEK[]');

          final messagesList = messages.messages;

          if (messagesList.isNotEmpty) {
            messagesList.sort((a, b) =>
                (a.decodeDate() ?? new DateTime(1970)).compareTo(
                    (b.decodeDate() ?? new DateTime(1970))));
            return messagesList.last;
          }
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

  deleteImageFiles() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }
      if (Platform.isAndroid) {
        directory = await getApplicationDocumentsDirectory();
      }

      Directory? directory2 = await getTemporaryDirectory();
      var files = directory?.listSync(recursive: false, followLinks: false);
      var files2 = directory2.listSync(recursive: false, followLinks: false);
      for (int x = 0; x < files!.length; x++) {
        try {
          var file = files[x];
          if (basename(file.path) == 'mailpiece.jpg') {
            file.delete();
          }
        } catch (e) {}
      }
      for (int x = 0; x < files2.length; x++) {
        try {
          var file = files[x];
          if (basename(file.path) == 'mailpiece.jpg') {
            file.delete();
          }
        } catch (e) {}
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<File?> saveImageFile(Uint8List imageBytes, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          if (await _requestPermission(Permission.photos)) {
            directory = await getTemporaryDirectory();
          } else {
            return null;
          }
        }
      }
      if (Platform.isIOS) {
        if (imageBytes.isNotEmpty) {
          directory = await getApplicationDocumentsDirectory();
          print(directory.path);
        }
      }
      if (!await directory!.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File("${directory.path}/$fileName");
        saveFile.writeAsBytesSync(imageBytes);

        return saveFile;
      }
    } catch (e) {}
    return null;
  }

  Future<bool> _requestPermission(Permission permission) async {
    try {
      if (await permission.isGranted) {
        return true;
      } else {
        var result = await permission.request();
        if (result == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<MailResponse> processImage(String imageData) async {
    try {
      CloudVisionApi vision = CloudVisionApi();

      var objMr = await vision.search(imageData);
      for (var address in objMr.addresses) {
        address.validated = await UspsAddressVerification()
            .verifyAddressString(address.address);
      }

      var file = await saveImageFile(base64Decode(imageData), "mailpiece.jpg");

      try {
        if (file != null) {
          _barcodeScannerApi = BarcodeScannerApi();
          _barcodeScannerApi!.setImageFromFile(file);

          List<CodeObject> codes = await _barcodeScannerApi!.processImage();
          for (final code in codes) {
            objMr.codes.add(code);
          }
        }
      } finally {
        if (file != null) {
          file.delete();
        }
      }
      return objMr;
    } catch (e) {
      rethrow;
    }
  }
}
