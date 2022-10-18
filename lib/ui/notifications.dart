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
            ),
          ]),
        ),
        body: TabBarView(
          children: <Widget>[
            Container( //Notifications
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                            child: Text('Date',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                fontSize: 18),),
                            padding:
                                EdgeInsets.only(left: 40, top: 20, bottom: 5)),
                        Container(
                          child: Text('Keyword(s)',style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                              fontSize: 18),),
                          padding:
                              EdgeInsets.only(left: 40, top: 20, bottom: 5),
                        ),
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
                  Container(  //the following code is used for notification subscriptions on the manage tab, but placed here for testing purposes and layout
                    height: 400,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var item in _subscriptions)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center, //displaying notifications subscriptions for testing purposes only
                              children: [
                                SizedBox(
                                  child: Text(item.keyword, style:TextStyle(color:Color.fromRGBO(51, 51, 102, 1),
                                      fontSize: 18),) ,
                                  width: 270,
                                ),
                                SizedBox(
                                  child: OutlinedButton(
                                    child: Text(
                                      'Delete',
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
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        width: MediaQuery.of(context).size.width/2,
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
                              width: MediaQuery.of(context).size.width/2,
                            ),
                            SizedBox(
                              child: OutlinedButton(
                                child: Text(
                                  'Delete',
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
