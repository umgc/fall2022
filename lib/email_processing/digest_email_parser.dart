import 'dart:convert';
import 'dart:ffi';
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
  CloudVisionApi vision = CloudVisionApi();
  BarcodeScannerApi? _barcodeScannerApi;
  String filePath = '';
  String imagePath = '';

  Future<Digest> createDigest(String userName, String password) async {
    try {
      Digest digest = Digest(await _getDigestEmail(userName, password));

        if (!digest.isNull()) {
        digest.attachments = await _getAttachments(digest.message);
        digest.links = _getLinks(digest.message);
      }
      return digest;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Attachment>> _getAttachments(MimeMessage m) async {
    try {
      List<Attachment> list = [];
      await deleteImageFiles(); //this method deletes the current list of user images in the app local directory
      for (int x = 0; x < m.mimeData!.parts!.length; x++) {
        var firstLevel = m.mimeData!.parts!.elementAt(x);
        if (firstLevel.parts != null && firstLevel.parts!.isNotEmpty) {
          for (int y = 0; y < firstLevel!.parts!.length; y++) {
            if (firstLevel
            !.parts
            !.elementAt(y)
                .contentType
                ?.value
                .toString()
                .contains("image") ??
                false) {
              var attachment = Attachment();
              attachment.attachment = firstLevel.parts!
                  .elementAt(y)
                  .decodeMessageData()
                  .toString(); //These are base64 encoded images with formatting
              attachment.attachmentNoFormatting = attachment.attachment
                  .toString()
                  .replaceAll(
                  "\r\n", ""); //These are base64 encoded images with formatting
              /* get the position of element with value "image" and save to attachment.  delete all returns */
              await saveImageFile(
                  base64Decode(attachment.attachmentNoFormatting),
                  "mailpiece$y.jpg");
              attachment.detailedInformation =
              await processImage(filePath); //process image defined below
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

  String _formatTargetDateForSearch(DateTime date) {
    final DateFormat format = DateFormat('dd-MMM-yyyy');
    return format.format(date);
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

        // directory = await getExternalStorageDirectory();
      }

      Directory? directory2 = await getTemporaryDirectory();
      var files = directory?.listSync(recursive: false, followLinks: false);
      var files2 = directory2.listSync(recursive: false, followLinks: false);
      for (int x = 0; x < files!.length; x++) {
        try {
          files[x].delete();
          print("Delete in Extern: ${files[x].path}");
        } catch (e) {
          print("File$x does not exist");
        }
      }
      for (int x = 0; x < files2.length; x++) {
        try {
          files[x].delete();
          print("Delete: ${files2[x].path}");
        } catch (e) {
          print("File$x does not exist");
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> saveImageFile(Uint8List imageBytes, String fileName) async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        if (await _requestPermission(Permission.storage)) {
          // directory = await getExternalStorageDirectory();
          directory = await getApplicationDocumentsDirectory();
          imagePath = directory.path.toString();
          print(directory.path);
        } else {
          if (await _requestPermission(Permission.photos)) {
            directory = await getTemporaryDirectory();
            imagePath = directory.path;
            print(directory.path);
          } else {
            return false;
          }
        }
      }
      if (Platform.isIOS) {
        if (imageBytes.isNotEmpty) {
          directory = await getApplicationDocumentsDirectory();
          imagePath = directory.path;
          print(directory.path);
        }
      }
      if (!await directory!.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File("${directory.path}/$fileName");
        saveFile.writeAsBytesSync(imageBytes);

        filePath = saveFile.path;
        print("Directory${directory.listSync()}");
        return true;
      }
    } catch (e) {
      debugPrint("Something happened in saveImageFile method");
    }
    return false;
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

  Future<MailResponse> processImage(String imagePath) async {
    try {
      CloudVisionApi vision = CloudVisionApi();
      print("processImage: $imagePath");
      var image = File(imagePath);
      Uint8List imageByte;
      imageByte = image.readAsBytesSync();

      var a = base64.encode(imageByte);
      print(a);
      var objMr = await vision.search(a);
      for (var address in objMr.addresses) {
        address.validated = await UspsAddressVerification()
            .verifyAddressString(address.address);
      }
      _barcodeScannerApi = BarcodeScannerApi();
      File img = File(filePath);
      _barcodeScannerApi!.setImageFromFile(img);

      List<CodeObject> codes = await _barcodeScannerApi!.processImage();
      for (final code in codes) {
        objMr.codes.add(code);
      }
      print(objMr.toJson());
      return objMr;
    } catch (e) {
      rethrow;
    }
  }
}
