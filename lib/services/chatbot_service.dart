import 'dart:collection';
import 'package:summer2022/exceptions/invalid_command_exception.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
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

  /**
   * Perform user entered chat function
   * returns an application function to be called by UI
   */
  @override
  ApplicationFunction performChatFunction(SiteAreas currentArea, String userInput) {
    var parsedInput = userInput.split(' ');

    try {
      // Attempt to retrieve the first word (command)
      var cmd = ChatFunctions[currentArea]!.toList();
      String? cmdFunc;
      for (var i = 0; i < cmd.length; i++) {
        if (cmd[i] == parsedInput[0]) {
          cmdFunc = cmd[i];
          break;
        }
      }
      if (cmdFunc == null) throw InvalidCommandException();
      // Remove command from parseInput so we only have the parameters to pass
      parsedInput.removeAt(0);

      var response = _implementCommand(currentArea, cmdFunc.toString(), parsedInput);
      return response!;
    } catch (InvalidCommandException) {
      // Send response command was unsuccessful
      return ApplicationFunction(message: "Unable to parse command: " + userInput  +
          ". Enter 'help' to see a list of available options");
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
   * Converts String command to ApplicationFunction for implementation
   */
  ApplicationFunction? _implementCommand(SiteAreas currentArea, String command, List<String> parameters) {
    switch (command) {
      case "help":
        // Return list of available commands
        var commands = ChatFunctions[currentArea]?.toList().join(", ");
        return ApplicationFunction(message: "Available commands on this page: " + commands!);
        break;
      case "home":
        // Perform return home function
        return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/main"]);
        break;
      default:
        break;
    }
    // No response available
    return null;
  }
}