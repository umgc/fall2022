import 'dart:convert';
import 'package:enough_mail/codecs.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import '../models/Digest.dart';
import '../services/mail_retrieveByMailPiece.dart';
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:url_launcher/url_launcher.dart';

class MailPieceViewWidget extends StatefulWidget{

  final MailPiece mailPiece;

  const MailPieceViewWidget({Key? key, required this.mailPiece}) : super(key: key);

  @override
  MailPieceViewWidgetState createState() => MailPieceViewWidgetState();
}

  GlobalConfiguration cfg = GlobalConfiguration();

  class MailPieceViewWidgetState extends State<MailPieceViewWidget> {
  GlobalConfiguration cfg = GlobalConfiguration();

  final FontWeight _commonFontWeight = FontWeight.w500;
  final double _commonFontSize = 30;
  final Color _buttonColor = Color.fromRGBO(51, 51, 102, 1.0);
  late Digest digest;
  late Image? mailImage = null;
  late String linkHTML = '<a href="https://informeddelivery.usps.com/box/pages/reminder/confirm?campId=1200041798&amp;deliveryDate=10/11/2022&amp;physicalAddressId=13671311&amp;mailpieceId=20152977694596">Some link text</a>';
  String link = 'https://informeddelivery.usps.com/box/pages/reminder/confirm?campId=1200041798;deliveryDate=10/11/2022;physicalAddressId=13671311;mailpieceId=20152977694596';
  //Image.asset('assets/mail.test.02.png');

  MailPieceViewWidgetState();

  @override
  void initState() {
    super.initState();
    _getMailPieceEmail();
  }

  Future<void> _getMailPieceEmail() async {
    MailPieceEmailFetcher mpef1 = await MailPieceEmailFetcher(widget.mailPiece.timestamp);
      debugPrint("ID: " + widget.mailPiece.id + "\nEmail ID: " + widget.mailPiece.emailId + "\nmid: " + widget.mailPiece.midId);
      digest = await mpef1.getMailPieceDigest();
      MimeMessage m1 = digest.message;
      _getImgFromEmail(m1);
      _getLinkHtmlFromEmail(m1);
  }

  void _getImgFromEmail(MimeMessage m) async {
    m = digest.message;
    for (int x = 0; x < m.mimeData!.parts!.length; x++) {
      for (int y = 0; y < m.mimeData!.parts!.elementAt(x).parts!.length; y++) {
        if (m.mimeData!.parts!.elementAt(x).parts!.elementAt(y).contentType?.value.toString()
            .contains("image") ?? false) {
          if (m.mimeData!.parts!.elementAt(x).parts!.elementAt(y)
              .toString()
              .contains(widget.mailPiece.midId)) {
            var picture = m.mimeData!.parts!.elementAt(x).parts!
                .elementAt(y)
                .decodeMessageData()
                .toString();
            //These are base64 encoded images with formatting
            picture = picture.replaceAll("\r\n", "");
            //These are base64 encoded images with formatting

            setState(() {
              mailImage = Image.memory(base64Decode(picture));
            });
          }
        }
      }
    }
  }

  void _getLinkHtmlFromEmail(MimeMessage m) async {
    m = digest.message;
    for (int x = 0; x < m.mimeData!.parts!.length; x++) {
      for (int y = 0; y < m.mimeData!.parts!.elementAt(x).parts!.length; y++) {
        if (m.mimeData!.parts!.elementAt(x).parts!.elementAt(y).contentType
            ?.value.toString()
            .contains("text/html") ?? false) {
          var doc = parse(m.mimeData!.parts!.elementAt(x).parts!.elementAt(y).toString());
          debugPrint(doc.getElementsByTagName("table").toString());

          /*
          setState(() {
            linkHTML = doc.getElementsByTagName("table").toString();
          });

           */
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: AppBar(
        title: Text('Search Result: ${widget.mailPiece.id}',  style:
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
              Text('SENT BY: ${widget.mailPiece.sender}\n',
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
                      Text('RECEIVED: ' + DateFormat('yyyy/MM/dd').format(widget.mailPiece.timestamp) + ' ' + DateFormat('EEE hh:mm a').format(widget.mailPiece.timestamp),
                          style: TextStyle(fontSize: 15)),
                      Text('RELEVANT TEXT: \n' + widget.mailPiece.imageText,
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
                        TextButton.icon(
                          onPressed: () async {

                            if(await canLaunch(link)){
                              await launch(link);
                            }else {
                              throw 'Could not launch $link';
                            }
                          },
                            icon: Icon(Icons.language),
                            label: Text('Open the link'),
                          ),
                       /*
                       Html(data: linkHTML,
                         onLinkTap: (linkHTML) async {
                           if (await canLaunch(linkHTML?))
                           {
                             await launch(linkHTML?);
                           } else {
                             debugPrint('Could not launch $linkHTML');
                           }
                         }
                       ),
                        */

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