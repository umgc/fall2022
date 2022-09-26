import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/utility/Client.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/locator.dart';


class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: "Sign In"),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 50),
              ),
              Container(
                padding: const EdgeInsets.only(top: 150),
                color: const Color.fromRGBO(228, 228, 228, 0.6),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 25, right: 25),
                            child: TextField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'E-Mail Address',
                              ),
                              controller: emailController,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 50),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 25, right: 25),
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
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 150),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: OutlinedButton(
                              onPressed: () async {
                                String email =
                                    emailController.text.toString();
                                String password =
                                    passwordController.text.toString();
                                //If email validated through enough mail then switch to the main screen, if not, add error text to the to show on the screen
                                var loggedIn = await Client()
                                    .getImapClient(email, password);
                                //Store the credentials into the the secure storage only if validated
                                if (loggedIn) {
                                  Keychain().addCredentials(email, password);
                                  Navigator.pushNamed(context, '/main');
                                } else {
                                  showLoginErrorDialog();
                                  context.loaderOverlay.hide();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shadowColor: Colors.grey,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 50),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
