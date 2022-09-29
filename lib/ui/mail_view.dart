import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';

class MailViewWidget extends StatelessWidget {
  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);
  final List<MailPiece> mailPieces = List.generate(
      10,
          (index) =>
          new MailPiece("", "", DateTime.now(), "John Doe", "Lorem ipsum dolor sit amet, ", "")
  );
  @override
  Widget build(BuildContext context) {
    Widget _buildMailPiece(MailPiece mailPiece) {
      return Container(
        color: Colors.white10,
        child: ListTile(
          horizontalTitleGap: 10.0,
          contentPadding: EdgeInsets.all(5),
          dense: true,
          onTap: () {
            Navigator.pushNamed(context, '/mail_piece_view', arguments: mailPiece);
          },
          //leading: mailPiece.mailImage,
          title:
          Row(
              children:[
                Container(
                  padding: EdgeInsets.only(right: 10.0),
                  child:
                  Text(
                    mailPiece.sender,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                Expanded(
                  child:
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children:[
                        Text(DateFormat('EEE hh:mm').format(mailPiece.timestamp)
                        ),
                        Text(DateFormat('MM/dd/yyyy').format(mailPiece.timestamp)
                        ),
                      ]),
                ),
              ]
          ),
          subtitle: Text(mailPiece.imageText.toString()),
        ),
      );
    };

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
          child: ListView(
            children: mailPieces.map(_buildMailPiece).toList(),
          ),
        ),
      ),
    );
  }
}

