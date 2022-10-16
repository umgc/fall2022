import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';

class MailPieceViewWidget extends StatelessWidget{

  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);

  final MailPiece mailPiece;
  MailPieceViewWidget({required this.mailPiece});

  @override
  Widget build(BuildContext context) {
    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: showHomeButton,
        child: FloatingHomeButton(parentWidgetName: context.widget.toString()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: 'Search Results'),
      body:
    SingleChildScrollView(
      child:
        Container(
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
      ),
    );
  }
}