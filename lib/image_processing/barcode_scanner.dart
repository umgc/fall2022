import 'dart:io';
import 'dart:async';
import '../models/Code.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeScannerApi {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  String? _path;
  InputImage? inputImage;
  bool _isBusy = false;

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load(path);

    //final file = File('${(await getTemporaryDirectory()).path}\\image.png');
    final file =
        File('${(await getApplicationDocumentsDirectory()).path}/image.png');

    if (!file.path.contains('test')) {
      try {
        await file.writeAsBytes(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
      } catch (e) {
        rethrow;
      }
    }

    return file;
  }

  void setImageFromPath(String path) {
    inputImage = InputImage.fromFilePath(path);
  }

  void setImageFromFile(File img) {
    inputImage = InputImage.fromFile(img);
  }

  Future<List<CodeObject>> processImage([InputImage? img]) async {
    List<CodeObject> codes = [];

    if (_isBusy) return codes;

    _isBusy = true;

    if (img != null) {
      inputImage = img;
    }

    var barcodes = <Barcode>[];
    if (_path != null || inputImage != null) {
      try {
        barcodes = await _barcodeScanner.processImage(inputImage!);
      } catch (e) {
        rethrow;
      } finally {
        for (final barcode in barcodes) {
          var type = "other";
          switch (barcode.type) {
            case BarcodeType.url:
              type = "qr";
              break;
            case BarcodeType.product:
            case BarcodeType.isbn:
              type = "bar";
              break;
            case BarcodeType.unknown:
            case BarcodeType.contactInfo:
            case BarcodeType.email:
            case BarcodeType.phone:
            case BarcodeType.sms:
            case BarcodeType.text:
            case BarcodeType.wifi:
            case BarcodeType.geoCoordinates:
            case BarcodeType.calendarEvent:
            case BarcodeType.driverLicense:
              type = "other";
              break;
          }
          //print("Barcode type: ${type}\nBarcode value: ${barcode.rawValue}");
          codes.add(CodeObject(type: type, info: barcode.rawValue as String));
        }
      }
      _isBusy = false;
    }

    return codes;
  }
}
