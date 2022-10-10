import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/utility/Client.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/utility/locator.dart';

import 'assistant_state.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends AssistantState<SignInWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  static const kPrimaryColor = Color(0xFF6F35A5);
  static const kPrimaryLightColor = Color(0xFFF1E6FF);
  static const double defaultPadding = 16.0;
  bool checked = false;

  @override
  void initState() {
    super.initState();

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
  @override
  void processFunction(ApplicationFunction function)
  {
    //TODO put a dialog explaining why this won't work.
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
        return const AlertDialog(
          title: Center(
            child: Text("Login Error"),
          ),
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
        return const AlertDialog(
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
          content: SizedBox(
            height: 75.0,
            width: 75.0,
            child: Center(
                child: Text.rich(
                  textAlign: TextAlign.left,
                  TextSpan(
                      text: 'Please indicate that you have read and agree to the Terms and Conditions and Privacy Policy',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      )
                  )
                )
            ),
          )
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(51, 51, 102, 1),
      //bottomNavigationBar: const BottomBar(),
      //appBar: TopBar(title: "Sign In"),
      body: SingleChildScrollView(
        child: Container(
        width: MediaQuery.of(context).size.width,
        height: 700.0,
        child: SafeArea(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children:[
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
                          child: Image.asset("assets/icon/applogo-mailspeak-200.png" ),
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
                                  fontSize: 14, color: Colors.black
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'Terms and Conditions',
                                    style: TextStyle(
                                      fontSize: 14, color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      showTermsAndConditionsDialog();
                                    }
                                  ),
                                  TextSpan(
                                    text: ' and ',
                                    style: TextStyle(
                                      fontSize: 14, color: Colors.black
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: 'Privacy Policy', style: TextStyle(
                                          fontSize: 14, color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline
                                      ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              showPrivacyPolicyDialog();
                                            }
                                      )
                                    ]
                                  )
                                ]
                              ),
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
                            String email = emailController.text.toString();
                            String password = passwordController.text.toString();
                            //If email validated through enough mail then switch to the main screen, if not, add error text to the to show on the screen
                            var loggedIn = await Client()
                                .getImapClient(email, password);
                            //Store the credentials into the the secure storage only if validated
                            if (loggedIn) {
                              Keychain().addCredentials(email, password);
                              await CacheService.updateMail(email, password);
                              Navigator.pushNamed(context, '/main');
                            } else {
                              showLoginErrorDialog();
                              context.loaderOverlay.hide();
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(51, 51, 102, 1),
                          shadowColor: Colors.grey,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                        ),
                        child: const Text(
                          "RETRIEVE MAIL",
                          style: TextStyle(color: Colors.white)                          ,
                        ),
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15, bottom: 15),
                      alignment: Alignment.center,
                      child: Text(
                        "Not registered, click here."),
                    ),
                      ],
                    ),
                  ),
              ),
            ]
            ),
          ),
        ),
        ),
    );
  }
}
