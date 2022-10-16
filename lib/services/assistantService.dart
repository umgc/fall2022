import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:receive_intent/receive_intent.dart';

class AssistantService
{
  static ApplicationFunction? ParseIntent(Intent intent)
  {
      // Try to get our action from the intent
      if (intent.action == "actions.intent.action.GET_THING")
      {
          String query = intent.extra!["name"];

          if (query == "Digest")
          {
            return ApplicationFunction(methodName: "navigateTo", parameters: <String>["/digest_mail"]);
          }
          else if (query.isNotEmpty)
          {
            return ApplicationFunction(methodName: "performSearch", parameters: <String>[query]);
          }
      }
      else if (intent.action == "actions.intent.action.CREATE_THING")
      {
          String query = intent.extra!["name"];
          if (query.isNotEmpty)
          {
            return ApplicationFunction(methodName: "addKeyword", parameters: <String>[query]);
          }
      }

      return null;
  }
}