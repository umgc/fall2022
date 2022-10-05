import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:fall2022/models/MailPiece.dart';
import 'package:fall2022/ui/bottom_app_bar.dart';

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
          child: Column(
            children: [
                Image.asset('assets/mail.test.02.png'), //load link to photo
                Container(
                padding: EdgeInsets.all(15),
                child:
                    Align(
                      alignment: Alignment.topLeft,
                      child:
                      Wrap(
                        direction: Axis.vertical,
                        alignment: WrapAlignment.start,
                        spacing: 15,
                        children: [
                          Text('RECEIVED: ' + DateFormat('yyyy/MM/dd').format(mailPiece.timestamp) + ' ' + DateFormat('EEE hh:mm a').format(mailPiece.timestamp),
                              style: TextStyle(fontSize: 15)),
                          Text('SENT BY: ' + mailPiece.sender,
                              style: TextStyle(fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(51, 51, 102, 1.0)),
                          ),
                          Text('RELEVANT TEXT: \n' + mailPiece.imageText,
                              style: TextStyle(fontSize: 15,
                                color: Color.fromRGBO(51, 51, 102, 1.0) ))
                        ]
                      ),
                    ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}