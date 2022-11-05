import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/services/chat_bot_service.dart';
import 'package:summer2022/utility/RouteGenerator.dart';
import 'package:summer2022/models/SearchCriteria.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatBot Service Verification Tests', () {
    test("Verify performChatFunction Help", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Home, "help");
      expect(result.methodName, "");
      expect(result.parameters, null);
      expect(result.messages?.elementAt(0).contains("Available commands on this page:"), true);
    });
    test("Verify ChatBot to homepage", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Settings, "home");
      expect(result.methodName, "navigateTo");
      expect(result.parameters, <String>["/main"]);
    });
    test("Verify Search with Parameters multiple keywords", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Search, "search 10/2/2022 keyword 10/7/2022 test");
      var searchCriteria = SearchCriteria.withList(result.parameters!);
      expect(searchCriteria.keyword, "keyword test");
    });
    test("Verify Search with Parameters Start and End Dates", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Search, "search 10/2/2022 10/7/2022");
      var searchCriteria = SearchCriteria.withList(result.parameters!);
      expect(searchCriteria.startDate, DateTime(2022, 10, 2));
      expect(searchCriteria.endDate, DateTime(2022, 10, 7));
    });
    test("Verify Search with Parameters Start Exceeds End Dates", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Search, "search 10/20/2022 10/7/2022");
      var searchCriteria = SearchCriteria.withList(result.parameters!);
      expect(searchCriteria.startDate, DateTime(2022, 10, 20));
      expect(searchCriteria.endDate, DateTime(2022, 10, 20));
    });
    test("Verify Create Notification", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Home, "notifications add test");
      expect(result.methodName, "addNotification");
      expect(result.parameters?[0], "test");
    });
    test("Verify Delete Notification", () {
      var service = ChatBotService();
      var result = service.performChatFunction(SiteAreas.Home, "notifications delete test");
      expect(result.methodName, "deleteNotification");
      expect(result.parameters?[0], "test");
    });
  });
}