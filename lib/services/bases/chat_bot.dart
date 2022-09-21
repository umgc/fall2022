import '../../models/ApplicationFunction.dart';
import '../../utility/RouteGenerator.dart';

// Abstract implementation for ChatBot Service functions
// to be publicly accessible
abstract class ChatBot {

  // Perform user entered chat function
  ApplicationFunction performChatFunction(SiteAreas currentArea, String userInput);
}