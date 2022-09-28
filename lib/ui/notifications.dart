import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/main.dart';
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
    stt.setCurrentPage("notifications", this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Notifications"),
        backgroundColor: Colors.grey,
        leading: Builder(
          builder: (BuildContext context) {
            return BackButton(
              onPressed: () { navKey.currentState!.pushNamed('/main');},
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: const Color.fromRGBO(228, 228, 228, 0.6),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                            child: Text(
                              "Notifications",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                        Expanded(
                          child: Text(
                            "Manage",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ))
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}