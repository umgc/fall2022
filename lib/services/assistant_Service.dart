import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:receive_intent/receive_intent.dart';
import 'dart:developer';

class AssistantService
{
  static ApplicationFunction? ParseIntent(Intent intent)
  {
      log(intent.action ?? "");
      // Try to get our action from the intent
      if (intent.action == "actions.intent.GET_THING")
      {
          String query = intent.extra!["name"];
          if (query == "Digest")
          {
            return ApplicationFunction(methodName: "digest");
          }
          else if (query.isNotEmpty)
          {
            return ApplicationFunction(methodName: "performSearch", parameters: <String>[query]);
          }
      }
      else if (intent.action == "actions.intent.CREATE_THING")
      {
          String query = intent.extra!["name"];
          if (query.isNotEmpty)
          {
            return ApplicationFunction(methodName: "addKeyword", parameters: <String>[query]);
          }
      }
      else if (intent.action == "actions.intent.OPEN_APP_FEATURE") {
          String query = intent.extra!["name"];
          if (query.isNotEmpty)
          {
            return ApplicationFunction(methodName: "navigateTo", parameters: <String>['/notifications']);
          }
      }

      return null;
  }
}