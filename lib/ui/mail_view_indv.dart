import 'dart:js';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import '../services/mail_retrieveByMailPiece.dart';

class MailPieceViewWidget extends StatelessWidget{

  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);

  final MailPiece mailPiece;
  MimeMessage ? email;

  MailPieceViewWidget( {required this.mailPiece} );

  Future<void> _getMailPieceEmail() async {
    try {
        await MailPieceEmailFetcher().getMailPieceEmail(await Keychain().getUsername(), await Keychain().getPassword(), mailPiece)
            .then((value) => email = value);
  } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: AppBar(
        title: Text('Search Result: ${mailPiece.id}',  style:
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
              Text('SENT BY: ${mailPiece.sender}\n',
                  style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(51, 51, 102, 1.0)),
              ),
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

                      Text('RELEVANT TEXT: \n' + mailPiece.imageText,
                          style: TextStyle(fontSize: 15,
                            color: Color.fromRGBO(51, 51, 102, 1.0) ))
                    ]
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: new BorderRadius.circular(16.0),
                    color: _buttonColor
                  ),
                child:
                    Column(
                      children: [
                          Text('area for more actions\n\n',
                          style: TextStyle(fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                          ),
                          Text('area for do more with your mail\n\n',
                              style: TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                           ),
                    ]),
              ),
            ]),
          ),
      ),
    );

  }

}