import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/email_processing/digest_email_parser.dart';
import 'package:summer2022/email_processing/other_mail_parser.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/image_processing/google_cloud_vision_api.dart';
import 'package:summer2022/models/Arguments.dart';
import 'package:summer2022/models/EmailArguments.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/locator.dart';
import 'package:summer2022/services/mail_loader.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/ui/assistant_state.dart';
import 'package:summer2022/ui/floating_home_button.dart';

class MainWidget extends StatefulWidget {
  final ApplicationFunction? function;
  const MainWidget({Key? key, this.function}) : super(key: key);

  @override
  MainWidgetState createState() => MainWidgetState();
}

CloudVisionApi? vision = CloudVisionApi();

class MainWidgetState extends AssistantState<MainWidget> {
  DateTime selectedDate = DateTime.now();
  String mailType = "Email";
  final mailLoader = MailLoader();
  FontWeight commonFontWt = FontWeight.w700;
  double commonFontSize = 26;
  double commonBorderWidth = 1;
  double commonButtonHeight = 50;
  double commonCornerRadius = 8;
  bool selectDigest = false;
  bool ranTutorial = false;
  var appbarPresent = true;
  var bottomBarPresent = true;
  var columnCount = 2;
  var minRowCountOnScreen = 3;

  @override
  void initState() {
    super.initState();
    locator<AnalyticsService>().logScreens(name: "Main Menu");
    WidgetsBinding.instance.addPostFrameCallback((_) => checkPassedInFunction());
  }

  void checkPassedInFunction()
  {
    if (this.widget.function != null) {
      processFunction(this.widget.function!);
    }
  }

  void setMailType(String type) {
    mailType = type;
  }

  ButtonStyle commonButtonStyleElevated(Color? primary, Color? shadow) {
    return ElevatedButton.styleFrom(
      minimumSize: Size.fromHeight(commonButtonHeight),
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
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
    var size = MediaQuery.of(context).size;
    var width = size.width;
    var height = size.height;
    if (appbarPresent) {
      height -= kToolbarHeight;
    }
    if (bottomBarPresent) {
      height -= kBottomNavigationBarHeight;
    }

    var aspectRatio = (width / columnCount) / (height / minRowCountOnScreen);
    return Scaffold(
        floatingActionButton: FloatingHomeButton(parentWidgetName: context.widget.toString()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const BottomBar(),
        appBar: TopBar(title: "Main Menu"),
        body: GridView.count(
          primary: false,
          padding: const EdgeInsets.all(4),
          crossAxisSpacing: columnCount.toDouble(),
          childAspectRatio: aspectRatio + .05,
          mainAxisSpacing: 6,
          crossAxisCount: 2,
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {

                Navigator.pushNamed(context, '/search');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Search Mail'),
                  Image.asset(
                    "assets/icon/search_mail_icon_lg.png",
                    width: aspectRatio * 125,
                    height: aspectRatio * 125,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              style: commonButtonStyleElevated(Colors.grey, Colors.grey),
            ),
            ElevatedButton(
              onPressed: _getDailyDigest,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Daily Digest'),
                  Image.asset(
                    "assets/icon/daily_digest_icon_lg.png",
                    width: aspectRatio * 125,
                    height: aspectRatio * 125,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              style: commonButtonStyleElevated(Colors.grey, Colors.grey),
            ),
            ElevatedButton(
              onPressed: () {
                mailLoader.uploadMail(ImageSource.gallery);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Upload Mail'),
                  Image.asset(
                    "assets/icon/upload_image_lg.png",
                    width: aspectRatio * 125,
                    height: aspectRatio * 125,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              style: commonButtonStyleElevated(Colors.grey, Colors.grey),
            ),
            ElevatedButton(
              onPressed: () {
                mailLoader.uploadMail(ImageSource.camera);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Scan Mail'),
                  Image.asset(
                    "assets/icon/scan_mail_icon_lg.png",
                    width: aspectRatio * 125,
                    height: aspectRatio * 125,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              style: commonButtonStyleElevated(Colors.grey, Colors.grey),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Settings'),
                  Image.asset(
                    "assets/icon/settings_icon_lg.png",
                    width: aspectRatio * 125,
                    height: aspectRatio * 125,
                    excludeFromSemantics: true,
                  ),
                ],
              ),
              style: commonButtonStyleElevated(Colors.grey, Colors.grey),
            ),
            ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Notifications'),
                        Image.asset(
                          "assets/icon/notification_icon_lg.png",
                          width: aspectRatio * 125,
                          height: aspectRatio * 125,
                          excludeFromSemantics: true,
                        ),
                      ],
                    ),
              style: commonButtonStyleElevated(Colors.grey, Colors.grey),
            ),
        ],
      ),
    );
  }

  void _getDailyDigest() async {
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

    void showNoDigestDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Center(
              child: Text("No Digest Available"),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text(
                  'Close'
              ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
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
            title: Center(
              child: Text("No Emails Available"),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text(
                  'Close'
              ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
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
          return AlertDialog(
            title: Center(
              child: Text.rich(
                TextSpan(
                  text: 'Error',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text(
                  'Close'
              ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
            content: SizedBox(
              height: 50.0, // Change as per your requirement
              width: 75.0, // Change as per your requirement
              child: Center(
                  child: Text.rich(
                      textAlign: TextAlign.left,
                      TextSpan(
                          text: 'An Unexpected Error has occurred, please try again later.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          )
                      )
                  )
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

  Future<void> getDigest() async {
    try {
      await DigestEmailParser()
          .createDigest(await Keychain().getUsername(),
              await Keychain().getPassword())
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
