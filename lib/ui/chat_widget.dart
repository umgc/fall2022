import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/services/chat_bot_service.dart';
import 'package:summer2022/utility/RouteGenerator.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:uuid/uuid.dart';

import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/locator.dart';

class ChatWidget extends StatefulWidget {
  final SiteAreas currentPage;
  const ChatWidget({super.key, required this.currentPage});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ChatBotService _chatBotService = ChatBotService();
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _system = const types.User(id: 'system', /* imageUrl: TODO: Add chatBot image */);
  final FontWeight _commonFontWt = FontWeight.w700;
  final double _commonFontSize = 30;
  List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();
    locator<AnalyticsService>().logScreens(name: "Chatbot");
    //FirebaseAnalytics.instance.setCurrentScreen(screenName: "Settings");
    /*FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'screenName': 'Chatbot',
        'screenClass': 'chat_widget.dart',
      },
    );*/
    _addSystemMessage("How may I assist you?");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: TopBar(title: 'Chat Support'),
    body: Chat(
      messages: _messages,
      onMessageTap: _handleMessageTap,
      onSendPressed: _handleSendPressed,
      showUserAvatars: true,
      showUserNames: true,
      user: _user,
    ),
    bottomNavigationBar: const BottomBar()
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  // May be able to use this for simple clicking of suggested option commands
  void _handleMessageTap(BuildContext _, types.Message message) async {
    // TODO: Remove or implement this if needed
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(textMessage);

    // Get functionality from bot
    ApplicationFunction chatFunction = _chatBotService.performChatFunction(widget.currentPage, message.text.toLowerCase());
    if (chatFunction.message.isNotEmpty) _addSystemMessage(chatFunction.message);

    // TODO: Perform functions
    switch (chatFunction.methodName) {
      case 'navigateTo':
        Navigator.pushNamed(context, chatFunction.parameters![0]);
        break;
      case 'performSearch':
        Navigator.pushNamed(context, '/search', arguments: chatFunction.parameters);
        break;
    }
  }

  void _addSystemMessage(String input) {
    var message = types.TextMessage(
      author: _system,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: input,
    );
    _addMessage(message);
  }
}