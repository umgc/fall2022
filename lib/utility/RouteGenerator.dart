import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fall2022/models/MailPiece.dart';
import 'package:fall2022/ui/chat_widget.dart';
import 'package:fall2022/ui/mail_widget.dart';
import 'package:fall2022/ui/main_menu.dart';
import 'package:fall2022/ui/notifications.dart';
import 'package:fall2022/ui/other_mail.dart';
import 'package:fall2022/ui/settings.dart';
import 'package:fall2022/ui/sign_in.dart';
import 'package:fall2022/backend_testing.dart';
import 'package:fall2022/models/Arguments.dart';
import 'package:fall2022/models/EmailArguments.dart';
import 'package:fall2022/ui/search.dart';
import 'package:fall2022/ui/mail_view.dart';

import '../services/mail_service.dart';
import '../ui/mail_view_indv.dart';

// Enum defining all areas of the application
enum SiteAreas { Home, Settings, Search, SearchResults, MailView, NotificationManage, NotificationView }

class RouteGenerator {
  static SiteAreas previousRoute = SiteAreas.Home;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    _updatePreviousRoute(settings.name!);
    switch (settings.name) {
      case '/main':
        return CupertinoPageRoute(builder: (_) => const MainWidget());
      case '/settings':
        return CupertinoPageRoute(builder: (_) => const SettingsWidget());
      case '/digest_mail':
        return CupertinoPageRoute(
            builder: (_) => MailWidget(
                digest: (settings.arguments as MailWidgetArguments).digest));
      case '/sign_in':
        return CupertinoPageRoute(builder: (_) => const SignInWidget());
      case '/other_mail':
        return CupertinoPageRoute(
            builder: (_) => OtherMailWidget(
                emails: (settings.arguments as EmailWidgetArguments).emails));
      case '/backend_testing':
        return CupertinoPageRoute(
            builder: (_) => const BackendPage(title: "Backend Testing"));
      case '/chat':
        return CupertinoPageRoute(
            builder: (_) => ChatWidget(
              currentPage: previousRoute
        ));
      case '/search':
        var parameters = settings.arguments != null ? settings.arguments as List<String> : <String>[];
        return CupertinoPageRoute(
            builder: (_) => SearchWidget(parameters: parameters));
      case '/mail_view':
        return CupertinoPageRoute(
            builder: (_) => MailViewWidget());
      case '/mail_piece_view':
        var parameters =  settings.arguments as MailPiece;
        return CupertinoPageRoute(
            builder: (_) => MailPieceViewWidget(mailPiece: parameters));
      case '/notifications':
        return CupertinoPageRoute(
            builder: (_) => NotificationsWidget());
      default:
        return CupertinoPageRoute(builder: (_) {
          return Scaffold(
              body: Center(
            child: Text("No route for ${settings.name}"),
          ));
        });
    }
  }

  // Update previous route to new route if it matches any valid routes
  // This is for use by the ChatBot to determine the user's page
  // TODO: Probably a better way to handle this with Navigator/navkey
  static void _updatePreviousRoute(String newRoute) {
    switch (newRoute) {
      case '/mail_view':
        previousRoute = SiteAreas.MailView;
        break;
      case '/main':
        previousRoute = SiteAreas.Home;
        break;
      case '/settings':
        previousRoute = SiteAreas.Settings;
        break;
      case '/search':
        previousRoute = SiteAreas.Search;
        break;
      default:
        break;
    }
  }
}
