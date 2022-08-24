import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/speech_commands/read_info.dart';
import 'package:summer2022/main.dart';


class FakeFlutterTts extends Fake implements FlutterTts {
  @override
  Future<dynamic> awaitSpeakCompletion(bool? awaitCompletion) {
    return Future.value(true);
  }

  @override
  Future<dynamic> speak(String? text) {
    print(text);
    return Future.value(1);
  }

  @override
  Future<dynamic> stop() {
    return Future.value(true);
  }

  @override
  Future<dynamic> setLanguage(String? language) {
    return Future.value(true);
  }

  @override
  Future<dynamic> setSpeechRate(double? rate) {
    return Future.value(true);
  }

  @override
  Future<dynamic> setVolume(double? volume) {
    return Future.value(true);
  }

  @override
  Future<dynamic> setPitch(double? pitch) {
    return Future.value(true);
  }
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() async {
    GlobalConfiguration cfg = GlobalConfiguration();
    await cfg.loadFromAsset("app_settings");
    tts = FakeFlutterTts();
  });

  test("Command Tutorial", () {
    String error = '';
    try {
      CommandTutorial commandTutorial = CommandTutorial();
      commandTutorial.runTutorial();
    } catch (e) {
      error = e.toString();
    }
    expect(error, '');
  });

  group("Help Commands", () {
    test("Main Help", () {
      String error = '';
      try {
        CommandTutorial commandTutorial = CommandTutorial();
        commandTutorial.getMainHelp();
      } catch (e) {
        error = e.toString();
      }
      expect(error, '');
    });

    test("Digest Help", () {
      String error = '';
      try {
        CommandTutorial commandTutorial = CommandTutorial();
        commandTutorial.getDigestHelp();
      } catch (e) {
        error = e.toString();
      }
      expect(error, '');
    });

    test("Email Help", () {
      String error = '';
      try {
        CommandTutorial commandTutorial = CommandTutorial();
        commandTutorial.getEmailHelp();
      } catch (e) {
        error = e.toString();
      }
      expect(error, '');
    });

    test("Settings Help", () {
      String error = '';
      try {
        CommandTutorial commandTutorial = CommandTutorial();
        commandTutorial.getSettingsHelp();
      } catch (e) {
        error = e.toString();
      }
      expect(error, '');
    });
  });
}