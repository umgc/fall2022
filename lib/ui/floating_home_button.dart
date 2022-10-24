import 'package:flutter/material.dart';

class FloatingHomeButton extends StatefulWidget {
  final String parentWidgetName;

  FloatingHomeButton(
      {Key? key, required this.parentWidgetName}): super(key:key);

  @override
  FloatingHomeButtonState createState() => FloatingHomeButtonState();
}

class FloatingHomeButtonState extends State<FloatingHomeButton> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
        excludeSemantics: true,
        button: true,
        label: "Home",
        onTap: () {
            if (this.widget.parentWidgetName != "MainWidget") {
                //clears navigation stack
                Navigator.pushNamedAndRemoveUntil(context,'/main', (Route<dynamic> route) => false);
            }
          },
        child:
          FloatingActionButton(
          onPressed: () {
            if (this.widget.parentWidgetName != "MainWidget") {
              //clears navigation stack
              Navigator.pushNamedAndRemoveUntil(context,'/main', (Route<dynamic> route) => false);
            }
          },
          child: Image.asset("assets/icon/home-icon.png",
            width: 35.0,
            height: 35.0,),
          backgroundColor: Color.fromRGBO(51, 51, 102, 1),
        ),
    );
  }
}