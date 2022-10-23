// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/services/assistantService.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/services/mail_utility.dart';
import 'package:summer2022/services/background_service.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/ui/main_menu.dart';
import 'package:summer2022/ui/sign_in.dart';
import 'package:summer2022/utility/RouteGenerator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:summer2022/utility/locator.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;
import 'firebase_options.dart';
import 'models/ApplicationFunction.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // needed to access Keychain prior to main finishing
  GlobalConfiguration cfg = GlobalConfiguration();
  await setupLocator();
  await cfg.loadFromAsset("app_settings");
  BackgroundService.init();

  var emailAuthenticated = false; // default false go to signin page
  String? username = await Keychain().getUsername();
  String? password = await Keychain().getPassword();
  if (username != null && password != null) {
    // Check that email and password still can login
    MailUtility mail = new MailUtility();
    emailAuthenticated = (await mail.getImapClient(
        username, password)); //Replace with config read for credentials
  }

  String? emailDomain =
      username?.substring(username.indexOf("@") + 1, username.length);

  // Cache emails
  if (emailAuthenticated) {
    await CacheService.updateMail();
    BackgroundService.registerBackgroundUpdates();
  }

  if (Firebase.apps.length == 0) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseAnalytics.instance
        .setUserProperty(name: 'email_domain', value: emailDomain);
  }

  ApplicationFunction? function;
  try {
    receiveIntent.Intent? intent =
        await receiveIntent.ReceiveIntent.getInitialIntent();
    if (intent != null) {
      function = AssistantService.ParseIntent(intent!);
    }
  } catch (e) {
    print("ios does not support receive_intent pkg");
  }

  runApp(GlobalLoaderOverlay(
      child: MaterialApp(
    //showSemanticsDebugger: true,
    title: "MailSpeak", //title: "USPS Informed Delivery Visual Assistance App",
    initialRoute: emailAuthenticated == true ? "/main" : "/sign_in",
    onGenerateRoute: RouteGenerator.generateRoute,
    home: buildScreen(emailAuthenticated, function),
    navigatorKey: navKey,
  )));
}

Widget buildScreen(bool emailAuthenticated, ApplicationFunction? function) {
  return emailAuthenticated == true
      ? MainWidget(function: function)
      : SignInWidget(function: function);
}
