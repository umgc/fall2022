import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/main.dart';
import 'package:summer2022/models/Notification.dart';
import 'package:summer2022/ui/top_app_bar.dart';
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
  GlobalConfiguration cfg = GlobalConfiguration();
  var notificationSubList = <NotificationSubscription>[];

  var notificationSub = new NotificationSubscription('Test Keyword');  //TODO: create fetching new notification subscription


  void initState() {
    super.initState();
  }

  void addItemToList(){
    setState(() {
      notificationSubList.add(notificationSub);  //TODO: Add item to notification subscription list
    });
  }

  void removeItemFromList(String item) {
    setState(() {
      //var itemindexSubList = notificationSubList.indexWhere((element) => element.keyword == item);
      //notificationSubList.removeAt(itemindexSubList);
      notificationSubList.removeWhere((element) => element.keyword == item);  //TODO: remove item from notification subscription list
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(
        bottomNavigationBar: const BottomBar(),
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
                icon: new Image.asset("assets/icon/exit-icon.png", width: 30, height: 30), onPressed: () {Navigator.pushNamed(context, '/sign_in');} ),
          ],
          leading:
          IconButton(
            icon: new Image.asset("assets/icon/back-icon.png", width: 30, height: 30), onPressed: () =>Navigator.pop(context), ),
          centerTitle: true,

          title: Text("Notifications",
            style:
            TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(51, 51, 102, 1),
          bottom: const TabBar(
              tabs: <Widget>[
                Tab(text: "Notifications",), Tab(text: "Manage",)
              ]
          ),
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
                          child: Text('Date'), padding: EdgeInsets.only(left: 40, top: 20, bottom: 5)
                        ),
                        Container(
                          child: Text('Keyword(s)'), padding: EdgeInsets.only(left: 40, top: 20, bottom: 5),
                        ),
                      ]
                  ),
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
                  Row(
                    children: [
                      Container(
                        child: Text('Keyword(s)'), padding: EdgeInsets.only(left: 40),
                      ),
                      Container(
                          child: OutlinedButton(
                            child: Text('Add', style: TextStyle(color: Colors.white),),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))
                            ),
                            onPressed: () {
                              addItemToList();
                            },
                          ),
                        padding: EdgeInsets.only(left: 190),
                      )
                    ]
                  ),
                  Divider(
                    height: 20,
                    thickness: 2,
                    color: Colors.black,
                  ),
                  Column(
                    children: [
                      for(var item in notificationSubList)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [

                            SizedBox(
                              child: Text(item.keyword),
                              width: 270,
                            ),
                            SizedBox(
                              child: OutlinedButton(
                                child: Text('Delete', style: TextStyle(color: Colors.white),),
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateColor.resolveWith((states) => Colors.red),
                                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)))
                                ),
                                onPressed: () {
                                  removeItemFromList(item.keyword);
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
  Widget _buildList({required String key, required String string}) {
    return ListView.builder(
      key: PageStorageKey(key),
      itemBuilder: (_, i) => ListTile(title: Text("${string} ${i}")),
    );
  }
}
