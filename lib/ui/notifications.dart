import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/models/Notification.dart' as Notification;
import 'package:summer2022/services/mail_notifier.dart';
import '../models/MailPiece.dart';
import '../services/mail_storage.dart';
import 'assistant_state.dart';
import 'bottom_app_bar.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/services/mailPiece_storage.dart';
import 'package:summer2022/ui/assistant_state.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/models/ApplicationFunction.dart';
import 'package:summer2022/models/NotificationSubscription.dart';
import 'package:summer2022/models/MailPieceViewArguments.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/locator.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:summer2022/firebase_options.dart';



class NotificationsWidget extends StatefulWidget {
  final ApplicationFunction? function;
  const NotificationsWidget({Key? key, this.function}) : super(key: key);
  @override
  NotificationsWidgetState createState() => NotificationsWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();
MailNotifier mn = new MailNotifier();
MailStorage mailStorage = new MailStorage();

final time =  DateTime.now().subtract(Duration(days: 30));
MailPiece clickedMailPiece = new MailPiece("", "", time, "", "", "");
class NotificationsWidgetState extends AssistantState<NotificationsWidget> {
  final sender_notifier = MailNotifier();
MailPieceStorage mailStorage = new MailPieceStorage();

final time =  DateTime.now().subtract(Duration(days: 30));
MailPiece clickedMailPiece = new MailPiece("", "", time, "", "", "","", null, null, null);
class NotificationsWidgetState extends AssistantState<NotificationsWidget> with SingleTickerProviderStateMixin {
  final _notifier = MailNotifier();
  final _keywordController = TextEditingController();

  var _subscriptions = <NotificationSubscription>[];
  var _notifications = <Notification.Notification>[];
  @override
  void initState() {
    super.initState();
    mn.updateNotifications(time);
    this.fetch();
    updateSubscriptionList();
    updateNotificationList();
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 2);
    locator<AnalyticsService>().logScreens(name: "Notifications");
    updateSubscriptionList();
    updateNotificationList();
    removeAllNotification();

    this.fetch();

    WidgetsBinding.instance.addPostFrameCallback((_) => checkPassedInFunction());

    setState(() {});

  }

  void checkPassedInFunction() {
    if (this.widget.function != null) {
      processFunction(widget.function!);
    }
  }

  Future<MailPiece> getMailPiece(String mailPieceId) async {
    clickedMailPiece = (await mailStorage.getMailPiece(mailPieceId))!;
    return clickedMailPiece;
  }

