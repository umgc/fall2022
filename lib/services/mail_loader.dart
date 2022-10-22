import 'dart:io';
import 'package:summer2022/image_processing/imageProcessing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/models/MailResponse.dart';

class MailLoader {
  final picker = ImagePicker();

  void uploadMail(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final bytes = File(pickedFile.path).readAsBytesSync();
    await deleteImageFiles();
    await saveImageFile(bytes, "mailpiece.jpg");
    MailResponse response = await processImage("$imagePath/mailpiece.jpg");
    await CacheService.processUploadedMailPiece(response);
  }
}