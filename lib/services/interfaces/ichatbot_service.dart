import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/utility/RouteGenerator.dart';

/**
 * Interface for Chatbot Service functions
 * to be publicly accessible
 */
abstract class IChatbotService {
  /**
   * Perform user entered chat function
   */
  ApplicationFunction performChatFunction(SiteAreas currentArea, String userInput);
}