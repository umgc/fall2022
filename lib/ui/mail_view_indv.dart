import 'dart:convert';
import 'package:enough_mail/codecs.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import '../models/Digest.dart';
import '../services/mail_retrieveByMailPiece.dart';
import 'package:html/parser.dart';
import 'package:url_launcher/url_launcher.dart';

class MailPieceViewWidget extends StatefulWidget {
  final MailPiece mailPiece;

  const MailPieceViewWidget({Key? key, required this.mailPiece})
      : super(key: key);

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
  late bool hasLearnMore = false;
  late Uri learnMoreLinkUrl = Uri.parse("http://www.google.com");
  late Uri reminderLinkUrl = Uri.parse("http://www.google.com");

  MailPieceViewWidgetState();

  @override
  void initState() {
    super.initState();
    _getMailPieceEmail();
  }

  Future<void> _getMailPieceEmail() async {
    MailPieceEmailFetcher mpef1 =
        await MailPieceEmailFetcher(widget.mailPiece.timestamp);
    digest = await mpef1.getMailPieceDigest();
    MimeMessage m1 = digest.message;
    _getImgFromEmail(m1);
    _getLinkHtmlFromEmail(m1);
  }

  //sets state mailImage given the found email based on mailPiece
  void _getImgFromEmail(MimeMessage m) async {
    for (int x = 0; x < m.mimeData!.parts!.length; x++) {
      if (m.mimeData!.parts!
              .elementAt(x)
              .contentType
              ?.value
              .toString()
              .contains("multipart") ??
          false) {
        for (int y = 0;
            y < m.mimeData!.parts!.elementAt(x).parts!.length;
            y++) {
          if (m.mimeData!.parts!
                  .elementAt(x)
                  .parts!
                  .elementAt(y)
                  .contentType
                  ?.value
                  .toString()
                  .contains("image") ??
              false) {
            if (m.mimeData!.parts!
                .elementAt(x)
                .parts!
                .elementAt(y)
                .toString()
                .contains(widget.mailPiece.scanImgCID)) {
              var picture = m.mimeData!.parts!
                  .elementAt(x)
                  .parts!
                  .elementAt(y)
                  .decodeMessageData()
                  .toString();
              //These are base64 encoded images with formatting, remove all returns and lines
              picture = picture.replaceAll("\r\n", "");

              setState(() {
                mailImage = Image.memory(base64Decode(picture));
              });
            } //end if y element contains midId
          } //end if y element contains image
        } //end element(y) for loop
      } //end if contains multipart
    } //end element(x) for loop
  } //end _getImgFromEmail

  //sets state of URLs given the found email based on mailPiece
  void _getLinkHtmlFromEmail(MimeMessage m) async {
    //based on test account, need to get 2nd level of parts to find image.  search in text/html part first
    for (int x = 0; x < m.mimeData!.parts!.length; x++) {
      if (m.mimeData!.parts!
              .elementAt(x)
              .contentType
              ?.value
              .toString()
              .contains("multipart") ??
          false) {
        for (int y = 0;
            y < m.mimeData!.parts!.elementAt(x).parts!.length;
            y++) {
          if (m.mimeData!.parts!
                  .elementAt(x)
                  .parts!
                  .elementAt(y)
                  .contentType
                  ?.value
                  .toString()
                  .contains("text/html") ??
              false) {
            //get the parts into an html document to make it searchable.
            //need to decode Text into 'quoted-printable' type to see all the link text values
            var doc = parse(m.mimeData!.parts!
                .elementAt(x)
                .parts!
                .elementAt(y)
                .decodeText(
                    ContentTypeHeader('text/html'), 'quoted-printable'));

            //next, get a list of items that have the reminder link.  All mailpieces have the reminder link.
            var reminderItem = doc.querySelector(
                'a[originalsrc*=\'${widget.mailPiece.uspsMID}\'], a[originalsrc*=\'Set Reminder\']');

            List<String> reminderLinkList =
                await _getLinks(reminderItem!.outerHtml.toString());

            //finally, set the state of the links to the matched element
            setState(() {
              //get the number out of the matched text
              reminderLinkUrl = Uri.parse(reminderLinkList[0]);
            });

            //next, get a list of items that have the tracking link.  All learn more has the tracking link.
            var trackingItem = doc.querySelector(
                'a[originalsrc*=\'informeddelivery.usps.com/tracking\'], a[originalsrc*=\'${widget.mailPiece.uspsMID}\']');

            /*
            //find a reminder with the image tag, this eliminates the duplicate tag with the "Set a Reminder" text
            for (int i = 0; i < trackingItems.length; i++) {
            */

            if (trackingItem.toString().contains("alt=\"Learn More\"") &&
                trackingItem.toString().contains(widget.mailPiece.uspsMID)) {
              List<String> trackingLinkList =
                  await _getLinks(trackingItem!.outerHtml.toString());

              //set the state of the links to the matched element
              setState(() {
                learnMoreLinkUrl = Uri.parse(trackingLinkList[0]);
                hasLearnMore = true;
              });
              //break out of for after finding correct mailPiece
            }
          } //end if contains text/html
        } //end element(y) for loop
      } //end if contains multipart
    } //end element(x) for loop
  } //end _getLinkHtmlFromEmail

