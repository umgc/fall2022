import 'dart:convert';
import 'package:enough_mail/codecs.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import '../models/Digest.dart';
import '../services/mail_retrieveByMailPiece.dart';

class MailPieceViewWidget extends StatefulWidget{

  final MailPiece mailPiece;

  const MailPieceViewWidget({Key? key, required this.mailPiece}) : super(key: key);

  @override
  MailPieceViewWidgetState createState() => MailPieceViewWidgetState(mailPiece);
}

  GlobalConfiguration cfg = GlobalConfiguration();

  class MailPieceViewWidgetState extends State<MailPieceViewWidget> {
  GlobalConfiguration cfg = GlobalConfiguration();

  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);
  final mailPiece;
  late Digest digest;
  late Image? mailImage = null;
  //Image.asset('assets/mail.test.02.png');

  MailPieceViewWidgetState(this.mailPiece);

  @override
  void initState() {
    super.initState();
    @override
    Widget build(BuildContext context) {
      return Center(
          child: CircularProgressIndicator()
      );
    }
    _getMailPieceEmail();
    Navigator.of(context).pop();
  }

  Future<void> _getMailPieceEmail() async {
      MailPieceEmailFetcher mpef1 = await MailPieceEmailFetcher(mailPiece);
      digest = await mpef1.getMailPieceDigest();
      _getImgFromEmail();
  }

  void _getImgFromEmail() async {
    MimeMessage m = digest.message;
    for (int x = 0; x < m.mimeData!.parts!.length; x++) {
      if (m.mimeData!.parts!.elementAt(x).contentType?.value.toString().contains("image")??false) {
        if (m.mimeData!.parts!.elementAt(x).toString().contains(mailPiece.midId)) {
          var picture = m.mimeData!.parts!.elementAt(x).decodeMessageData().toString();
          //These are base64 encoded images with formatting
          picture = picture.replaceAll("\r\n", "");
          //These are base64 encoded images with formatting

          setState((){ mailImage = Image.memory(base64Decode(picture)); });
        }
      }
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
      body: SingleChildScrollView(
      child:
        Container(
        padding: EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            children: [
              Text('SENT BY: ${mailPiece.sender}\n',
                  style: TextStyle(fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(51, 51, 102, 1.0)),
              ),
              mailImage ?? Text("No Photo Loaded"), //load link to photo
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
                            color: Color.fromRGBO(51, 51, 102, 1.0) )),
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
            ]
          ),
        ),
      ),
    ),
  );

  }

}