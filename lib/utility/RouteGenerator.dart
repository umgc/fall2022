import 'package:flutter/material.dart';
import 'package:summer2022/ui/chat_widget.dart';
import 'package:summer2022/ui/mail_widget.dart';
import 'package:summer2022/ui/main_menu.dart';
import 'package:summer2022/ui/notifications.dart';
import 'package:summer2022/ui/other_mail.dart';
import 'package:summer2022/ui/settings.dart';
import 'package:summer2022/ui/sign_in.dart';
import 'package:summer2022/backend_testing.dart';
import 'package:summer2022/models/Arguments.dart';
import 'package:summer2022/models/EmailArguments.dart';
import 'package:summer2022/ui/search.dart';
import 'package:summer2022/ui/mail_view.dart';

// Enum defining all areas of the application
enum SiteAreas { Home, Settings, Search, SearchResults, MailView, NotificationManage, NotificationView }

class RouteGenerator {
  static SiteAreas previousRoute = SiteAreas.Home;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    _updatePreviousRoute(settings.name!);
    switch (settings.name) {
      case '/main':
        return MaterialPageRoute(builder: (_) => const MainWidget());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsWidget());
      case '/digest_mail':
        return MaterialPageRoute(
            builder: (_) => MailWidget(
                digest: (settings.arguments as MailWidgetArguments).digest));
      case '/sign_in':
        return MaterialPageRoute(builder: (_) => const SignInWidget());
      case '/other_mail':
        return MaterialPageRoute(
            builder: (_) => OtherMailWidget(
                emails: (settings.arguments as EmailWidgetArguments).emails));
      case '/backend_testing':
        return MaterialPageRoute(
            builder: (_) => const BackendPage(title: "Backend Testing"));
      case '/chat':
        return MaterialPageRoute(
            builder: (_) => ChatWidget(
              currentPage: previousRoute
        ));
      case '/search':
        var parameters = settings.arguments != null ? settings.arguments as List<String> : <String>[];
        return MaterialPageRoute(
            builder: (_) => SearchWidget(parameters: parameters));
      case '/mail_view':
        return MaterialPageRoute(
            builder: (_) => MailViewWidget());
      case '/notifications':
        return MaterialPageRoute(
            builder: (_) => NotificationsWidget());
      default:
        return MaterialPageRoute(builder: (_) {
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
