import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';

import 'mail_view.dart';

class MailPieceViewWidget extends StatelessWidget{

  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);

  final MailPiece mailPiece;
  MailPieceViewWidget({required this.mailPiece});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: AppBar(
        title: Text('Search Results',  style:
        TextStyle(fontWeight: _commonFontWeight, fontSize: _commonFontSize),
        ),
        backgroundColor: _buttonColor,
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(15.0),
        child: Center(
          child: Column(children: [
            Text(mailPiece.sender),
            Text(mailPiece.timeStamp.toString()),
            Text(mailPiece.mailDescription),
            Text(mailPiece.imageText),
             mailPiece.mailImage
          ],)
        ),
      ),
    );
  }
}