  List<String> _getLinks(String x) {
    try {
      List<String> list = [];
      RegExp linkExp = RegExp(
          r'"(https:\/\/informeddelivery(.*?))"');

      String text = x;

      //remove encoding to make text easier to interpret
      text = text.replaceAll('\r\n', " ");
      text = text.replaceAll('<', " ");
      text = text.replaceAll('>', " ");
      text = text.replaceAll(']', " ");
      text = text.replaceAll('[', " ");

      while (linkExp.hasMatch(text)) {
        var match = linkExp.firstMatch(text)?.group(0);
        String link = match.toString();

        link = link.replaceAll('"', ""); //get rid of "
        link = link.replaceAll('&amp', '&'); //replace &amp with &
        link = link.replaceAll(";", ""); //get rid of ;

        list.add(link);
        text = text.substring(text.indexOf(match.toString()) +
            match
                .toString()
                .length); //remove the found link and continue searching
      }
      return list;
    } catch (e) {
      rethrow;
    }
  } //end _getLinks

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
      appBar: TopBar(
        title: 'Search Result: ${widget.mailPiece.id}',
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child: Center(
            child: Column(children: [
              Text(
                'SENT BY: ${widget.mailPiece.sender}\n',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(51, 51, 102, 1.0)),
              ),
              mailImage ?? Text("No Photo Loaded"), //load link to photo
              Container(
                padding: EdgeInsets.all(15),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.start,
                      spacing: 15,
                      children: [
                        Text(
                            'RECEIVED: ' +
                                DateFormat('yyyy/MM/dd')
                                    .format(widget.mailPiece.timestamp) +
                                ' ' +
                                DateFormat('EEE hh:mm a')
                                    .format(widget.mailPiece.timestamp),
                            style: TextStyle(fontSize: 15)),
                        Text('RELEVANT TEXT: \n' + widget.mailPiece.imageText,
                            style: TextStyle(
                                fontSize: 15,
                                color: Color.fromRGBO(51, 51, 102, 1.0))),
                      ]),
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: new BorderRadius.circular(16.0),
                    color: _buttonColor),
                child: Column(children: [
                  Text(
                    'Do more with your mail\n',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.white),
                  ),
                  Visibility(
                    visible: hasLearnMore,
                    child: TextButton.icon(
                      onPressed: () async {
                        if (await canLaunchUrl(learnMoreLinkUrl)) {
                          await launchUrl(learnMoreLinkUrl!);
                        } else {
                          throw 'Could not launch $learnMoreLinkUrl';
                        }
                      },
                      icon: Icon(Icons.language, size: 40.0),
                      label: Text('Learn More'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      if (await canLaunchUrl(reminderLinkUrl)) {
                        await launchUrl(reminderLinkUrl!);
                      } else {
                        throw 'Could not launch $reminderLinkUrl';
                      }
                    },
                    icon: Icon(Icons.calendar_month, size: 40.0),
                    label: Text('Set a Reminder'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
