import 'dart:async';
import 'package:flutter/material.dart';
import 'package:receive_intent/receive_intent.dart' as receiveIntent;
import '../models/ApplicationFunction.dart';
import '../services/assistantService.dart';

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
    intentSubscription = receiveIntent.ReceiveIntent.receivedIntentStream.listen((receiveIntent.Intent? intent)
    {
        if (intent != null) {
          ApplicationFunction? appFunction = AssistantService.ParseIntent(intent);
          if (appFunction != null) {
            processFunction(appFunction);
          }
        }
    });
  }

  void processFunction(ApplicationFunction function)
  {
    switch (function.methodName) {
      case 'navigateTo':
        Navigator.pushNamed(context, function.parameters![0]);
        break;
      case 'performSearch':
        Navigator.pushNamed(context, '/search', arguments: function.parameters);
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