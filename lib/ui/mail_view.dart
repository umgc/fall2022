import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';

class MailViewWidget extends StatelessWidget {
  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);
  final List<MailPiece> mailPieces = List.generate(
      10,
          (index) => new MailPiece(
              timeStamp: DateTime.now(),
              sender: "John Doe",
              mailImage: Image.asset('assets/mail.test.02.png'),
              mailDescription: "Lorem ipsum dolor sit amet, "
              "consectetur adipiscing elit. "
              "Sed consequat, quam non dictum volutpat, dolor odio sagittis dui, "
              "quis dictum turpis nisl non ex. Donec suscipit euismod rutrum. ",
              imageText: "Lorem ipsum dolor sit amet, "
      )
  );
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
          child: ListView(
            children: mailPieces.map(_buildMailPiece).toList(),
          ),
        ),
      ),
    );
  }
}

Widget _buildMailPiece(MailPiece mailPiece) {
  return Container(
    color: Colors.white10,
    child: ListTile(
      horizontalTitleGap: 10.0,
      contentPadding: EdgeInsets.all(5),
      dense: true,
      onTap: () {},
      leading: mailPiece.mailImage,
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
                    Text(DateFormat('EEE hh:mm').format(mailPiece.timeStamp)
                    ),
                    Text(DateFormat('MM/dd/yyyy').format(mailPiece.timeStamp)
                    ),
                  ]),
            ),
          ]
      ),
      subtitle: Text(mailPiece.mailDescription.toString()),
    ),
  );
}

class MailPiece {
  final DateTime timeStamp;
  final String sender;
  final String imageText;
  final Image mailImage;
  final String mailDescription;

  MailPiece(
      {
        @required timeStamp,
        @required sender,
        @required imageText,
        mailImage,
        mailDescription
      })
      : this.timeStamp = timeStamp,
        this.sender = sender,
        this.imageText = imageText,
        this.mailImage = mailImage,
        this.mailDescription = mailDescription;
}