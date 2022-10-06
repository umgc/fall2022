import 'dart:core';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/top_app_bar.dart';

import '../models/MailSearchParameters.dart';
import '../services/mail_service.dart';

class MailViewWidget extends StatelessWidget {

  final MailSearchParameters query;

  MailService mailService = MailService();
  MailViewWidget({required this.query});



  @override
  Widget build(BuildContext context) {

    List<MailPiece> mailPieces = [];
    final Future<List<MailPiece>> mailPiecesFuture = mailService.fetchMail(query);

    Widget _buildMailPiece(BuildContext context, MailPiece mailPiece) {
      return Container(
        color: Colors.white10,
        child:
        GestureDetector(
          child:
          Semantics(
            excludeSemantics: true,
            button: true,
            label: "Letter from ${mailPiece.sender} received on ${DateFormat('EEE MMM,d,yyyy').format(mailPiece.timestamp)}",
            hint: "Double tap to select.",
            child:
            Container(
              child:
                ListTile(
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
                                  Text(DateFormat('EEE hh:mm a').format(mailPiece.timestamp)
                                  ),
                                  Text(DateFormat('MM/dd/yyyy').format(mailPiece.timestamp)
                                  ),
                                ]),
                          ),
                        ]
                    ),
                    subtitle: Text(mailPiece.imageText.toString()),
                ),
            ),
          ),
        ),
      );
    }

    var mailPieceListViewWidget = FutureBuilder<List<MailPiece>>(
      future: mailService.fetchMail(query),
      builder: (context, AsyncSnapshot<List<MailPiece>> snapshot){
        if(snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              itemBuilder: (context, int index) {
                return _buildMailPiece(context, snapshot.data![index]);
              }
          );
        }
        else{
          return CircularProgressIndicator();
        }
      }
    );

    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(
          title: "Search Results"
      ),
      body: SafeArea(
        child:
          Container(
            padding: EdgeInsets.all(15.0),
            child:
              Column(
                children: [
                  SizedBox(
                    height: 20,

                    child:
                    Row(
                        children:[
                          Container(
                            child:
                            Text('SENT BY:',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child:
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children:[
                                  Text('TIME & DATE:',
                                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold) ),
                                ]),
                          ),
                        ]),
                  ),
                  Expanded(
                    child:
                    mailPieceListViewWidget,
                  ),
                ]),
            ),
      ),
    );


  }
}