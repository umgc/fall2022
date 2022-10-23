import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/models/Notification.dart' as Notification;
import 'package:summer2022/services/mail_notifier.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/services/mail_storage.dart';
import 'package:summer2022/ui/assistant_state.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/models/NotificationSubscription.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({Key? key}) : super(key: key);
  @override
  NotificationsWidgetState createState() => NotificationsWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();
MailNotifier mn = new MailNotifier();
MailStorage mailStorage = new MailStorage();

final time =  DateTime.now().subtract(Duration(days: 30));
MailPiece clickedMailPiece = new MailPiece("", "", time, "", "", "");
class NotificationsWidgetState extends AssistantState<NotificationsWidget> {
  final _notifier = MailNotifier();
  final _keywordController = TextEditingController();

  var _subscriptions = <NotificationSubscription>[];
  var _notifications = <Notification.Notification>[];
  @override
  void initState() {
    super.initState();
    updateSubscriptionList();
    updateNotificationList();
    removeAllNotification();

    this.fetch();

    setState(() {});

  }

  Future<MailPiece> getMailPiece(String mailPieceId) async {
    clickedMailPiece = (await mailStorage.getMailPiece(mailPieceId))!;
    return clickedMailPiece;
  }

  void fetch() async{
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
    super.dispose();
  }

  Future<void> updateSubscriptionList() async {
    final subscriptions = await _notifier.getSubscriptions();
    setState(() {
      _subscriptions = subscriptions;
    });
  }

  Future<void> updateNotificationList() async {
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
      await _notifier.createSubscription(subscription);
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
    await _notifier.removeSubscription(subscription);
    await updateSubscriptionList();
  }

  void removeNotification(String mailPieceId, String keyword) async {
    final notification =  Notification.Notification(mailPieceId,keyword);
    await _notifier.clearNotification(notification);
    await updateNotificationList();
  }

  void removeAllNotification() async {
    await _notifier.clearAllNotifications();
    await updateNotificationList();
  }

  @override
  Widget build(BuildContext context) {
    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: showHomeButton,
          child: FloatingHomeButton(parentWidgetName: context.widget.toString()),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: const BottomBar(),
        appBar:
          TopBar(title: "Notifications"),
        body: TabBarView(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height/9,//Notifications
                padding: EdgeInsets.fromLTRB(15, 15, 15, 35),
                child: Column(
                  children: [
                    // for (var item in _notifications)
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              child: Text('Date',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                  fontSize: 18),
                                  textAlign: TextAlign.center),
                            width: MediaQuery.of(context).size.width/6,
                          ),
                          SizedBox(
                            child: Text('Keyword(s)',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                fontSize: 18),
                                textAlign: TextAlign.center),
                            width: MediaQuery.of(context).size.width/4,
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
                        ]),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
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
                                  child: Text('Go to Message', style: TextStyle(color: Colors.white),),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.black45),
                                    //shape: MaterialStateProperty.all(ContinuousRectangleBorder(borderRadius: BorderRadius.circular(30)))
                                  ),
                                  onPressed: () async {
                                    Navigator.pushNamed(context, '/mail_piece_view', arguments: await getMailPiece(item.mailPieceId));
                                  },
                                ),
                                Spacer(),
                                ElevatedButton(
                                  child: Text('Clear', style: TextStyle(color: Colors.white),),
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
                    ),),)
                  ],
                ),
              ),
              Container(//Manager1
                padding: EdgeInsets.fromLTRB(15, 15, 15, 35),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         Expanded(child:
                            Semantics(
                            excludeSemantics: true,
                            textField: true,
                            focusable: true,
                            label: "Keyword",
                            hint: "Enter notification keyword to add",
                            child:
                              Padding(padding:EdgeInsets.only(right:20), child:
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
                              ),),),
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
                          )
                        ]),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
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
                          child: Column(
                            children: [
                              for (var item in _subscriptions)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      child: Text(item.keyword, style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                          fontSize: 18),),
                                    ),
                                    SizedBox(
                                      child: OutlinedButton(
                                        child: Text(
                                          'Delete', semanticsLabel: "Delete ${item.keyword}",
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
  }


}
