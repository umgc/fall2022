import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/main.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'bottom_app_bar.dart';
import 'package:summer2022/models/NotificationSubscription.dart';
import 'package:summer2022/models/Notification.dart';


class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({Key? key}) : super(key: key);
  @override
  NotificationsWidgetState createState() => NotificationsWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();

class NotificationsWidgetState extends State<NotificationsWidget> {
  GlobalConfiguration cfg = GlobalConfiguration();
  late final NotificationSubscription notificationSubscription;
  final List<NotificationSubscription> notificationSubscriptions = List.generate(
      3,
          (index) =>
      new NotificationSubscription("Testing")
  );
  @override
  void initState() {
    super.initState();
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
                icon: new Image.asset("assets/icon/settings-icon.png", width: 30, height: 30), onPressed: () {Navigator.pushNamed(context, '/settings');} ),
            IconButton(
                icon: new Image.asset("assets/icon/exit-icon.png", width: 30, height: 30), onPressed: () {Navigator.pushNamed(context, '/sign_in');} ),
          ],
          leading:
          IconButton(
            icon: new Image.asset("assets/icon/back-icon.png", width: 30, height: 30), onPressed: () { navKey.currentState!.pushNamed('/main');}, ),
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
            Center(
              child: Text("It's cloudy here"),
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
                            onPressed: () {},
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
                  Container(
                    child: ListView.builder(
                          itemCount: 3,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: ListTile(
                                title: Text("This is title"),
                              ),
                            );
                          }
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*Container(
                      child: ListView.builder(
                          itemCount: notificationSubscriptions.length,
                          itemBuilder: (context, int index) {
                            return Text(notificationSubscriptions[index].toString());
                          }
                      ),
                    ),*/