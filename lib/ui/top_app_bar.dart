import 'package:flutter/material.dart';
import '../main.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  //final String title = "";
  //final backgroundColor;
  const TopBar(
      {Key? key, required this.title}): super(key:key);

  Size get preferredSize => Size.fromHeight(50.0);

  //const TopBar({required String this.title});

  @override
  TopBarState createState() => TopBarState();
}

class TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    //preferredSize: const Size.fromHeight(50);
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
          //todo - need to dynamically set the page title
          title: Text("${this.widget.title}",
          style:
          TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromRGBO(51, 51, 102, 1)
      );
    }
  }