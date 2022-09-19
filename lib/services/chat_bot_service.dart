import 'dart:collection';
import 'package:summer2022/exceptions/invalid_command_exception.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/services/bases/chat_bot.dart';
import 'package:summer2022/utility/RouteGenerator.dart';

class ChatBotService implements ChatBot {
  Map<SiteAreas, List<String>> ChatFunctions = HashMap();

  /**
   * Default constructor
   */
  ChatBotService() {
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
      var command = ChatFunctions[currentArea]!.toList();
      String? commandFunction;
      for (var i = 0; i < command.length; i++) {
        if (command[i] == parsedInput[0]) {
          commandFunction = command[i];
          break;
        }
      }
      if (commandFunction == null) throw InvalidCommandException();
      // Remove command from parseInput so we only have the parameters to pass
      parsedInput.removeAt(0);

      var response = _implementCommand(currentArea, commandFunction.toString(), parsedInput);
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
      "search", "settings",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.MailView] = <String>[
      "home", "settings",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.NotificationManage] = <String>[
      "home", "settings",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.NotificationView] = <String>[
      "home", "settings",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.Search] = <String>[
      "home", "settings",
      ...availableOnAllPages
    ];
    ChatFunctions[SiteAreas.SearchResults] = <String>[
      "home", "settings",
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
      case "home":
        // Perform return home function
        return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/main"]);
      case "search":
        // Perform navigate to search function
        return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/search"]);
      case "settings":
        // Perform navigate to settings function
        return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/settings"]);
      case "logout":
        // Take user to sign in page
        return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/sign_in"]);
      default:
        break;
    }
    // No response available
    return null;
  }
}