import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/vision/v1.dart';
import 'package:fall2022/image_processing/google_cloud_vision_api.dart';
import 'package:fall2022/models/Address.dart';
import 'package:fall2022/models/Logo.dart';
import 'package:fall2022/models/MailResponse.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io' as io;

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;
  group("CloudVision Tests", () {
    test("Cloud Vision Credentials Test - Credentials File loaded", () async {
      String error = '';
      try {
        await rootBundle.loadString('assets/credentials.json');
      } catch (e) {
        error = e.toString();
      }
      expect(error, '');
    });
    //TODO: re-enable when account is re-activated
    test(
        'Cloud Vision Image Information Retrieval Test - Receives Text from image',
        () async {
      CloudVisionApi vision = CloudVisionApi();
      var image = await rootBundle.load('assets/mail.test.01.jpg');
      var buffer = image.buffer;
      var a = base64.encode(Uint8List.view(buffer));
      //print("Image: $image\nBuffer: $buffer\na: $a\n");
      List<TextAnnotation> textAnnotations = await vision.convertImageToText(a);
      List<AddressObject> addresses = await vision.searchImageForText(textAnnotations);
      //print(s.toJson());
      expect(addresses[0].getName, 'GEICO');
      expect(addresses[0].getAddress, '2563 Forest Dr; Annapolis, MD 21401');
      expect(addresses[1].getName, 'Deborah Keenan');
      expect(addresses[1].getAddress,
          '1006 Morgan Station Dr; Severn, MD 21144-1245');
    }, skip: true);
    //TODO: re-enable when account is re-activated
    test('Cloud Vision Logo Detection Test - Receives Logo information',
        () async {
      CloudVisionApi vision = CloudVisionApi();
      var image = await rootBundle.load('assets/mail.test.01.jpg');
      var buffer = image.buffer;
      var a = base64.encode(Uint8List.view(buffer));
      //print("Image: $image\nBuffer: $buffer\na: $a\n");
      List<LogoObject> logos = await vision.searchImageForLogo(a);
      //print(s.toJson());
      expect(logos[0].getName, 'GEICO');
    }, skip: true);
    //TODO: re-enable when account is re-activated
    test(
        'Cloud Vision Daily Digest Test- For each image, the application uses the api to retrieve information and consolidates (JSON).',
        () async {
      CloudVisionApi vision = CloudVisionApi();
      var image = await rootBundle.load('assets/mail.test.01.jpg');
      var buffer = image.buffer;
      var a = base64.encode(Uint8List.view(buffer));
      //print("Image: $image\nBuffer: $buffer\na: $a\n");
      MailResponse mail = await vision.search(a);
      //print(mail.toJson().toString());
      expect(mail.toJson().toString(),
          '{addresses: [{type: sender, name: GEICO, address: 2563 Forest Dr; Annapolis, MD 21401, validated: false}, {type: recipient, name: Deborah Keenan, address: 1006 Morgan Station Dr; Severn, MD 21144-1245, validated: false}], logos: [{name: GEICO}, {name: GEICO}], codes: []}');
    }, skip: true);
    //TODO: re-enable when account is re-activated
    test('Cloud Vision Image Verification illegible- Returns empty object',
        () async {
      CloudVisionApi vision = CloudVisionApi();
      var image = await rootBundle.load('assets/horusx.jpg');
      var buffer = image.buffer;
      var a = base64.encode(Uint8List.view(buffer));
      //print("Image: $image\nBuffer: $buffer\na: $a\n");
      MailResponse mail = await vision.search(a);
      //print(mail.toJson().toString());
      expect(mail.addresses.length, 0);
      expect(mail.logos.length, 0);
      //expect(mail.logos[0].name, 'None');
    }, skip: true);
  });
  // group("Camera Tests", () {
  //   test("Camera Test 1 - ", () async {
  //     String error = '';
  //     final picker = ImagePicker();
  //     final LostDataResponse response = await picker.retrieveLostData();
  //     if (response.isEmpty) {
  //       return;
  //     }
  //     if (response.files != null) {
  //       print(response.file!.name + "/" + response.file!.path);
  //     }
  //   });
  // });
}
