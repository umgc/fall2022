import 'package:firebase_auth/firebase_auth.dart';
import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:summer2022/firebase_options.dart';
import 'package:summer2022/ui/main_menu.dart';
import 'package:summer2022/ui/sign_in.dart';

class UserAuthService {
  static final UserAuthService _instance = UserAuthService._internal();
  factory UserAuthService() {
    return _instance;
  }
  UserAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn =
      GoogleSignIn(scopes: [GmailApi.gmailReadonlyScope]);

  Future<AuthClient> get googleClient async {
    AuthClient client = (await _googleSignIn.authenticatedClient())!;
    return client;
  }

  Future<String> get googleUserId async {
    final client = await UserAuthService().googleClient;
    final tokenStr = client.credentials.accessToken;
    final res = await get(Uri.parse(
        'https://www.googleapis.com/gmail/vi/users/me/profile?access_token=$tokenStr'));
    if (res.statusCode != 200) {
      return "";
    }
    final body = jsonDecode(res.body);
    final email = body["emailAddress"].toString();
    return email;
  }

  Future<bool> get isSignedIntoGoogle async {
    return await _googleSignIn.isSignedIn();
  }

  handleAuthState() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            return MainWidget();
          } else {
            return const SignInWidget();
          }
        });
  }

  Future<bool> signInGoogleEmail() async {
    try {
      await _googleSignIn.signIn();
      return _googleSignIn.isSignedIn();
    } catch (error) {
      print(error);
      return false;
    }
  }

  signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
            clientId: DefaultFirebaseOptions.currentPlatform.iosClientId)
        .signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  signInWithApple() async {
    final appleProvider = AppleAuthProvider();
    appleProvider.addScope('email');

    if (kIsWeb) {
      // Once signed in, return the UserCredential
      return await _auth.signInWithPopup(appleProvider);
    } else {
      return await _auth.signInWithProvider(appleProvider);
    }
  }

  signInWithYahoo() async {
    final yahooProvider = YahooAuthProvider();

    if (kIsWeb)
      // Once signed in, return the UserCredential
      return await _auth.signInWithPopup(yahooProvider);
    else
      return await _auth.signInWithProvider(yahooProvider);
  }

  signInWithMicrosoft() async {
    final microsoftProvider = MicrosoftAuthProvider();

    if (kIsWeb) {
      await _auth.signInWithPopup(microsoftProvider);
    } else {
      await _auth.signInWithProvider(microsoftProvider);
    }

    return await FirebaseAuth.instance.currentUser
        ?.reauthenticateWithProvider(microsoftProvider);
  }

  // signOut
  signOut() {
    FirebaseAuth.instance.signOut();
    _googleSignIn.signOut();
  }
}
