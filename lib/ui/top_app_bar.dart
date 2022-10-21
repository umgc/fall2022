import 'package:flutter/material.dart';
import 'package:summer2022/utility/user_auth_service.dart';
import '../main.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Size preferredSize = Size.fromHeight(50.0);

  TopBar({Key? key, required this.title}) : super(key: key);

  @override
  TopBarState createState() => TopBarState();
}

class TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(

        actions:[
          Semantics(
              label: "Show Menu",
              button: true,
              excludeSemantics: true,
              child:
              PopupMenuButton(
                  position: PopupMenuPosition.under,
                  icon: Icon(Icons.menu_outlined),
                  itemBuilder: (context){
                    return [
                      PopupMenuItem<int>(
                        value: 0,
                        child:
                        Row(
                            children:[
                              Text("Settings"),
                              Spacer(),
                              Image.asset("assets/icon/settings-icon.png", width: 30, height: 30),
                            ]),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child:
                        Row(children: [
                          Text("Logout"),
                          Spacer(),
                          Image.asset("assets/icon/exit-icon.png", width: 30, height: 30),
                        ]),
                      ),
                    ];
                  },
                  onSelected:
                      (value){
                    if(value == 0){
                      Navigator.pushNamed(context, '/settings');
                    }else if(value == 1){
                      /**
                       * Clears navigation stack, which will prevent redirecting to previous page with back gesture
                       * **/
                      Navigator.pushNamedAndRemoveUntil(context,'/sign_in', (Route<dynamic> route) => false);
                    }
                  }
              ))
        ],
        leading:
            (this.widget.title != "Main Menu" && this.widget.title != "Sign In")
                ? (Semantics(
                    excludeSemantics: true,
                    button: true,
                    label: "Back",
                    onTap: () {
                      navKey.currentState!.pushNamed('/main');
                    },
                    child: IconButton(
                        icon: new Image.asset("assets/icon/back-icon.png",
                            width: 30, height: 30),
                        onPressed: () => Navigator.pop(context)),
                  ))
                : null,
        centerTitle: true,
        title: Text(
          "${this.widget.title}",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(51, 51, 102, 1),
        bottom:
        (this.widget.title == "Notifications") ?
        (const TabBar(
            tabs: <Widget>[
              Tab(text: "Notifications"), Tab(text: "Manage")
            ]
        )
        ) : null,
    );
  }
}
