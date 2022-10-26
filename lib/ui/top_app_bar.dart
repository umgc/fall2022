import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:summer2022/utility/user_auth_service.dart';
import 'package:summer2022/main.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Size preferredSize;
  final TabController? tabController;

  TopBar(
      {Key? key, required this.title, this.tabController = null}): this.preferredSize= ((title == "Notifications") ? Size.fromHeight(100.0) : Size.fromHeight(50.0)), super(key:key);

  @override
  TopBarState createState() => TopBarState();
}

class TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      actions: [
        Semantics(
            sortKey: OrdinalSortKey(3),
            child: PopupMenuButton(
                position: PopupMenuPosition.under,
                icon: Icon(Icons.menu_outlined),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(children: [
                        Text("Settings"),
                        Spacer(),
                        Image.asset("assets/icon/settings-icon.png",
                            width: 30, height: 30, excludeFromSemantics: true),
                      ]),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(children: [
                        Text("Logout"),
                        Spacer(),
                        Image.asset("assets/icon/exit-icon.png",
                            width: 30, height: 30, excludeFromSemantics: true),
                      ]),
                    ),
                  ];
                },
                onSelected: (value) async {
                  if (value == 0) {
                    Navigator.pushNamed(context, '/settings');
                  } else if (value == 1) {
                    /**
                       * Clears navigation stack, which will prevent redirecting to previous page with back gesture
                       * **/
                    bool isSignedGoogle =
                        await UserAuthService().isSignedIntoGoogle;
                    if (isSignedGoogle) {
                      await UserAuthService().signOut();
                    }
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/sign_in', (Route<dynamic> route) => false);
                  }
                }))
      ],
      leading:
          (this.widget.title != "Main Menu" && this.widget.title != "Sign In")
              ? (Semantics(
                  sortKey: OrdinalSortKey(2),
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
      title: Semantics(
        sortKey: OrdinalSortKey(1),
        child:
        Text("${this.widget.title}", style:
        TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
        ),
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Color.fromRGBO(51, 51, 102, 1),
      bottom: (this.widget.title == "Notifications")
          ? (TabBar(controller: this.widget.tabController,
              tabs: <Widget>[Tab(text: "Notifications"), Tab(text: "Manage")])
      )
          : null,
    );
  }
}
