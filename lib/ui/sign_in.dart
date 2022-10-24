import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/utility/user_auth_service.dart';
import 'package:summer2022/utility/locator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/mail_utility.dart';
import 'assistant_state.dart';

/// Helper class to show a snackbar using the passed context.
class ScaffoldSnackbar {
  // ignore: public_member_api_docs
  ScaffoldSnackbar(this._context);

  /// The scaffold of current context.
  factory ScaffoldSnackbar.of(BuildContext context) {
    return ScaffoldSnackbar(context);
  }

  final BuildContext _context;

  /// Helper method to show a SnackBar.
  void show(String message) {
    ScaffoldMessenger.of(_context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class SignInWidget extends StatefulWidget {
  final ApplicationFunction? function;
  const SignInWidget({Key? key, this.function}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends AssistantState<SignInWidget> {
  var url1 = Uri.parse("https://www.google.com/policies/privacy/");
  var url2 = Uri.parse("https://firebase.google.com/policies/analytics");
  var url3 =
      Uri.parse("https://www.apple.com/legal/privacy/data/en/app-store/");
  var url4 = Uri.parse("https://informeddelivery.usps.com");
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  static const kPrimaryColor = Color(0xFF6F35A5);
  static const kPrimaryLightColor = Color(0xFFF1E6FF);
  static const double defaultPadding = 16.0;
  bool checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => checkPassedInFunction());
    locator<AnalyticsService>().logScreens(name: "signIn");

    //FirebaseAnalytics.instance.setCurrentScreen(screenName: "SignIn");
    /*FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'screenName': 'SignIn',
        'screenClass': 'signIn.dart',
      },
    );*/
  }

  void checkPassedInFunction() {
    if (this.widget.function != null) {
      processFunction(this.widget.function!);
    }
  }

  @override
  Future<void> processFunction(ApplicationFunction function) async {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Center(
            child: Text("Please Login"),
          ),
          content: SizedBox(
            height: 50.0, // Change as per your requirement
            width: 75.0, // Change as per your requirement
            child: Center(
              child: Text(
                "You must be logged in to do this.",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showLoginErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text("Login Error"),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                padding: MaterialStateProperty.all(
                    EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                textStyle: MaterialStateProperty.all(
                  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
          content: SizedBox(
            height: 50.0, // Change as per your requirement
            width: 75.0, // Change as per your requirement
            child: Center(
              child: Text(
                "Login credentials failed.",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }

  void showTermsAndPrivacyAgreementErrorDialog() {
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
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
            content: SizedBox(
              height: 75.0,
              width: 75.0,
              child: Center(
                  child: Text.rich(
                      textAlign: TextAlign.left,
                      TextSpan(
                          text:
                              'Please indicate that you have read and agree to the Terms and Conditions and Privacy Policy',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          )))),
            ));
      },
    );
  }

  void showTermsAndConditionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding:
                EdgeInsets.only(top: 17, left: 20, right: 20, bottom: 20),
            title: Center(
                child: Text.rich(TextSpan(
                    text: 'Terms and Conditions',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    )))),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
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
                            text:
                                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. \n\nLorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                            style: TextStyle(
                              fontSize: 14,
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  void showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding:
                EdgeInsets.only(top: 17, left: 20, right: 20, bottom: 20),
            title: Center(
                child: Text.rich(TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    )))),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(
                    TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
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
                      RichText(
                          text: TextSpan(children: [
                        TextSpan(
                          text:
                              'Privacy Policy\n\n[Our Name] has created a free app called MailSpeak. This Mobile Application is provided at no cost and is intended for use as is. \n\nThis page is used to inform app users of our policies regarding the collection, use, and disclosure of Personal Information should they decide to use our Service.\n\nIf you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.\n\nInformation Collection and Use\n\nFor a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to email, email password. The information that we request will be retained by us and used as described in this privacy policy. \n\nThe app does use third party services that may collect information used to identify you.\n\nLink to privacy policy of third-party service providers used by the app',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                            text: '\n\n• Google Play Services\n\n',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(url1);
                              }),
                        TextSpan(
                            text: '• Google Firebase Analytics\n\n',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(url2);
                              }),
                        TextSpan(
                            text: '• Apple App Store\n\n',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(url3);
                              }),
                        TextSpan(
                          text:
                              'Affiliates and Business Partners\n\nWe share your information with our affiliates and business partners for internal business purposes, including for customer support, evaluation, marketing, and technical operations. \n\nLog Data\n\nWe want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics. \n\nCookies\n\nCookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your devices internal memory. \n\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service. \n\nService Providers\n\nWe may employ third-party companies and individuals due to the following reasons: \n\n•To facilitate our Service; \n\n•To provide the Service on our behalf; \n\n•To perform Service-related services; or\n\n•To assist us in analyzing how our Service is used. \n\nWe want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose. \n\nSecurity\n\nWe value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security. \n\nLinks to Other Sites\n\nThis Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services. \n\nChildren’s Privacy\n\nThese Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions.\n\nChanges to This Privacy Policy\n\nWe may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.\n\nContact Us\n\nIf you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us.\n\n',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ]))
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(51, 51, 102, 1),
      //bottomNavigationBar: const BottomBar(),
      //appBar: TopBar(title: "Sign In"),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 800.0,
          child: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(15.0),
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
                //padding: const EdgeInsets.all(2.0),
                //child: Text("MailSpeak"),
                child: Form(
                  child: Column(
                    children: [
                      /*Container(
                          alignment: Alignment.center,
                          child: Text("MailSpeak",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),)
                        ),*/
                      Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                            "assets/icon/applogo-mailspeak-200.png"),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        alignment: Alignment.center,
                        child: Text("USPS Informed Delivery Registered Email"),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 15),
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'E-Mail Address',
                          ),
                          controller: emailController,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 15),
                        alignment: Alignment.center,
                        child: TextField(
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          controller: passwordController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Password',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            Checkbox(
                              value: checked,
                              onChanged: (value) {
                                setState(() {
                                  checked = value ?? false;
                                });
                              },
                            ),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                    text: 'I have read and agree to the ',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Terms and Conditions',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              showTermsAndConditionsDialog();
                                            }),
                                      TextSpan(
                                          text: ' and ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: 'Privacy Policy',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.blue,
                                                    fontWeight: FontWeight.bold,
                                                    decoration: TextDecoration
                                                        .underline),
                                                recognizer:
                                                    TapGestureRecognizer()
                                                      ..onTap = () {
                                                        showPrivacyPolicyDialog();
                                                      })
                                          ])
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                          alignment: Alignment.center,
                          child: OutlinedButton(
                            onPressed: () async {
                              if (checked != true) {
                                showTermsAndPrivacyAgreementErrorDialog();
                                //If check box is not ticked off, show error dialog
                              } else {
                                // .trim() removes any leading and trailing white spaces
                                String email =
                                    emailController.text.toString().trim();
                                String password =
                                    passwordController.text.toString().trim();
                                //If email validated through enough mail then switch to the main screen, if not, add error text to the to show on the screen
                                if (email.isNotEmpty && password.isNotEmpty) {
                                  //check for that email and password provided can successfully login
                                  MailUtility mail = new MailUtility();
                                  var loggedIn =
                                      await mail.getImapClient(email, password);
                                  //Store the credentials into the the secure storage only if validated
                                  if (loggedIn) {
                                    Keychain().addCredentials(email, password);
                                    await CacheService.updateMail();
                                    //Navigates to Main Menu and clears navigation stack to prevent login screen access with back gesture
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/main',
                                        (Route<dynamic> route) => false);
                                  } else {
                                    showLoginErrorDialog();
                                    context.loaderOverlay.hide();
                                  }
                                } else {
                                  showLoginErrorDialog();
                                  context.loaderOverlay.hide();
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(51, 51, 102, 1),
                              shadowColor: Colors.grey,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            child: const Text(
                              "RETRIEVE MAIL",
                              style: TextStyle(color: Colors.white),
                            ),
                          )),
                      Container(
                          child: RichText(
                              text: TextSpan(children: [
                        TextSpan(
                          text: 'Not registered, ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                            text: 'touch here.',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrl(url4);
                              }),
                      ]))),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 35, right: 35),
                                  child: SignInButton(
                                    Buttons.Google,
                                    onPressed: () async {
                                      // To get oauth token
                                      bool success = await UserAuthService()
                                          .signInGoogleEmail();

                                      if (success) {
                                        await CacheService.updateMail();
                                        Navigator.pushNamed(context, '/main');
                                      } else {
                                        showLoginErrorDialog();
                                        context.loaderOverlay.hide();
                                      }
                                    },
                                    text: 'Sign In with Google',
                                  ),
                                ))
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
