import 'dart:typed_data';
import 'dart:io';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/image_processing/imageProcessing.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/email_processing/digest_email_parser.dart';
import 'package:summer2022/email_processing/other_mail_parser.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:summer2022/models/Arguments.dart';
import 'package:summer2022/models/EmailArguments.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:summer2022/models/MailResponse.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  MainWidgetState createState() => MainWidgetState();
}

CloudVisionApi? vision = CloudVisionApi();

bool? _completed;

class MainWidgetState extends State<MainWidget> {
  DateTime selectedDate = DateTime.now();
  String mailType = "Email";
  File? _image;
  Uint8List? _imageBytes;
  final picker = ImagePicker();
  FontWeight commonFontWt = FontWeight.w700;
  double commonFontSize = 30;
  double commonBorderWidth = 2;
  double commonButtonHeight = 75;
  double commonCornerRadius = 8;
  bool selectDigest = false;
  bool ranTutorial = false;


  @override
  void initState() {
    super.initState();
  }

  void setMailType(String type) {
    mailType = type;
  }

  ButtonStyle commonButtonStyleElevated(Color? primary, Color? shadow) {
    return ElevatedButton.styleFrom(
      minimumSize: Size.fromHeight( commonButtonHeight ),
      textStyle:
          TextStyle(fontWeight: FontWeight.w700, fontSize: commonFontSize),
      backgroundColor: primary,
      shadowColor: shadow,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(commonCornerRadius))),
      side: BorderSide(width: commonBorderWidth, color: Colors.black),
    );
  }

  ButtonStyle commonButtonStyleText(Color? primary, Color? shadow) {
    return TextButton.styleFrom(
      textStyle: TextStyle(fontWeight: commonFontWt, fontSize: commonFontSize),
      backgroundColor: primary,
      shadowColor: shadow,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(commonCornerRadius))),
      side: BorderSide(width: commonBorderWidth, color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedSelectedDate =
        DateFormat('yyyy-MM-dd').format(selectedDate);
    var latestButton = SizedBox(
      height: commonButtonHeight, // LATEST Button
      child: OutlinedButton(
        onPressed: () async {
          if (mailType == "Email") {
            context.loaderOverlay.show();
            await getEmails(false, DateTime.now());
            if (emails.isNotEmpty) {
              Navigator.pushNamed(context, '/other_mail',
                  arguments: EmailWidgetArguments(emails));
            } else {
              showNoEmailsDialog();
            }
            context.loaderOverlay.hide();
          } else {
            context.loaderOverlay.show();
            await getDigest();
            if (!digest.isNull()) {
              Navigator.pushNamed(context, '/digest_mail',
                  arguments: MailWidgetArguments(digest));
            } else {
              showNoDigestDialog();
            }
            context.loaderOverlay.hide();
          }
        },
        style: commonButtonStyleElevated(Colors.white, Colors.grey),
        child: const Text("Latest", style: TextStyle(color: Colors.black)),
      ),
    );
    var unreadButton = SizedBox(
      height: commonButtonHeight, // UNREAD Button
      child: OutlinedButton(
        onPressed: () async {
          if (mailType == "Email") {
            context.loaderOverlay.show();
            await getEmails(true, DateTime.now());
            if ((emails.isNotEmpty)) {
              Navigator.pushNamed(context, '/other_mail',
                  arguments: EmailWidgetArguments(emails));
            } else {
              showNoEmailsDialog();
            }
            context.loaderOverlay.hide();
          } else {
            context.loaderOverlay.show();
            await getDigest();
            if (!digest.isNull()) {
              Navigator.pushNamed(context, '/digest_mail',
                  arguments: MailWidgetArguments(digest));
            } else {
              showNoDigestDialog();
            }
            context.loaderOverlay.hide();
          }
        },
        style: commonButtonStyleElevated(Colors.white, Colors.grey),
        child: const Text("Unread", style: TextStyle(color: Colors.black)),
      ),
    );

    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: "Main Menu"),
      /*PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: TopBar(title: "Main Menu"),
      ),*/
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
      //search button
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                    child:
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (mailType == "Email") {
                            context.loaderOverlay.show();
                            await getEmails(false, DateTime.now());
                            if (emails.isNotEmpty) {
                              Navigator.pushNamed(context, '/other_mail',
                                  arguments: EmailWidgetArguments(emails));
                            } else {
                              showNoEmailsDialog();
                            }
                            context.loaderOverlay.hide();
                          } else {
                            context.loaderOverlay.show();
                            await getDigest();
                            if (!digest.isNull()) {
                              Navigator.pushNamed(context, '/digest_mail',
                                  arguments: MailWidgetArguments(digest));
                            } else {
                              showNoDigestDialog();
                            }
                            context.loaderOverlay.hide();
                          }
                        },
                        style: commonButtonStyleElevated(
                            Colors.grey, Colors.grey),
                        icon: new Image.asset("assets/icon/search-icon.png", width: 50, height: 50),
                          label: Text("Search Mail",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: commonFontSize - 3,
                              )),
                      ),
                  ),
                   //daily digest
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                    child:
                    ElevatedButton.icon(
                      onPressed: () async {
                          if (mailType == "Email") {
                            context.loaderOverlay.show();
                            await getEmails(false, DateTime.now());
                            if (emails.isNotEmpty) {
                              Navigator.pushNamed(context, '/other_mail',
                                  arguments: EmailWidgetArguments(emails));
                            } else {
                              showNoEmailsDialog();
                            }
                            context.loaderOverlay.hide();
                          } else {
                            context.loaderOverlay.show();
                            await getDigest();
                            if (!digest.isNull()) {
                              Navigator.pushNamed(context, '/digest_mail',
                                  arguments: MailWidgetArguments(digest));
                            } else {
                              showNoDigestDialog();
                            }
                            context.loaderOverlay.hide();
                          }
                      },
                      style: commonButtonStyleElevated(
                          Colors.grey, Colors.grey),
                      icon: new Image.asset("assets/icon/calendar-icon.png", width: 50, height: 50),
                      label: Text("Daily Digest",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: commonFontSize - 3,
                          )),
                    ),
                  ),
                  //scan mail
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                    child:
                    ElevatedButton.icon(
                      onPressed: () async {
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
                      },
                      style: commonButtonStyleElevated(
                          Colors.grey, Colors.grey),
                      icon: new Image.asset("assets/icon/scanmail-icon.png", width: 50, height: 50),
                      label: Text("Scan Mail",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: commonFontSize - 3,
                          )),
                    ),
                  ),
      //upload mail
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                    child:
                    ElevatedButton.icon(
                      onPressed: () async {
                        final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery);
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
                      },
                      style: commonButtonStyleElevated(
                          Colors.grey, Colors.grey),
                      icon: new Image.asset("assets/icon/uploadmail-icon.png", width: 50, height: 50),
                      label: Text("Upload Mail",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: commonFontSize - 3,
                          )),
                    ),
                  ),
      //notifications
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                    child:
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '');
                      },
                      style: commonButtonStyleElevated(
                          Colors.grey, Colors.grey),
                      icon: new Image.asset("assets/icon/notifications-icon.png", width: 50, height: 50),
                      label: Text("Notifications",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: commonFontSize - 3,
                          )),
                    ),
                  ),
      //chatbot
                  /*Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                    child:
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/chat');
                      },
                      style: commonButtonStyleElevated(
                          Colors.grey, Colors.grey),
                      icon: new Image.asset("assets/icon/chatbot-icon.png", width: 50, height: 50),
                      label: Text("Chatbot",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: commonFontSize - 3,
                          )),
                    ),
                  ),*/
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 10),
                    child:
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/settings');
                      },
                      style: commonButtonStyleElevated(
                          Colors.grey, Colors.grey),
                      icon: new Image.asset("assets/icon/settings-icon.png", width: 50, height: 50),
                      label: Text("Settings",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: commonFontSize - 3,
                          )),
                    ),
                  ),
          ],
          ),
        )
    );
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime.now());
    if ((picked != null) && (picked != selectedDate)) {
      if (mailType == "Email") {
        context.loaderOverlay.show();
        await getEmails(false, picked);
        if ((emails.isNotEmpty)) {
          Navigator.pushNamed(context, '/other_mail',
              arguments: EmailWidgetArguments(emails));
        } else {
          showNoEmailsDialog();
        }
        context.loaderOverlay.hide();
      } else {
        context.loaderOverlay.show();
        await getDigest(picked);
        if (!digest.isNull()) {
          Navigator.pushNamed(context, '/digest_mail',
              arguments: MailWidgetArguments(digest));
        } else {
          showNoDigestDialog();
        }
        context.loaderOverlay.hide();
      }

      setState(() {
        selectedDate = picked;
      });
    }
  }

  void showNoDigestDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("No Digest Available"),
          ),
          content: SizedBox(
            height: 100.0, // Change as per your requirement
            width: 100.0, // Change as per your requirement
            child: Center(
              child: Text(
                "There is no Digest available for the selected date: ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  void showNoEmailsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(
            child: Text("No Emails Available"),
          ),
          content: SizedBox(
            height: 100.0, // Change as per your requirement
            width: 100.0, // Change as per your requirement
            child: Center(
              child: Text(
                "There are no emails available for the selected date: ${selectedDate.month}/${selectedDate.day}/${selectedDate.year}",
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Center(
            child: Text("Error Dialog"),
          ),
          content: SizedBox(
            height: 100.0,
            width: 100.0,
            child: Center(
              child: Text(
                "An Unexpected Error has occurred, please try again later.",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> selectOtherMailDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1970),
        lastDate: DateTime.now());
    if ((picked != null) && (picked != selectedDate)) {
      context.loaderOverlay.show();
      await getEmails(false, picked);
      if (emails.isNotEmpty) {
        Navigator.pushNamed(context, '/other_mail',
            arguments: EmailWidgetArguments(emails));
      } else {
        showNoEmailsDialog();
      }
      context.loaderOverlay.hide();
      setState(() {
        selectedDate = picked;
      });
    }
  }

  late Digest digest;
  late List<Digest> emails;

  Future<void> getDigest([DateTime? pickedDate]) async {
    try {
      await DigestEmailParser()
          .createDigest(await Keychain().getUsername(),
              await Keychain().getPassword(), pickedDate ?? selectedDate)
          .then((value) => digest = value);
    } catch (e) {
      showErrorDialog();
      context.loaderOverlay.hide();
    }
  }

  Future<void> getEmails(bool isUnread, [DateTime? pickedDate]) async {
    try {
      await OtherMailParser()
          .createEmailList(isUnread, await Keychain().getUsername(),
              await Keychain().getPassword(), pickedDate ?? selectedDate)
          .then((value) => emails = value);
    } catch (e) {
      showErrorDialog();
      context.loaderOverlay.hide();
    }
  }
}
