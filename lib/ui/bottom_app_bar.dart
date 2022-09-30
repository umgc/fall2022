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
      color: Color.fromRGBO(51, 51, 102, 1),
      child: Row(
        children: <Widget>[
          // TODO: Add other icons
          Spacer(),
          Semantics(
            excludeSemantics: true,
            button: true,
            label: "Chatbot",
            child:
            IconButton(
              icon: new Image.asset("assets/icon/chatbot-icon.png"),
              onPressed: () {
                Navigator.pushNamed(context, "/chat");
                },
            ),
          ),
        ],
      ),
    );
  }
}