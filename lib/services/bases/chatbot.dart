import '../../models/ApplicationFunction.dart';
import '../../utility/RouteGenerator.dart';

/**
 * Abstract implementation for Chatbot Service functions
 * to be publicly accessible
 */
abstract class Chatbot {
  /**
   * Perform user entered chat function
   */
  ApplicationFunction performChatFunction(SiteAreas currentArea, String userInput);
}