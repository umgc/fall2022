import 'package:flutter/material.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xff004B87),

      child: Row(
        children: <Widget>[
          // TODO: Add other icons
          IconButton(
          icon: const Icon(Icons.markunread_mailbox_outlined, color: Color(0xFFFFFFFF)),
            onPressed: () {
            Navigator.pushNamed(context, "/search");
            },
          ),
          Spacer(),
          IconButton(
            tooltip: "Open chat bot",
            icon: const Icon(Icons.headset_mic, color: Color(0xFFFFFFFF)),
            onPressed: () {
              Navigator.pushNamed(context, "/chat");
            },
          ),
        ],
      ),
    );
  }
}