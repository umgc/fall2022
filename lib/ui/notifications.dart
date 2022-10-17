import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/services/mail_notifier.dart';
import 'assistant_state.dart';
import 'bottom_app_bar.dart';
import 'package:summer2022/models/NotificationSubscription.dart';

class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({Key? key}) : super(key: key);
  @override
  NotificationsWidgetState createState() => NotificationsWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();

class NotificationsWidgetState extends AssistantState<NotificationsWidget> {
  final _notifier = MailNotifier();
  final _keywordController = TextEditingController();

  var _subscriptions = <NotificationSubscription>[];

  @override
  void initState() {
    super.initState();
    updateSubscriptionList();
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

  void addSubscription(String keywords) async {
    for (final text in keywords.split(',')) {
      final keyword = text.trim();
      if (keyword.isEmpty) continue;
      final subscription = NotificationSubscription(keyword);
      await _notifier.createSubscription(subscription);
    }
    await updateSubscriptionList();
  }

  void removeSubscription(String keyword) async {
    final subscription = NotificationSubscription(keyword);
    await _notifier.removeSubscription(subscription);
    await updateSubscriptionList();
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
            )
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                            child: Text('Date'),
                            padding:
                                EdgeInsets.only(left: 40, top: 20, bottom: 5)),
                        Container(
                          child: Text('Keyword(s)'),
                          padding:
                              EdgeInsets.only(left: 40, top: 20, bottom: 5),
                        ),
                      ]),
                  Divider(
                    height: 20,
                    thickness: 2,
                    color: Colors.black,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Row(children: [
                    Container(
                      child: SizedBox(
                        child: TextField(
                          controller: _keywordController,
                          onSubmitted: (keywords) {
                            addSubscription(keywords);
                            _keywordController.clear();
                          },
                          decoration: const InputDecoration(
                              labelText: 'Keyword(s)',
                              isDense: true,
                              border: InputBorder.none),
                        ),
                        width: 300,
                      ),
                      padding: EdgeInsets.only(left: 5),
                    ),
                    Container(
                      child: OutlinedButton(
                        child: Text(
                          'Add',
                          style: TextStyle(color: Colors.white),
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
                  Divider(
                    height: 20,
                    thickness: 2,
                    color: Colors.black,
                  ),
                  Column(
                    children: [
                      for (var item in _subscriptions)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              child: Text(item.keyword),
                              width: 270,
                            ),
                            SizedBox(
                              child: OutlinedButton(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.white),
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
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
