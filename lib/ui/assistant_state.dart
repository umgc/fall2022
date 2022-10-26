import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/email_processing/digest_email_parser.dart';
import 'package:summer2022/models/Arguments.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/services/assistantService.dart';

abstract class AssistantState<T extends StatefulWidget> extends State<T>
{
  late StreamSubscription intentSubscription;

  @override
  void initState()
  {
    super.initState();
    initIntentListener();
  }

  void clearIntentListener()
  {
    intentSubscription.pause();
  }

  Future<void> initIntentListener() async
  {
    intentSubscription = receiveIntent.ReceiveIntent.receivedIntentStream.listen((receiveIntent.Intent? intent) async
    {
        if (intent != null) {
          if (ModalRoute.of(context)?.isCurrent ?? false) {
            ApplicationFunction? appFunction = AssistantService.ParseIntent(
                intent);
            if (appFunction != null) {
              await processFunction(appFunction);
            }
          }
        }
    });
  }

  Future<void> processFunction(ApplicationFunction function) async
  {
    switch (function.methodName) {
      case 'navigateTo':
        Navigator.pushNamed(context, function.parameters![0]);
        break;
      case 'digest':
        var digestEmailParser = new DigestEmailParser();
        var digest = await digestEmailParser.createDigest(await Keychain().getUsername(), await Keychain().getPassword());
        if (!digest.isNull()) {
          Navigator.pushNamed(context, '/digest_mail',
              arguments: MailWidgetArguments(digest));
        }
        break;
      case 'performSearch':
        Navigator.pushNamed(context, '/search', arguments: function.parameters);
        break;
      case 'addKeyword':
        Navigator.pushNamed(context, '/notifications', arguments: function);
        break;
    }
  }

  @override
  void dispose()
  {
    clearIntentListener();
    super.dispose();
  }
}