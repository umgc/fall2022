import 'dart:core';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/models/MailSearchParameters.dart';
import 'package:summer2022/services/mailPiece_service.dart';
import 'package:summer2022/models/MailPieceViewArguments.dart';

class MailViewWidget extends StatefulWidget {

  final MailSearchParameters query;

  final MailPieceService _mailService = MailPieceService();

  MailViewWidget({required this.query});

  @override
  MailViewWidgetState createState() => MailViewWidgetState();
}

class MailViewWidgetState extends State<MailViewWidget> {

  //this is temporary for list view display, need to eventually delete when search results are achieved
  List<MailPiece> mailPieces = _createMailPieces();

  static List<MailPiece> _createMailPieces() {
    List<MailPiece> _mailPieces = List.generate(
        10,
            (index) => new MailPiece(
            "", "", DateTime.now(), "John Doe", "Lorem ipsum dolor sit amet, ",
            "", ""),
        growable: true
    );

    MailPiece m = new MailPiece(
        "id", "emailId", DateTime(2022, 10, 3), "sender",
        "## ImageText Contents ##", "mail ID content do not need to include 'cid:'", "");

    _mailPieces.add(m);

    return _mailPieces;
  }

  @override
  Widget build(BuildContext context) {

    Widget _buildMailPiece(BuildContext context, MailPiece mailPiece) {
      return Container(
        color: Colors.white10,
        child:
        GestureDetector(
          child:
          Semantics(
            excludeSemantics: true,
            link: true,
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
                      Navigator.pushNamed(context, '/mail_piece_view', arguments: new MailPieceViewArguments(mailPiece));
                    },
                    //leading: mailPiece.mailImage,
                    title:
                    Row(
                        children:[
                          Expanded(
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
      future: widget._mailService.fetchMail(widget.query),
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

    bool showHomeButton = MediaQuery.of(context).viewInsets.bottom == 0;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: showHomeButton,
        child: FloatingHomeButton(parentWidgetName: context.widget.toString()),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                                  Text('DATE:',
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