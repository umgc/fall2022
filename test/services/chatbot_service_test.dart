import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/services/chatbot_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("Verify ChatFunctions are populated", () {
    var service = ChatbotService();
    var result = service.ChatFunctions.entries.length > 0;
    expect(result, true);
  });
}