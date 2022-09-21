import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/services/chat_bot_service.dart';
import 'package:summer2022/utility/RouteGenerator.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatBot Service Verification Tests', () {
    test("Verify performChatFunction Help", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Home, "help");
      expect(result.getMethodName, "");
      expect(result.getParameters, null);
      expect(result.getMessage.contains("Available commands on this page:"), true);
    });
    test("Verify ChatBot to homepage", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Settings, "home");
      expect(result.getMethodName, "navigateTo");
      expect(result.getParameters, <String>["/main"]);
    });
  });
}