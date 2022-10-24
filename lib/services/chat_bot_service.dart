import 'package:summer2022/exceptions/invalid_command_exception.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/services/bases/chat_bot.dart';
import 'package:summer2022/utility/RouteGenerator.dart';

class ChatBotService implements ChatBot {
  // This list of functions should be available on all pages
  static const availableOnAllPages = <String>[
    "digest", "help", "home", "logout", "notifications", "scan", "search", "settings", "upload"
  ];
  static const Map<SiteAreas, List<String>> ChatFunctions = {
    SiteAreas.Home: <String>[...availableOnAllPages],
    SiteAreas.Settings: <String>[...availableOnAllPages],
    SiteAreas.SearchResults: <String>[...availableOnAllPages],
    SiteAreas.Search: <String>[...availableOnAllPages],
    SiteAreas.MailView: <String>[...availableOnAllPages],
    SiteAreas.NotificationView: <String>[...availableOnAllPages],
    SiteAreas.NotificationManage: <String>[...availableOnAllPages],
  };

  // Default constructor
  ChatBotService() {  }

  // Perform user entered chat function
  // returns an application function to be called by UI
  @override
  ApplicationFunction performChatFunction(SiteAreas currentArea, String userInput) {
    // Return if currentArea doesn't have any mapped functions
    if (!ChatFunctions.containsKey(currentArea))
      return ApplicationFunction(messages: <String>["There are no available commands on this page."]);

    var parsedInput = userInput.split(' ');

    try {
      // Attempt to retrieve the first word (command)
      var command = ChatFunctions[currentArea]!.toList();
      String? commandFunction;
      String? commandInput = "";
      var i = 0;
      for (i = 0; i < parsedInput.length; i++) {
        if (commandFunction != null) break;
        commandInput = "${commandInput} ${parsedInput[i]}".trim();
        commandFunction = command.firstWhere((element) => element == commandInput) ?? null;
      }
      if (commandFunction == null) throw InvalidCommandException();
      // Remove command from parseInput so we only have the parameters to pass
      parsedInput.removeRange(0, i);

      return _implementCommand(currentArea, commandFunction.toString(), parsedInput);
    } catch (InvalidCommandException) {
      // Send response command was unsuccessful
      return ApplicationFunction(messages: <String>["Unable to parse command: " + userInput  +
          ". Enter 'help' to see a list of available options"]);
    }
  }

  // Converts String command to ApplicationFunction for implementation
  ApplicationFunction _implementCommand(SiteAreas currentArea, String command, List<String> parameters) {
    List<String> usage = <String>[];
    ApplicationFunction result;

    switch (command) {
      case "digest":
        // Perform navigate to digest function
        // TODO: May need to be action that gets digest and navigates
        //result = ApplicationFunction(messages: <String>["Digest is currently unsupported from the chatbot."]);
        result = ApplicationFunction(methodName: 'digest');
        usage.add("'digest': Navigates to Daily Digest Page");
        break;
      case "help":
        // Return list of available commands
        var commands = ChatFunctions[currentArea]?.toList().join(", ");
        result =  ApplicationFunction(messages: <String>["Available commands on this page: ${commands!}.", "Note: If you need help with "
            "a specific command, enter '<command> help' to view any extra command options."]);
        usage.add("'help': Displays list of commands available");
        break;
      case "home":
        // Perform return home function
        result =  ApplicationFunction(methodName: "navigateTo", parameters: <String>["/main"]);
        usage.add("'home': Navigates to Main Menu");
        break;
      case "logout":
      // Take user to sign in page
        result =  ApplicationFunction(methodName: "navigateTo", parameters: <String>["/sign_in"]);
        usage.add("'logout': Logs user out and navigates to the sign in page");
        break;
      case "notifications":
        if (parameters.isNotEmpty) {
            if (parameters[0] == "add") {
              // Add notification by keyword
              parameters.removeAt(0);
              result =  ApplicationFunction(
                  methodName: "addNotification", parameters: parameters);
            } else if (parameters[0] == "delete") {
              // Delete notification by keyword
              parameters.removeAt(0);
              result =  ApplicationFunction(methodName: "deleteNotification", parameters: parameters);
            } else {
              result =  ApplicationFunction(messages: <String>["Sorry. I couldn't interpret your command."]);
            }
        } else {
          // Perform navigate to base notifications page
          result =  ApplicationFunction(methodName: "navigateTo", parameters: <String>["/notifications"]);
        }
        usage.add("'notifications': Navigates to Notifications");
        usage.add("'add <keyword>': Adds a notification for the suggested keyword.");
        usage.add("'delete <keyword>': Deletes notification for the suggested keyword");
        break;
      case "scan":
        // Perform navigate to scan mail function
        result =  ApplicationFunction(methodName: "scanMail", parameters: parameters);
        usage.add("'scan': Opens camera application to scan and upload mail item");
        break;
      case "search":
        if (parameters.isNotEmpty) {
          // Perform search using parameters
          result =  ApplicationFunction(methodName: "performSearch", parameters: parameters);
        } else {
          // Perform navigate to search function
          result =  ApplicationFunction(methodName: "navigateTo", parameters: <String>["/search"]);
        }
        usage.add("'search': Navigates to the search page");
        usage.add("'search <date> <date> <keyword>': Loads advanced search page using entered dates/keywords (optional). Note: First date "
            "is always treated as the start date. Date format is mm/dd/yyyy");
        break;
      case "settings":
        // Perform navigate to settings function
        result =  ApplicationFunction(methodName: "navigateTo", parameters: <String>["/settings"]);
        usage.add("'settings': Navigates to the settings page");
        break;
      case "upload":
        // Perform navigate to upload mail function
        result =  ApplicationFunction(methodName: "uploadMail", parameters: parameters);
        usage.add("'upload': Opens gallery to find and upload mail item");
        break;
      default:
        // No response available
        result = ApplicationFunction(messages: <String>["Sorry. I couldn't interpret your command."]);
        usage.add("Sorry. I couldn't interpret your command.");
        break;
    }

    // If help is being requested with a command, return the detailed usage
    if (parameters.isNotEmpty && parameters.first == "help")
      result = ApplicationFunction(messages: usage);

    return result;
  }
}