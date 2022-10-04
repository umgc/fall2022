import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:summer2022/image_processing/imageProcessing.dart';
import 'package:summer2022/models/MailResponse.dart';


class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  DateTime selectedDate = DateTime.now();
  String mailType = "Email";
  File? _image;
  Uint8List? _imageBytes;
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color.fromRGBO(51, 51, 102, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Spacer(),
          Semantics(
            excludeSemantics: true,
            button: true,
            label: "Search Mail",
            onTap: () {
              Navigator.pushNamed(context, "/search");
            },
            child:
            IconButton(
              icon: new Image.asset("assets/icon/search-icon.png"),
              onPressed: () {
                Navigator.pushNamed(context, "/search");
              },
            ),
          ),
          Spacer(),
          Semantics(
            excludeSemantics: true,
            button: true,
            label: "Scan Mail",
            onTap: _scanMail,
            child:
            IconButton(
              icon: new Image.asset("assets/icon/scanmail-icon.png"),
              onPressed: _scanMail,
            ),
          ),
          Spacer(),
          Semantics(
            excludeSemantics: true,
            button: true,
            label: "Chatbot",
            onTap: () {
              Navigator.pushNamed(context, "/chat");
            },
            child:
            IconButton(
              icon: new Image.asset("assets/icon/chatbot-icon.png"),
              onPressed: () {
                Navigator.pushNamed(context, "/chat");
                },
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
  void _scanMail() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera);
    print(pickedFile!.path);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      _imageBytes = _image!.readAsBytesSync();
      await deleteImageFiles();
      await saveImageFile(
          _imageBytes!, "mailpiece.jpg");
      MailResponse s = await processImage(
          "$imagePath/mailpiece.jpg");
      print(s.toJson());
    } else {
      return;
    }
  }
}