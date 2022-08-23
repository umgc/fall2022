import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:summer2022/image_processing/barcode_scanner.dart';
import 'package:summer2022/models/Code.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUpAll(() {
    const channel = MethodChannel(
      'plugins.flutter.io/path_provider_macos',
    );
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
          return "test/data";
        default:
      }
    });
  });
  group("QR/Barcode Test", () {
    test('Scanner must recognize QR Code', () async {
      const MethodChannel('google_mlkit_barcode_scanning')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'vision#startBarcodeScanner') {
          var json = [
            {
              "type": 8,
              "format": 10,
              "displayValue": "https://qrco.de/bczuEB",
              "rawValue": "https://qrco.de/bczuEB",
              "rawBytes": Uint8List.fromList([
                104,
                116,
                116,
                112,
                115,
                58,
                47,
                47,
                113,
                114,
                99,
                111,
                46,
                100,
                101,
                47,
                98,
                99,
                122,
                117,
                69,
                66
              ]),
              "boundingBoxLeft": 394.0,
              "boundingBoxTop": 619.0,
              "boundingBoxRight": 505.0,
              "boundingBoxBottom": 730.0,
              "cornerPoints": [
                {"x": 394, "y": 619},
                {"x": 505, "y": 619},
                {"x": 504, "y": 727},
                {"x": 395, "y": 730}
              ],
              "url": "https://qrco.de/bczuEB",
              "title": "TD Bank"
            }
          ];
          return json;
        }
        return null;
      });

      BarcodeScannerApi scanner = BarcodeScannerApi();
      File f = await scanner.getImageFileFromAssets('assets/mail.test.03.png');
      InputImage img = InputImage.fromFile(f);
      List<CodeObject> codes = await scanner.processImage(img);
      expect(codes.length, 1);
    });
    test('Scanner must not recognize QR Code', () async {
      const MethodChannel('google_mlkit_barcode_scanning')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'vision#startBarcodeScanner') {
          return [];
        }
        return null;
      });

      BarcodeScannerApi scanner = BarcodeScannerApi();
      File f = await scanner.getImageFileFromAssets('assets/mail.test.02.png');
      InputImage img = InputImage.fromFile(f);
      List<CodeObject> codes = await scanner.processImage(img);
      expect(codes.length, 0);
    });
    test('Scanner must recognize barcode', () async {
      const MethodChannel('google_mlkit_barcode_scanning')
          .setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'vision#startBarcodeScanner') {
          return [
            {
              "type": 7,
              "format": 3,
              "displayValue": "ES303",
              "rawValue": "ES303",
              "rawBytes": Uint8List.fromList([]),
              "boundingBoxLeft": 394.0,
              "boundingBoxTop": 619.0,
              "boundingBoxRight": 505.0,
              "boundingBoxBottom": 730.0,
              "cornerPoints": [
                {"x": 394, "y": 619},
                {"x": 505, "y": 619},
                {"x": 504, "y": 727},
                {"x": 395, "y": 730}
              ],
            }
          ];
        }
        return null;
      });

      BarcodeScannerApi scanner = BarcodeScannerApi();
      File f = await scanner.getImageFileFromAssets('assets/mail.test.04.png');
      InputImage img = InputImage.fromFile(f);
      List<CodeObject> codes = await scanner.processImage(img);
      expect(codes.length, 1);
    });
  });
}
