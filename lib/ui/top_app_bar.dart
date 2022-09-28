import 'package:flutter/material.dart';
import '../main.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Size preferredSize = Size.fromHeight(50.0);

  TopBar(
      {Key? key, required this.title}): super(key:key);

  @override
  TopBarState createState() => TopBarState();
}

class TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {

      return AppBar(
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

          title: Text("${this.widget.title}",
          style:
          TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(51, 51, 102, 1)
      );
    }
  }