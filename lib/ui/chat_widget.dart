import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/models/NotificationSubscription.dart';
import 'package:summer2022/models/SearchCriteria.dart';
import 'package:summer2022/services/chat_bot_service.dart';
import 'package:summer2022/services/mail_notifier.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/utility/RouteGenerator.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:uuid/uuid.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/locator.dart';
import 'package:summer2022/services/mail_loader.dart';

import '../email_processing/digest_email_parser.dart';
import '../email_processing/other_mail_parser.dart';
import '../models/Arguments.dart';
import '../models/Digest.dart';
import '../models/MailSearchParameters.dart';
import '../utility/Keychain.dart';

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
  final mailLoader = MailLoader();
  final selectedDate = DateTime.now();
  List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();
    locator<AnalyticsService>().logScreens(name: "Chatbot");
    _addSystemMessage("How may I assist you?");
  }

  @override
  Widget build(BuildContext context) {
    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
        appBar: TopBar(title: 'Chat Support'),
        floatingActionButton: Visibility(
          visible: showHomeButton,
          child: FloatingHomeButton(
              parentWidgetName: context.widget.toString()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
  }

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
    chatFunction.messages?.forEach((element) {
      _addSystemMessage(element);
    });

    // Perform functions
    switch (chatFunction.methodName) {
      case 'addNotification':
        var subscription = new NotificationSubscription(chatFunction.parameters!.join(','));
        final _notifier = MailNotifier();
        _notifier.createSubscription(subscription);
        _addSystemMessage("Notification for ${subscription.keyword} has been added.");
        break;
      case 'deleteNotification':
        var subscription = new NotificationSubscription(chatFunction.parameters!.join(','));
        final _notifier = MailNotifier();
        _notifier.removeSubscription(subscription);
        _addSystemMessage("Notification for ${subscription.keyword} has been deleted.");
        break;
      case 'digest':
        _addSystemMessage("Fetching daily digest...");
        _getDailyDigest(context);
        break;
      case 'navigateTo':
        Navigator.pushNamed(context, chatFunction.parameters![0]);
        break;
      case 'performSearch':
        final filters = SearchCriteria.withList(chatFunction.parameters!);

        // Navigate to search results
        var searchParams = new MailSearchParameters(
            keyword: filters.keyword,
            startDate: filters.startDate,
            endDate: filters.endDate);
        Navigator.pushNamed(context, '/mail_view',
            arguments: searchParams);

        FirebaseAnalytics.instance.logEvent(name: 'Mail_Search',parameters:{'senderKeyword':searchParams.keyword});
        break;
      case 'scanMail':
        mailLoader.uploadMail(ImageSource.camera);
        break;
      case 'uploadMail':
        mailLoader.uploadMail(ImageSource.gallery);
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

  void _getDailyDigest(BuildContext context) async {
    await getDigest();
    if (!digest.isNull()) {
      Navigator.pushNamed(context, '/digest_mail',
          arguments: MailWidgetArguments(digest));
      _addSystemMessage("Digest successfully retrieved.");
    } else {
      _addSystemMessage("No items could be found.");
    }
  }

  late Digest digest;
  late List<Digest> emails;

  Future<void> getDigest() async {
    try {
      await DigestEmailParser()
          .createDigest(await Keychain().getUsername(),
          await Keychain().getPassword())
          .then((value) => digest = value);
    } catch (e) {
      _addSystemMessage("Error retrieving Daily Digest.");
    }
  }

  Future<void> getEmails(bool isUnread, [DateTime? pickedDate]) async {
    try {
      await OtherMailParser()
          .createEmailList(isUnread, await Keychain().getUsername(),
          await Keychain().getPassword(), pickedDate ?? selectedDate)
          .then((value) => emails = value);
    } catch (e) {
      _addSystemMessage("Error retrieving Daily Digest.");
    }
  }
}