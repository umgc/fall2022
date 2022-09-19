import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/services/chat_bot_service.dart';
import 'package:summer2022/utility/RouteGenerator.dart';
import 'package:uuid/uuid.dart';

class ChatWidget extends StatefulWidget {
  final SiteAreas currentPage;
  const ChatWidget({super.key, required this.currentPage});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  ChatBotService _chatBotService = ChatBotService();
  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  final _system = const types.User(id: 'system', /* imageUrl: TODO: Add chatBot image */);

  FontWeight commonFontWt = FontWeight.w700;
  double commonFontSize = 30;
  double commonBorderWidth = 2;
  double commonButtonHeight = 60;
  double commonButtonWidth = 200;
  double commonCornerRadius = 8;

  @override
  void initState() {
    super.initState();
    _addSystemMessage("How may I assist you?");
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/main');
          },
          child: Icon(
              Icons.arrow_back
          )
      ),
      centerTitle: true,
      title: Text(
        "Chat Support",
        style:
        TextStyle(fontWeight: commonFontWt, fontSize: commonFontSize),
      ),
      actions: <Widget>[
        Padding(
            padding: EdgeInsets.only(right:20.0),
            child: GestureDetector(
                onTap: () {},
                child: Icon(
                    Icons.settings
                )
            )
        ),
        Padding(
            padding: EdgeInsets.only(right:20.0),
            child: GestureDetector(
                onTap: () {},
                child: Icon(
                    Icons.logout
                )
            )
        )
      ],
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xff004B87),
    ),
    body: Chat(
      messages: _messages,
      onMessageTap: _handleMessageTap,
      onSendPressed: _handleSendPressed,
      showUserAvatars: true,
      showUserNames: true,
      user: _user,
    ),
  );

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  /*
    May be able to use this for simple clicking of suggested option commands
   */
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