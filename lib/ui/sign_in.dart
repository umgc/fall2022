import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/utility/Client.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'dart:convert';
import 'dart:math';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


typedef OAuthSignIn = void Function();

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

/// The mode of the current auth session, either [AuthMode.login] or [AuthMode.register].
// ignore: public_member_api_docs
enum AuthMode { login, register, phone }

extension on AuthMode {
  String get label => this == AuthMode.login ? 'Sign in' : 'Register';
}

/// Entrypoint example for various sign-in flows with Firebase.
class SignInWidget extends StatefulWidget {
  // ignore: public_member_api_docs
  const SignInWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  AuthMode mode = AuthMode.login;

  bool isLoading = false;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.isMacOS) {
      authButtons = {
        Buttons.Apple: () => _handleMultiFactorException(
              _signInWithApple,
            ),
      };
    } else {
      authButtons = {
        Buttons.Apple: () => _handleMultiFactorException(
              _signInWithApple,
            ),
        Buttons.Google: () => _handleMultiFactorException(
              _signInWithGoogle,
            ),
        Buttons.GitHub: () => _handleMultiFactorException(
              _signInWithGitHub,
            ),
        Buttons.Microsoft: () => _handleMultiFactorException(
              _signInWithMicrosoft,
            ),
        Buttons.Yahoo: () => _handleMultiFactorException(
              _signInWithYahoo,
            ),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SafeArea(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            visible: error.isNotEmpty,
                            child: MaterialBanner(
                              backgroundColor: Theme.of(context).errorColor,
                              content: Text(error),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      error = '';
                                    });
                                  },
                                  child: const Text(
                                    'dismiss',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                              contentTextStyle:
                                  const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.all(10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (mode == AuthMode.login)
                            Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                    hintText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required',
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Password',
                                    border: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(4.0))),
                                  ),
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required',
                                ),
                              ],
                            ),
                          Container(
                            padding: const EdgeInsets.only(top: 15),
                          ),
                          if (mode != AuthMode.login)
                            const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _handleMultiFactorException(
                                        _emailAndPassword,
                                      ),
                              child: isLoading
                                  ? const CircularProgressIndicator.adaptive()
                                  : Text(mode.label),
                            ),
                          ),
                          TextButton(
                            onPressed: _resetPassword,
                            child: const Text('Forgot password?'),
                          ),
                          ...authButtons.keys
                              .map(
                                (button) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: isLoading
                                        ? Container(
                                            color: Colors.grey[200],
                                            height: 50,
                                            width: double.infinity,
                                          )
                                        : SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: SignInButton(
                                              button,
                                              onPressed: authButtons[button]!,
                                            ),
                                          ),
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
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

  Future<void> _handleMultiFactorException(
    Future<void> Function() authFunction,
  ) async {
    setIsLoading();
    try {
      await authFunction();
    } on FirebaseAuthMultiFactorException catch (e) {
      setState(() {
        error = '${e.message}';
      });
      final firstHint = e.resolver.hints.first;
      if (firstHint is! PhoneMultiFactorInfo) {
        return;
      }
      final auth = FirebaseAuth.instance;
      await auth.verifyPhoneNumber(
        multiFactorSession: e.resolver.session,
        multiFactorInfo: firstHint,
        verificationCompleted: (_) {},
        verificationFailed: print,
        codeSent: (String verificationId, int? resendToken) async {
          final smsCode = await getSmsCodeFromUser(context);

          if (smsCode != null) {
            // Create a PhoneAuthCredential with the code
            final credential = PhoneAuthProvider.credential(
              verificationId: verificationId,
              smsCode: smsCode,
            );

            try {
              await e.resolver.resolveSignIn(
                PhoneMultiFactorGenerator.getAssertion(
                  credential,
                ),
              );
            } on FirebaseAuthException catch (e) {
              print(e.message);
            }
          }
        },
        codeAutoRetrievalTimeout: print,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _emailAndPassword() async {
    String email = emailController.text.toString();
    String password = passwordController.text.toString();
    //If email validated through enough mail then switch to the main screen, if not, add error text to the to show on the screen
    var loggedIn = await Client().getImapClient(email, password);
    if (loggedIn) {
      Keychain().addCredentials(email, password);
      await CacheService.updateMail(email, password);
      Navigator.pushNamed(context, '/main');
    } else {
      showLoginErrorDialog();
      context.loaderOverlay.hide();
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

  Future<void> _signInWithGoogle() async {
    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final googleAuth = await googleUser?.authentication;

    if (googleAuth != null) {
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);
    }
  }

  Future<void> _signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');

    if (kIsWeb) {
      // Once signed in, return the UserCredential
      await _auth.signInWithPopup(appleProvider);
    } else {
      await _auth.signInWithProvider(appleProvider);
    }
  }

  Future<void> _signInWithYahoo() async {
    final yahooProvider = YahooAuthProvider();

    if (kIsWeb) {
      // Once signed in, return the UserCredential
      await _auth.signInWithPopup(yahooProvider);
    } else {
      await _auth.signInWithProvider(yahooProvider);
    }
  }

  Future<void> _signInWithGitHub() async {
    final githubProvider = GithubAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(githubProvider);
    } else {
      await _auth.signInWithProvider(githubProvider);
    }
  }

  Future<void> _signInWithMicrosoft() async {
    final microsoftProvider = MicrosoftAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(microsoftProvider);
    } else {
      await _auth.signInWithProvider(microsoftProvider);
    }

    await FirebaseAuth.instance.currentUser?.reauthenticateWithProvider(
      microsoftProvider,
    );
  }
}

Future<String?> getSmsCodeFromUser(BuildContext context) async {
  String? smsCode;

  // Update the UI - wait for the user to enter the SMS code
  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text('SMS code:'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Sign in'),
          ),
          OutlinedButton(
            onPressed: () {
              smsCode = null;
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
        content: Container(
          padding: const EdgeInsets.all(20),
          child: TextField(
            onChanged: (value) {
              smsCode = value;
            },
            textAlign: TextAlign.center,
            autofocus: true,
          ),
        ),
      );
    },
  );

  return smsCode;
}
