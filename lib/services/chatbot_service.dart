import 'dart:collection';

import 'package:enough_mail/enough_mail.dart';
import 'package:summer2022/exceptions/invalid_command_exception.dart';
import 'package:summer2022/services/interfaces/ichatbot_service.dart';
import 'package:summer2022/utility/RouteGenerator.dart';

class ChatbotService implements IChatbotService {
  Map<SiteAreas, List<String>> ChatFunctions = HashMap();

  /**
   * Default constructor
   */
  ChatbotService() {
    _populateChatFunctions();
  }

  @override
  void performChatFunction(SiteAreas currentArea, String userInput) {
    var parsedInput = userInput.split(' ');

    try {
      // Attempt to retrieve the first word (command)
      String? commandFunction = ChatFunctions[currentArea]?.firstWhere((e) => e == parsedInput[0],
          orElse: throw InvalidCommandException("Could not find matching function " + parsedInput[0])
      );

      // Remove command from parseInput so we only have the parameters to pass
      parsedInput.removeAt(0);

      _implementCommand(commandFunction.toString(), parsedInput);
    } catch (InvalidCommandException) {
      // TODO: Send response command was unsuccessful
    }
  }

  /**
   * Populates chatFunctions HashMap with possible commands per site area
   */
  void _populateChatFunctions() {
    // This list of functions should be available on all pages
    var availableOnAllPages = <String>[
      "logout", "help"
    ];

    ChatFunctions[SiteAreas.Home] = <String>[
      "search",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.MailView] = <String>[
      "home",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.NotificationManage] = <String>[
      "home",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.NotificationView] = <String>[
      "home",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.Search] = <String>[
      "home",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.SearchResults] = <String>[
      "home",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.Settings] = <String>[
      "home",
      ...availableOnAllPages
    ];
  }

  /**
   * Implement command (navigation/population/etc)
   */
  void _implementCommand(String command, List<String> parameters) {
      // TODO: Reflection to determine commands or custom actions
  }
}