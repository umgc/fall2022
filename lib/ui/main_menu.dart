import 'dart:typed_data';
import 'dart:io';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/image_processing/imageProcessing.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/email_processing/digest_email_parser.dart';
import 'package:summer2022/email_processing/other_mail_parser.dart';
import 'package:summer2022/speech_commands/read_info.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:summer2022/main.dart';
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
  double commonButtonHeight = 60;
  double commonCornerRadius = 8;
  bool selectDigest = false;
  bool ranTutorial = false;
  CommandTutorial commandTutorial = CommandTutorial();

  @override
  void initState() {
    super.initState();
    stt.setCurrentPage("main", this);
    if (GlobalConfiguration().getValue("tutorial")) {
      _completed ??= commandTutorial.runTutorial();
    }
  }

  void setMailType(String type) {
    mailType = type;
  }

  ButtonStyle commonButtonStyleElevated(Color? primary, Color? shadow) {
    return ElevatedButton.styleFrom(
      textStyle:
          TextStyle(fontWeight: FontWeight.w700, fontSize: commonFontSize),
      primary: primary,
      shadowColor: shadow,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(commonCornerRadius))),
      side: BorderSide(width: commonBorderWidth, color: Colors.black),
    );
  }

  ButtonStyle commonButtonStyleText(Color? primary, Color? shadow) {
    return TextButton.styleFrom(
      textStyle: TextStyle(fontWeight: commonFontWt, fontSize: commonFontSize),
      primary: primary,
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
          stop(); // stop tts
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
          stop(); // stop tts
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
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Main Menu",
            style:
                TextStyle(fontWeight: commonFontWt, fontSize: commonFontSize),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.grey,
        ),
        body: SafeArea(
            child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                    height: 630,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: commonButtonHeight,
                                    child: OutlinedButton.icon(
                                      onPressed: () => selectDate(context),
                                      icon: const Icon(
                                        Icons.calendar_month_outlined,
                                        size: 35,
                                      ),
                                      label: Text(formattedSelectedDate,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: commonFontSize - 3,
                                          )),
                                      style: commonButtonStyleText(
                                          Colors.black, Colors.grey),
                                    ),
                                  ),
                                  SizedBox(
                                    height: commonButtonHeight,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.grey
                                            .shade300, //background color of dropdown button
                                        borderRadius: BorderRadius.circular(
                                            commonCornerRadius), //border raiuds of dropdown button
                                      ),
                                      child: OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/settings');
                                        },
                                        icon: const Icon(
                                          Icons.settings,
                                          size: 45,
                                        ),
                                        label: const Text(""),
                                        style: commonButtonStyleText(
                                            Colors.black, Colors.grey),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: commonButtonHeight,
                                    child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.grey
                                              .shade300, //background color of dropdown button
                                          borderRadius: BorderRadius.circular(
                                              commonCornerRadius), //border raiuds of dropdown button
                                        ),
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, '/notifications');
                                          },
                                          icon: const Icon(
                                            Icons.notifications,
                                            size: 45,
                                          ),
                                          label: const Text(""),
                                          style: commonButtonStyleText(
                                              Colors.black, Colors.grey),
                                        ),
                                    ),
                                  ),
                                ]),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SizedBox(
                                        height: commonButtonHeight,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.grey
                                                .shade200, //background color of dropdown button
                                            border: Border.all(
                                                color: Colors.black,
                                                width:
                                                    commonBorderWidth), //border of dropdown button
                                            borderRadius: BorderRadius.circular(
                                                commonCornerRadius), //border raiuds of dropdown button
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 20),
                                            child: DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                    value: mailType,
                                                    items: [
                                                      DropdownMenuItem<String>(
                                                        value: "Email",
                                                        child: Text(
                                                            "Email Mode",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    commonFontWt,
                                                                fontSize:
                                                                    commonFontSize)),
                                                      ),
                                                      DropdownMenuItem<String>(
                                                        value: "Digest",
                                                        child: Text(
                                                            "Digest Mode",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    commonFontWt,
                                                                fontSize:
                                                                    commonFontSize)),
                                                      ),
                                                    ],
                                                    onChanged: (String?
                                                        valueSelected) {
                                                      setState(() {
                                                        mailType =
                                                            valueSelected!;
                                                      });
                                                    })),
                                          ),
                                        )),
                                  ),
                                ),
                              ]),
                          Center(
                            child: Row(
                                // LATEST and UNREAD Buttons
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  latestButton,
                                  if (mailType == "Email") unreadButton,
                                ]),
                          ),
                          Row(
                            children: [
                              Spacer(),
                              SizedBox(
                                height: commonButtonHeight, // SCAN MAIL Button
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.grey
                                        .shade400, //background color of dropdown button
                                    borderRadius: BorderRadius.circular(
                                        commonCornerRadius), //border raiuds of dropdown button
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final pickedFile = await picker.getImage(
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
                                        ReadDigestMail readMail =
                                            ReadDigestMail();
                                        print(s.toJson());
                                        readMail.setCurrentMail(s);
                                        await readMail.readDigestInfo();
                                      } else {
                                        return;
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 40,
                                    ),
                                    label: const Text("Scan Mail"),
                                    style: commonButtonStyleText(
                                        Colors.black, Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: commonButtonHeight,
                                width: 80, // SCAN MAIL Button
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.grey
                                        .shade400, //background color of dropdown button
                                    borderRadius: BorderRadius.circular(
                                        commonCornerRadius), //border raiuds of dropdown button
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final pickedFile = await picker.getImage(
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
                                        ReadDigestMail readMail =
                                            ReadDigestMail();
                                        print(s.toJson());
                                        readMail.setCurrentMail(s);
                                        await readMail.readDigestInfo();
                                      } else {
                                        return;
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.image_search,
                                      size: 40,
                                    ),
                                    label: const Text(""),
                                    style: commonButtonStyleText(
                                        Colors.black, Colors.grey),
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          Padding(
                            // MODE Dialog Box
                            padding: const EdgeInsets.only(top: 0, bottom: 20),
                            child: SizedBox(
                              height: commonButtonHeight,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/sign_in');
                                },
                                style: commonButtonStyleElevated(
                                    Colors.black, Colors.grey),
                                child: const Text(
                                  "  Sign Out  ",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          /*SizedBox(height: commonButtonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/backend_testing');
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) => const BackendPage(
                        //               title: "USPS Backend Testing",
                        //             )));
                      },
                      style: commonButtonStyleElevated(Colors.grey, Colors.grey),
                      child: const Text("Backend Testing",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),*/
                        ])))));
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
