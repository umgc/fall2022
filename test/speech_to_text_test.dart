import 'package:flutter_test/flutter_test.dart';
import 'package:summer2022/speech_commands/speech_to_text.dart';
import 'dart:io' as io;

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  io.HttpOverrides.global = null;

  test("Process Date", () {
    String error = '';
    try {
      DateTime expectedDt = DateTime(2022, 6, 8);
      Speech speech = Speech();
      DateTime? dt = speech.processDate("June 8th 2022");
      expect(dt, expectedDt);
    } catch (e) {
        error = e.toString();
    }
    expect(error, '');
  });
}