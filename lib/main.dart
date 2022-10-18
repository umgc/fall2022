// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/services/assistantService.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/ui/search.dart';
import 'package:summer2022/utility/Client.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/ui/main_menu.dart';
import 'package:summer2022/ui/sign_in.dart';
import 'package:summer2022/utility/RouteGenerator.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:summer2022/utility/auth_service.dart';
import 'package:summer2022/utility/locator.dart';
import 'firebase_options.dart';
import 'package:receive_intent/receive_intent.dart' as recieveIntent;
import 'dart:io' show Platform;

import 'models/ApplicationFunction.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // needed to access Keychain prior to main finishing
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GlobalConfiguration cfg = GlobalConfiguration();
  await setupLocator();
  await cfg.loadFromAsset("app_settings");
  var emailAuthenticated = false; // default false go to signin page
  String? username = await Keychain().getUsername();
  String? password = await Keychain().getPassword();
  if (username != null && password != null) {
    emailAuthenticated = (await Client().getImapClient(
        username, password)); //Replace with config read for credentials
  }

  String? emailDomain =
      username?.substring(username.indexOf("@") + 1, username.length);

  // Cache emails
  if (emailAuthenticated) {
    await CacheService.updateMail(username, password);
  }

  runApp(GlobalLoaderOverlay(
      child: MaterialApp(
        //showSemanticsDebugger: true,
        title: "MailSpeak", //title: "USPS Informed Delivery Visual Assistance App",
        initialRoute: emailAuthenticated == true ? "/main" : "/sign_in",
        onGenerateRoute: RouteGenerator.generateRoute,
        home: AuthService().handleAuthState(), //buildScreen(emailAuthenticated),
        navigatorKey: navKey,
      )
  )
  );
}

Widget buildScreen(bool emailAuthenticated) {
  return emailAuthenticated == true ? const MainWidget() : const SignInWidget();
}
