import 'dart:collection';
import 'package:summer2022/exceptions/invalid_command_exception.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/services/bases/chat_bot.dart';
import 'package:summer2022/utility/RouteGenerator.dart';

class ChatBotService implements ChatBot {
  // This list of functions should be available on all pages
  static const availableOnAllPages = <String>[
    "logout", "help"
  ];
  static const Map<SiteAreas, List<String>> ChatFunctions = {
    SiteAreas.Home: <String>["search", "settings", ...availableOnAllPages],
    SiteAreas.Settings: <String>["home", ...availableOnAllPages],
    SiteAreas.SearchResults: <String>["home", "settings", ...availableOnAllPages],
    SiteAreas.Search: <String>["home", "settings", ...availableOnAllPages],
    SiteAreas.MailView: <String>["home", "settings", ...availableOnAllPages],
    SiteAreas.NotificationView: <String>["home", "settings", ...availableOnAllPages],
    SiteAreas.NotificationManage: <String>["home", "settings", ...availableOnAllPages],
  };

  // Default constructor
  ChatBotService() {  }

  // Perform user entered chat function
  // returns an application function to be called by UI
  @override
  ApplicationFunction performChatFunction(SiteAreas currentArea, String userInput) {
    // Return if currentArea doesn't have any mapped functions
    if (!ChatFunctions.containsKey(currentArea))
      return ApplicationFunction(message: "There are no available commands on this page.");

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

      return _implementCommand(currentArea, commandFunction.toString(), parsedInput);
    } catch (InvalidCommandException) {
      // Send response command was unsuccessful
      return ApplicationFunction(message: "Unable to parse command: " + userInput  +
          ". Enter 'help' to see a list of available options");
    }
  }

  // Converts String command to ApplicationFunction for implementation
  ApplicationFunction _implementCommand(SiteAreas currentArea, String command, List<String> parameters) {
    switch (command) {
      case "help":
        // Return list of available commands
        var commands = ChatFunctions[currentArea]?.toList().join(", ");
        return ApplicationFunction(message: "Available commands on this page: " + commands!);
      case "home":
        // Perform return home function
        return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/main"]);
      case "search":
        if (parameters.isNotEmpty) {
          // Perform search using parameters
          return ApplicationFunction(methodName: "performSearch", parameters: parameters);
        } else {
          // Perform navigate to search function
          return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/search"]);
        }
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
    return ApplicationFunction(message: "Sorry. I couldn't interpret your command.");
  }
}