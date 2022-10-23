import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/main.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/services/mail_notifier.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/sign_in.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/utility/locator.dart';

import 'assistant_state.dart';


class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  SettingWidgetState createState() => SettingWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();

class SettingWidgetState extends AssistantState<SettingsWidget> {
  GlobalConfiguration cfg = GlobalConfiguration();

  @override
  void initState() {
    super.initState();
    locator<AnalyticsService>().logScreens(name: "Settings");
    //FirebaseAnalytics.instance.setCurrentScreen(screenName: "Settings");
    /*FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'screenName': 'Settings',
        'screenClass': 'settings.dart',
      },
    );*/
  }

  void showTermsAndConditionsDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.only(top: 17, left: 20, right: 20, bottom: 20),
            title: Center(
                child: Text.rich(
                    TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        )
                    )
                )
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))
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
            content: Container(
              height: 300,
              width: 400,
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 5,
                radius: Radius.circular(20),
                scrollbarOrientation: ScrollbarOrientation.right,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        TextSpan(
                            text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. \n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                            style: TextStyle(
                              fontSize: 14,
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        );
      },
    );
  }

  void showPrivacyPolicyDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.only(top: 17, left: 20, right: 20, bottom: 20),
            title: Center(
                child: Text.rich(
                    TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        )
                    )
                )
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))
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
            content: Container(
              height: 300,
              width: 400,
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 5,
                radius: Radius.circular(20),
                scrollbarOrientation: ScrollbarOrientation.right,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        TextSpan(
                            text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. \n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                            style: TextStyle(
                              fontSize: 14,
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        );
      },
    );
  }

  void askConfirmationDialog() {
    Widget noButton =
        TextButton(onPressed: () => Navigator.pop(context), child: Text("No"));
    Widget yesButton =
        TextButton(onPressed: () => _deleteEverything(), child: Text("Yes"));

    //setup Alert Dialog
    AlertDialog confirmation = AlertDialog(
      title: Text("Delete Confirmation"),
      content: Text(
          "Are you sure you want to delete all cached data?  This will delete everything and log you out."),
      actions: [yesButton, noButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return confirmation;
        });
  }

  void _deleteEverything() {
    // Remove saved login
    Keychain().deleteAll();
    // reset to default app settings
    cfg.loadFromAsset("app_settings");
    // clear cache
    CacheService.getInstance(null, null).clearAllCachedData();
    // return to login screen
    Navigator.pushNamed(context, '/sign_in');
  }

  @override
  Widget build(BuildContext context) {
    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: showHomeButton,
        child: FloatingHomeButton(parentWidgetName: context.widget.toString()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: 'Settings'),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                          leading: Icon(
                            Icons.mail,
                          ),
                          title: Text.rich(
                            TextSpan(
                              text: "Envelope Details",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("sender"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Sender ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("sender", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.person_search,
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("address"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Sender Address ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("address", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.place,
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("recipient"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Recipient ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("recipient", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.person_pin_sharp,
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("logos"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Logos ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("logos", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.image,
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("links"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Links:",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("links", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.link,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Icon(
                          Icons.mark_email_unread,
                        ),
                        title: Text.rich(
                          TextSpan(
                            text: "Email Details",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("email_subject"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Subject: ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("email_subject", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.short_text_sharp,
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("email_text"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Email Text: ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("email_text", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.text_snippet,
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("email_sender"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Sender Address: ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("email_sender", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.alternate_email_sharp,
                        ),
                      ),
                      SwitchListTile(
                        value: cfg.getValue("email_recipients"),
                        activeColor: Colors.indigo.shade400,
                        contentPadding: const EdgeInsets.only(left: 17, right: 17),
                        title: Text.rich(
                          TextSpan(
                            text: "Recipients: ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        onChanged: (bool value) {
                          setState(() {
                            cfg.updateValue("email_recipients", value);
                          });
                        },
                        secondary: const Icon(
                          Icons.person_pin_sharp,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Card(
                        elevation: 0,
                        child: ListTile(
                          leading: Icon(
                            Icons.content_paste_search_sharp,
                          ),
                          title: Text.rich(
                            TextSpan(
                              text: "Legal Notices",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey, width: 0.75)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 25, right: 25),
                          title: Text.rich(
                            TextSpan(
                              text: "Terms and Conditions",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded),
                          onTap: () {
                            showTermsAndConditionsDialog();
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey, width: 0.75)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 25, right: 25),
                          title: Text.rich(
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                            trailing: Icon(Icons.keyboard_arrow_right_rounded),
                          onTap: () {
                            showPrivacyPolicyDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                    alignment: Alignment.center,
                    child: OutlinedButton(
                      onPressed: () async {
                        askConfirmationDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(231, 25, 33, 1),
                        shadowColor: Colors.grey,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                      ),
                      child: const Text(
                        "Delete All Local Data",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
