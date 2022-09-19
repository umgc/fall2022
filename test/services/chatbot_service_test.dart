import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:summer2022/main.dart';
import 'package:summer2022/services/chatbot_service.dart';
import 'package:summer2022/utility/RouteGenerator.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Chatbot Service Verification Tests', () {
    test("Verify ChatFunctions are populated", () {
      var service = ChatbotService();
      var result = service.ChatFunctions.entries.length > 0;
      expect(result, true);
    });
    test("Verify performChatFunction Help", () {
      var service = ChatbotService();
      var result = service.performChatFunction(SiteAreas.Home, "help");
      expect(result.getMethodName, "");
      expect(result.getParameters, null);
      expect(result.getMessage.contains("Available commands on this page:"), true);
    });
    test("Verify chatbot to homepage", () {
      var service = ChatbotService();
      var result = service.performChatFunction(SiteAreas.Settings, "home");
      expect(result.getMethodName, "navigateTo");
      expect(result.getParameters, <String>["/main"]);
    });
  });
}