  void fetch() async{
    for (final notification in await mn.getNotifications()) {
      addNotification(notification.mailPieceId);
    mn.updateNotifications(time);
    // print("before");
    for (final notification in await mn.getNotifications()) {
      addNotification(notification.mailPieceId);
      //  print('after');
    }
  }

  @override
  void dispose() {
    _keywordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> processFunction(ApplicationFunction function) async {
    if (function.methodName == "addKeyword") {
      _tabController.animateTo(1);
      addSubscription(function.parameters![0]);
    }
    else {
      await super.processFunction(function);
    }
  }

  Future<void> updateSubscriptionList() async {
    final subscriptions = await sender_notifier.getSubscriptions();
    setState(() {
      _subscriptions = subscriptions;
    });
  }

  Future<void> updateNotificationList() async {
    final notifications = await sender_notifier.getNotifications();
    final notifications = await _notifier.getNotifications();
    setState(() {
      _notifications = notifications;
    });
  }

  void addSubscription(String keywords) async {
    for (final text in keywords.split(',')) {
    // .toLowerCase() eliminates duplicates subscriptions with capital letters
      final keyword = text.trim().toLowerCase();
      if (keyword.isEmpty) continue;
      final subscription = NotificationSubscription(keyword);
      await sender_notifier.createSubscription(subscription);
    }
    await updateSubscriptionList();
  }

  void addNotification(String keywords) async {
    for (final text in keywords.split(',')) {
      final keyword = text.trim();
      if (keyword.isEmpty) continue;
      //final notification = Notification.Notification(keyword,keyword);
    }
    await updateNotificationList();
  }

  void removeSubscription(String keyword) async {
    final subscription = NotificationSubscription(keyword);
    await sender_notifier.removeSubscription(subscription);
    await updateSubscriptionList();
  }

  void removeNotification(String mailPieceId, String keyword, int isCleared) async {
    final notification =  Notification.Notification(mailPieceId,keyword,isCleared);
    await sender_notifier.clearNotification(notification);
  void removeNotification(String mailPieceId, String keyword) async {
    final notification =  Notification.Notification(mailPieceId,keyword);
    await _notifier.clearNotification(notification);
    await updateNotificationList();
  }

  void removeAllNotification() async {
    await sender_notifier.clearAllNotifications();
    await _notifier.clearAllNotifications();
    await updateNotificationList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: const BottomBar(),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: new Image.asset("assets/icon/exit-icon.png",
                    width: 30, height: 30),
                onPressed: () {
                  Navigator.pushNamed(context, '/sign_in');
                }),
          ],
          leading: IconButton(
            icon: new Image.asset("assets/icon/back-icon.png",
                width: 30, height: 30),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            "Notifications",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(51, 51, 102, 1),
          bottom: const TabBar(tabs: <Widget>[
            Tab(
              text: "Notifications",
            ),
            Tab(
              text: "Manage",
            ),
          ]),
        ),
        body: TabBarView(
            children: <Widget>[
              Container( //Notifications
    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return new Scaffold(
        floatingActionButton: Visibility(
          visible: showHomeButton,
          child: FloatingHomeButton(parentWidgetName: context.widget.toString()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: const BottomBar(),
        appBar: TopBar(title: "Notifications", tabController: _tabController),
        body:
        TabBarView(
            controller: _tabController,
            children: <Widget>[
              Container( //Notifications
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Column(
                  children: [
                    // for (var item in _notifications)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                              child: Text('Date',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                  fontSize: 18),),
                              padding:
                              EdgeInsets.only(left: 0, top: 15, bottom: 5)),
                          Container(
                            child: Text('Keyword(s)',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                fontSize: 18),),
                            padding:
                            EdgeInsets.only(left: 0, top: 15, bottom: 5),
                          ),
                          SizedBox(

                          ),
                          SizedBox(

                          ),
                          SizedBox(

                          ),
                          Container(
                              child: SizedBox(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            explicitChildNodes: true,
                            child:
                            SizedBox(
                              child: Text('Date',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                    fontSize: 18), textAlign: TextAlign.center,),
                              width: MediaQuery.of(context).size.width/6,
                                ),
                          ),
                          Semantics(
                            explicitChildNodes: true,
                            child:
                            SizedBox(
                              child: Text('Keyword(s)',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                  fontSize: 18), textAlign: TextAlign.center),
                                width: MediaQuery.of(context).size.width/4,
                            ),
                          ),
                          Spacer(),
                          SizedBox(
                                child: ElevatedButton(
                                  child: Text('Clear All', style: TextStyle(color: Colors.white),),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),
                                    //shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)))
                                  ),
                                  onPressed: () {
                                    removeAllNotification();
                                  },
                                ),
                              ),
                              padding:
                              EdgeInsets.only(left: 0, top: 5, bottom: 5)
                          ),
                        ]),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                          ]),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(
                        height: 1,
                        indent: 10,
                        endIndent: 10,
                        thickness: 1,
                        color: Color.fromRGBO(51, 51, 102, 1),
                      ),
                    ),
                    Column(
                      children: [
                        for(var item in _notifications)
                          Row(
                            children: [
                              SizedBox(
                                child: Text(item.mailPieceId.split("-")[1]+"-"+item.mailPieceId.split("-")[2]+"-"
                                    +item.mailPieceId.split("-")[3].split(" ")[0]),
                                width: 100,
                              ),
                              SizedBox(
                                child: Text(item.subscriptionKeyword),
                                width: 100,
                              ),
                              SizedBox(
                                child: ElevatedButton(
                                  child: Text('Go to Message', style: TextStyle(color: Colors.white),),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.black45),
                                    //shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)))
                                  ),
                                  onPressed: () async {
                                    Navigator.pushNamed(context, '/mail_piece_view', arguments: await getMailPiece(item.mailPieceId));
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                child: ElevatedButton(
                                  child: Text('Clear', style: TextStyle(color: Colors.white),),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),
                                    //shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)))
                                  ),
                                  onPressed: () {
                                    removeNotification(item.mailPieceId,item.subscriptionKeyword, 0);
                                  },
                                ),
                              )
                            ],
                          ),
                      ],
                    )
                  ],
                ),
              ),
              Container(  //Manager1
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: SizedBox(
                              child: TextField(
                                controller: _keywordController,
                                onSubmitted: (keywords) {
                                  addSubscription(keywords);
                                  _keywordController.clear();
                                },
                                decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white54,
                                    border: OutlineInputBorder(),
                                    //contentPadding: EdgeInsets.all(8),
                                    labelText: 'Keyword(s)',
                                    labelStyle: TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                        fontSize: 18),
                                    isDense: true),
                              ),
                              width: 300,
                            ),
                            padding: EdgeInsets.only(left: 5),
                          ),
                          Container(
                            child: OutlinedButton(
                              child: Text(
                                'Add',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateColor.resolveWith(
                                          (states) => Colors.green),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30)))),
                              onPressed: () {
                                addSubscription(_keywordController.text);
                                _keywordController.clear();
                              },
                            ),
                            padding: EdgeInsets.only(left: 5),
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Divider(
                        height: 1,
                        indent: 10,
                        endIndent: 10,
                        thickness: 1,
                        color: Color.fromRGBO(51, 51, 102, 1),
                      ),
                    ),
                    Container(
                      height: 400,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (var item in _subscriptions)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    child: Text(item.keyword, style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                        fontSize: 18),) ,
                                    width: 270,
                    Expanded(
                      child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: 35),
                          child: Column(
                          children: [
                            for(var item in _notifications)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    child: Text(item.mailPieceId.split("-")[2]+"-"
                                        +item.mailPieceId.split("-")[3].split(" ")[0] + "\n" +item.mailPieceId.split("-")[1],
                                        textAlign: TextAlign.center
                                    ),
                                    width: MediaQuery.of(context).size.width/6,
                                  ),
                                  SizedBox(
                                    child: Text(item.subscriptionKeyword, textAlign: TextAlign.center),
                                    width: MediaQuery.of(context).size.width/4,
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                      child: Text('Go to Message',
                                        semanticsLabel: "Go to " + item.subscriptionKeyword + " Message",
                                        style: TextStyle(color: Colors.white),),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateColor.resolveWith((states) => Colors.black45),
                                        //shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)))
                                      ),
                                      onPressed: () async {
                                        Navigator.pushNamed(context, '/mail_piece_view', arguments: new MailPieceViewArguments(await getMailPiece(item.mailPieceId)));
                                      },
                                  ),
                                  Spacer(),
                                  ElevatedButton(
                                      child: Text('Clear',
                                        semanticsLabel: "Clear " + item.subscriptionKeyword,
                                        style: TextStyle(color: Colors.white),),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),
                                        //shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)))
                                      ),
                                      onPressed: () {
                                        removeNotification(item.mailPieceId,item.subscriptionKeyword);
                                      },
                                  )
                                ],
                              ),
                          ],
                          )
                      ),
                    ),
                  ],
                ),
              ),
              Container(
               //Manager1
                padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            explicitChildNodes: true,
                            child:
                          Container(
                            width: MediaQuery.of(context).size.width/1.5,
                            alignment: Alignment.center,
                            child:
                                Semantics(
                                  excludeSemantics: true,
                                  label: "Keyword",
                                  textField: true,
                                  hint: "Enter notification keyword to add",
                                  child:
                                  TextField(
                                      controller: _keywordController,
                                      onSubmitted: (keywords) {
                                        addSubscription(keywords);
                                        _keywordController.clear();
                                      },
                                      decoration: const InputDecoration(
                                          filled: true,
                                          fillColor: Colors.white54,
                                          border: OutlineInputBorder(),
                                          //contentPadding: EdgeInsets.all(8),
                                          labelText: 'Keyword(s)',
                                          labelStyle: TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                              fontSize: 18),
                                          isDense: true),
                                    ),),
                          ),),
                          Container(
                            child: OutlinedButton(
                              child: Text(
                                'Add',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateColor.resolveWith(
                                          (states) => Colors.green),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30)))),
                              onPressed: () {
                                addSubscription(_keywordController.text);
                                FirebaseAnalytics.instance.logEvent(name: 'Notification_Subscription',parameters:{'Add_Keyword':_keywordController.text});
                                _keywordController.clear();
                              },
                            ),
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Divider(
                        height: 1,
                        indent: 10,
                        endIndent: 10,
                        thickness: 1,
                        color: Color.fromRGBO(51, 51, 102, 1),
                      ),
                    ),
                    Expanded(child:
                    SingleChildScrollView(
                      padding: EdgeInsets.only(bottom: 35),
                      child: Column(
                        children: [
                          for (var item in _subscriptions)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(item.keyword, style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                      fontSize: 18),),
                                  ),
                                  SizedBox(
                                    child: OutlinedButton(
                                      child: Text(
                                        'Delete',
                                        semanticsLabel: "Delete " + item.keyword,
                                        style: TextStyle(color: Colors.white,fontSize: 18),
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                          MaterialStateColor.resolveWith(
                                                  (states) => Colors.red),
                                          shape: MaterialStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(30)))),
                                      onPressed: () {
                                        removeSubscription(item.keyword);
                                        FirebaseAnalytics.instance.logEvent(name: 'Notification_Subscription',parameters:{'Delete_Keyword':item.keyword});
                                      },
                                    ),
                                  )
                                ],
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // This is the end of manager tab one
            ]
        ),
      ),
    );
   );
  }
}
