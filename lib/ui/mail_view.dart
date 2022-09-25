import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
            children: mailPieces.map(_buildMialPiece).toList(),
          ),
        ),
      ),
    );
  }
}

Widget _buildMialPiece(MailPiece mailPiece) {
  return Container(
    color: Colors.white10,
    child: ListTile(
      horizontalTitleGap: 10.0,
      contentPadding: EdgeInsets.all(5),
      dense: true,
      onTap: () {},
      leading: mailPiece._mailImage,
      title:
      Row(
          children:[
            Container(
              padding: EdgeInsets.only(right: 10.0),
              child:
              Text(
                mailPiece._sender,
                style: TextStyle(fontSize: 20),
              ),
            ),
            Expanded(
              child:
              Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children:[
                    Text(DateFormat('EEE hh:mm').format(mailPiece._timeStamp)
                    ),
                    Text(DateFormat('MM/dd/yyyy').format(mailPiece._timeStamp)
                    ),
                  ]),
            ),
          ]
      ),
      subtitle: Text(mailPiece._mailDescription.toString()),
    ),
  );
}

class MailPiece {
  final DateTime _timeStamp;
  final String _sender;
  final String _imageText;
  final Image _mailImage;
  final String _mailDescription;

  MailPiece(
      {
        @required timeStamp,
        @required sender,
        @required imageText,
        mailImage,
        mailDescription
      })
      : this._timeStamp = timeStamp,
        this._sender = sender,
        this._imageText = imageText,
        this._mailImage = mailImage,
        this._mailDescription = mailDescription;

  DateTime get timeStamp => _timeStamp;
  String get sender => _sender;
  String get imageText => _imageText;
  String get mailDescription => _mailDescription;
  Image get mailImage => _mailImage;
}