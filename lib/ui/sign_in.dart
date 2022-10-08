import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/cloudsearch/v1.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/utility/Client.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'dart:convert';
import 'dart:math';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:summer2022/utility/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;

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
  // ignore: public_member_api_docs
  const SignInWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: "Sign In"),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 30),
              ),
              Container(
                padding: const EdgeInsets.only(top: 80),
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
                      padding: const EdgeInsets.only(top: 50),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 50, right: 50),
                            child: OutlinedButton(
                              onPressed: () async {
                                String email = emailController.text.toString();
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
                                backgroundColor: Color.fromRGBO(51, 51, 102, 1),
                                shadowColor: Colors.grey,
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              child: const Text(
                                "Login",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextButton(
                        onPressed: _resetPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text("OR",
                          style: TextStyle(
                              color: Color.fromARGB(255, 45, 46, 153))),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                padding:
                                    const EdgeInsets.only(left: 35, right: 35),
                                child: SignInButton(
                                  Buttons.Google,
                                  onPressed: () {
                                    Navigator.pushNamed(context,
                                        AuthService().signInWithGoogle());
                                  },
                                  text: 'Google Login',
                                ),
                              ))
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                padding:
                                    const EdgeInsets.only(left: 35, right: 35),
                                child: SignInButton(
                                  Buttons.AppleDark,
                                  onPressed: () {
                                    Navigator.pushNamed(context,
                                        AuthService().signInWithApple());
                                  },
                                  text: 'Apple Sign In',
                                ),
                              )),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                padding:
                                    const EdgeInsets.only(left: 35, right: 35),
                                child: SignInButton(
                                  Buttons.GitHub,
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context,
                                        AuthService()
                                            .signInWithGithub(context));
                                  },
                                  text: 'Github Login',
                                ),
                              )),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                padding:
                                    const EdgeInsets.only(left: 35, right: 35),
                                child: SignInButton(Buttons.Microsoft,
                                    onPressed: () {
                                  Navigator.pushNamed(context,
                                      AuthService().signInWithMicrosoft());
                                }, text: 'Microsoft LogIn'),
                              )),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 20),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                padding:
                                    const EdgeInsets.only(left: 35, right: 35),
                                child: SignInButton(
                                  Buttons.Yahoo,
                                  onPressed: () {
                                    Navigator.pushNamed(context,
                                        AuthService().signInWithYahoo());
                                  },
                                  text: 'Yahoo Sign In',
                                ),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 50),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: email!);
        ScaffoldSnackbar.of(context).show('Password reset email is sent');
      } catch (e) {
        ScaffoldSnackbar.of(context).show('Error resetting');
      }
    }
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
}
