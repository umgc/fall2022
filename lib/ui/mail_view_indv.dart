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
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/mail_fetcher.dart';

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
  late String mailPieceId = '';

  late bool hasLearnMore = false;
  late Uri learnMoreLinkUrl = Uri.parse("https://www.google.com");
  late Uri reminderLinkUrl = Uri.parse("https://www.google.com");

  //these Html links really aren't used - delete eventually.  URL launcher works better
  late String learnMoreLinkHtml = '';
  late String reminderLinkHtml = '';

  MailPieceViewWidgetState();

  @override
  void initState() {
    super.initState();
    _getMailPieceEmail();
  }

  Future<void> _getMailPieceEmail() async {
    MailFetcher mf1 = new MailFetcher();
    debugPrint("ID: " +
        widget.mailPiece.id +
        "\nEmail ID: " +
        widget.mailPiece.emailId +
        "\nmid: " +
        widget.mailPiece.midId);
    digest = await mf1.getMailPieceDigest(widget.mailPiece.timestamp);
    MimeMessage m1 = digest.message;
    _getImgFromEmail(m1);
    _getLinkHtmlFromEmail(m1);
  }

  void _getImgFromEmail(MimeMessage m) async {
    //m = digest.message;
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
                .contains(widget.mailPiece.midId)) {
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
          }  //end if y element contains image
        } //end element(y) for loop
      } //end if contains multipart
    } //end element(x) for loop
  } //end _getImgFromEmail

  void _getLinkHtmlFromEmail(MimeMessage m) async {

    //m = digest.message;

    //based on test account, need to get 2nd level of parts to find image.  search in text/html part first
    for (int x = 0; x < m.mimeData!.parts!.length; x++) {

      //vvvvvv delete eventually vvvvvvv
      debugPrint("x = " +
          x.toString() +
          " of " +
          m.mimeData!.parts!.length.toString());
      debugPrint(m.mimeData!.parts!.elementAt(x).contentType?.value.toString());
      //^^^^^^ delete eventually ^^^^^^

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

          //vvvvvv delete eventually vvvvvvv
          debugPrint("y = " +
              y.toString() +
              " of " +
              m.mimeData!.parts!.elementAt(x).parts!.length.toString());
          debugPrint(m.mimeData!.parts!
              .elementAt(x)
              .parts!
              .elementAt(y)
              .contentType
              ?.value
              .toString());
          //^^^^^^ delete eventually ^^^^^^

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

            //first step is to get all elements that are image, and have alt text 'scanned image of your mail piece'.
            var scannedMailPieceItems = doc.querySelectorAll(
                'img[alt*=\'Scanned image of your mail piece\']');

            //scan through the mailpiece images to figure out which index matches the mailPiece Id.
            //this will be used to find the corresponding reminder link.
            int matchingIndex = -1;
            for (int i = 0; i < scannedMailPieceItems.length; i++) {
              if (scannedMailPieceItems[i]
                  .attributes
                  .toString()
                  .contains(widget.mailPiece.midId)) {
                matchingIndex = i;
                break;
              }
            }

            //A matchingIndex at this point of -1 meant a mail image wasn't found.  No point
            //further searching for reminders and learn more, should skip this at this point


            //next, get a list of <a> tags that have the reminder link.
            // They all have the same type of beginning syntax.
            var reminderItems = doc.querySelectorAll(
                'a[originalsrc*=\'informeddelivery.usps.com/box/pages/reminder\']');

            //need a counter for times the reminder mailPiece with image was found
            int reminderCount = 0;

            //find a reminder link with the image tag, this eliminates the duplicate link with the "Set a Reminder" text
            for (int i = 0; i < reminderItems.length; i++) {
              if (reminderItems[i].innerHtml.toString().contains("img")) {

                //we want to get the mailPieceID of the matching mailPiece.
                // Will help with getting the tracking item with learn more
                //the matchingIndex of the main mailPiece is used to get the associated reminder link

                if (reminderCount == matchingIndex) {
                  var regex = RegExp(
                      r'mailpieceId=\d*\"'); //finds the string mailpieceId=digits -to"
                  var regexNum = RegExp(r'\d+'); //get numbers only

                  var mpID1 =
                      regex.firstMatch(reminderItems[i].outerHtml.toString());

                  List<String> list = await _getLinks(reminderItems[i].outerHtml.toString());

                  //debugPrint(list.toString());
                  //debugPrint(reminderLinkUrl.toString());

                  //finally, set the state of the UI links to the matched element
                  setState(() {
                    //get the number out of the matched text
                    mailPieceId = regexNum
                        .firstMatch(mpID1![0]!.toString())![0]!
                        .toString();
                    reminderLinkHtml = reminderItems[i].outerHtml.toString();
                    reminderLinkUrl = Uri.parse(list[0]);

                  });
                  //break out of for after finding correct mailPiece
                  break;
                } // end if reminderCount = matchingIndex

                reminderCount++;

              } // end if reminderItems[i] contains img
            } // end for loop of reminderItems


            //next, get a list of <a> tags that have the tracking link.
            // All Learn More items have the tracking link and similar syntax.
            var trackingItems = doc.querySelectorAll(
                'a[originalsrc*=\'informeddelivery.usps.com/tracking\']');

            //initialize a counter for times the tracking mailPiece was found
            int trackingCount = 0;

            //find a tracking item with the Learn More and mailPieceId
            for (int i = 0; i < trackingItems.length; i++) {

              //need both because alt=Learn More is in innerHtml and link is in outerHtml

              String htmlString1 = trackingItems[i].innerHtml.toString();
              String htmlString2 = trackingItems[i].outerHtml.toString();

              if (htmlString1.contains("alt=\"Learn More\"") &&
                  htmlString2.contains(mailPieceId)) {

                List<String> list2 = await _getLinks(trackingItems[i].outerHtml.toString());

                //debugPrint(list2.toString());

                //set the state of the links to the matched element
                setState(() {
                  learnMoreLinkHtml = trackingItems[i].outerHtml.toString();
                  learnMoreLinkUrl = Uri.parse(list2[0]);
                  hasLearnMore = true;
                });
                //break out of for after finding correct mailPiece
                break;
              }
              trackingCount++; //increase trackingCount because match was found
            } //end for loop of tracking items


          } //end if contains text/html
        } //end element(y) for loop
      } //end if contains multipart
    } //end element(x) for loop
  } //end _getLinkHtmlFromEmail

  List<String> _getLinks(String x) {
    try {
      List<String> list = [];
      RegExp linkExp = RegExp(
          //variant regexp that didnt work
          //r"(http|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])");
          //r'"(https:\/\/nam11\.safelinks(.*?))"');

          r'"(https:\/\/informeddelivery(.*?))"');

      String text = x;

      //debugPrint(text);

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
        link = link.replaceAll('&amp','&'); //replace &amp with &
        link = link.replaceAll(";",""); //get rid of ;

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
        title:
          'Search Result: ${widget.mailPiece.id}',
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
                    child:
                    TextButton.icon(
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
                        textStyle : const TextStyle(
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
                        textStyle : const TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  //it doesn't seem like the html works correctly,
                  //ScottH could never get it to to display and be able to launch links
                  Html(
                    data: reminderLinkHtml,
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
