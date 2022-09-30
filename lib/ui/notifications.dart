import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/main.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'bottom_app_bar.dart';


class NotificationsWidget extends StatefulWidget {
  const NotificationsWidget({Key? key}) : super(key: key);

  @override
  NotificationsWidgetState createState() => NotificationsWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();

class NotificationsWidgetState extends State<NotificationsWidget> {
  GlobalConfiguration cfg = GlobalConfiguration();

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
        body: const TabBarView(
          children: <Widget>[
            Center(
              child: Text("It's cloudy here"),
            ),
            Center(
              child: Text("It's rainy here"),
            ),
          ],
        ),
      ),
    );
    }
}