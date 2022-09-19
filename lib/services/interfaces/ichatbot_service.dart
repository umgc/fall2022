import 'package:summer2022/utility/RouteGenerator.dart';

/**
 * Interface for Chatbot Service functions
 * to be publicly accessible
 */
abstract class IChatbotService {
  /**
   * Perform user entered chat function
   */
  void performChatFunction(SiteAreas currentArea, String userInput);
}