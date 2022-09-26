// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/utility/Client.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/ui/main_menu.dart';
import 'package:summer2022/ui/sign_in.dart';
import 'package:summer2022/utility/RouteGenerator.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'dart:io' show Platform;

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // needed to access Keychain prior to main finishing
  GlobalConfiguration cfg = GlobalConfiguration();
  await cfg.loadFromAsset("app_settings");
  var emailAuthenticated = false; // default false go to signin page
  String? username = await Keychain().getUsername();
  String? password = await Keychain().getPassword();
  if (username != null && password != null) {
    emailAuthenticated = (await Client().getImapClient(
        username, password)); //Replace with config read for credentials
  }

  runApp(GlobalLoaderOverlay(
      child: MaterialApp(
    title: "USPS Informed Delivery Visual Assistance App",
    initialRoute: emailAuthenticated == true ? "/main" : "/sign_in",
    onGenerateRoute: RouteGenerator.generateRoute,
    home: buildScreen(emailAuthenticated),
    navigatorKey: navKey,
  )));
}

Widget buildScreen(bool emailAuthenticated) {
  return Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(50),
      child: TopBar(),
    ),
    body:
        emailAuthenticated == true ? const MainWidget() : const SignInWidget(),
    bottomNavigationBar: const BottomBar(),
  );
}
