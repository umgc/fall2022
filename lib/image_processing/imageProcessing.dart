import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import './google_cloud_vision_api.dart';
import './barcode_scanner.dart';
import '../models/Code.dart';
import '../models/Logo.dart';
import '../models/MailResponse.dart';
import './usps_address_verification.dart';

CloudVisionApi vision = CloudVisionApi();
BarcodeScannerApi? _barcodeScannerApi;
String filePath = '';
String imagePath = '';
final picker = ImagePicker();

deleteImageFiles() async {
  Directory? directory;
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
      print("Delete files from Externd/applicationDownload Directory: ${files[x].path}");
    } catch (e) {
      print("File$x does not exist");
    }
  }
  for (int x = 0; x < files2.length; x++) {
    try {
      files[x].delete();
      print("Delete files from temporary Directory: ${files2[x].path}");
    } catch (e) {
      print("File$x does not exist");
    }
  }
}

void processImageForLogo(String imagePath) async {
  // print("Inside processImageForLogo\n");
  var image = File(imagePath);
  var buffer = image.readAsBytesSync();
  var a = base64.encode(buffer);
  List<LogoObject> logos = await vision.searchImageForLogo(a);
  var output = '';
  for (var logo in logos) {
    output += "${logo.toJson()}\n";
  }
}

void processBarcode() async {
  // print("Inside process barcode\n");
  _barcodeScannerApi = BarcodeScannerApi();
  var fLoc = filePath;
  print(fLoc);
  File? img = await _barcodeScannerApi?.getImageFileFromAssets(filePath);

  _barcodeScannerApi!.setImageFromFile(img!);

  List<CodeObject> codes = await _barcodeScannerApi!.processImage();
  var output = '';
  for (var code in codes) {
    output += code.toJson().toString();
  }
  // print(output);
  // print("Exit ProcessBarcode");
}

Future<bool> saveImageFile(Uint8List imageBytes, String fileName) async {
  Directory? directory;
  try {
    if (Platform.isAndroid) {
      if (await _requestPermission(Permission.storage)) {
        // directory = await getExternalStorageDirectory();
        directory = await getApplicationDocumentsDirectory();
        imagePath = directory.path.toString();
        // print(directory.path);
      } else {
        if (await _requestPermission(Permission.photos)) {
          directory = await getTemporaryDirectory();
          imagePath = directory.path;
          // print(directory.path);
        } else {
          return false;
        }
      }
    }
    if (Platform.isIOS) {
      if (imageBytes.isNotEmpty) {
        directory = await getApplicationDocumentsDirectory();
        imagePath = directory.path;
        // print(directory.path);
      }
    }
    if (!await directory!.exists()) {
      await directory.create(recursive: true);
    }
    if (await directory.exists()) {
      File saveFile = File("${directory.path}/$fileName");
      saveFile.writeAsBytesSync(imageBytes);

      filePath = saveFile.path;
      // print("Directory" + directory.listSync().toString());
      return true;
    }
  } catch (e) {
    print("Something happened in saveImageFile method");
  }
  return false;
}

Future<bool> _requestPermission(Permission permission) async {
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
}

Future<MailResponse> processImage(String imagePath) async {
  CloudVisionApi vision = CloudVisionApi();
  print("processImage: $imagePath");
  var image = File(imagePath);
  var imageByte = image.readAsBytesSync();

  var a = base64.encode(imageByte);
  print(a);
  var objMr = await vision.search(a);
  for (var address in objMr.addresses) {
    address.validated =
        await UspsAddressVerification().verifyAddressString(address.address);
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
}
