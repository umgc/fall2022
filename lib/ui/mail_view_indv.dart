import 'dart:convert';
import 'package:enough_mail/codecs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:html/parser.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:summer2022/services/mail_fetcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:summer2022/utility/linkwell.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:summer2022/firebase_options.dart';

class MailPieceViewWidget extends StatefulWidget {
  final MailPiece mailPiece;
  final Digest? digest;

  const MailPieceViewWidget({Key? key, required this.mailPiece, this.digest})
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
  late String originalText = widget.mailPiece.imageText;
  String mailPieceText = '';

  bool loading = true;

  late bool hasLearnMore = false;
  late bool hasDoMore = false;
  late Uri? learnMoreLinkUrl = null;
  late Uri? reminderLinkUrl = null;

  MailPieceViewWidgetState();

  @override
  void initState() {
    super.initState();
    setState(() {
      loading = true;
    });
    if(widget.mailPiece.scanImgCID != "") {
      _getMailPieceEmail();
      mailPieceText = _reformatMailPieceString(originalText);
    } else {
      // scanImgCID = "" means no image or links will be found. dont check email and remove do more section
      setState(() {
        mailImage = null;
        reminderLinkUrl = null;
        learnMoreLinkUrl = null;
        hasDoMore = false;
        hasLearnMore = false;
        loading = false;
      });
    }
  }

  Future<void> _getMailPieceEmail() async {
    MailFetcher mf1 = new MailFetcher();
    digest = widget.digest ?? await mf1.getMailPieceDigest(widget.mailPiece.timestamp);
    MimeMessage m1 = digest.message;
    _getImgFromEmail(m1);
    _getLinkHtmlFromEmail(m1);

    if(Firebase.apps.length != 0){
      var EventParams = ['screen_view,page_location, page_referrer'];
      /*await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );*/
      FirebaseAnalytics.instance
          .setUserProperty(name: 'USPS_Email_MID', value: widget.mailPiece.uspsMID);
     // FirebaseAnalytics.instance
       //   .logEvent(name: 'AnalyticsParameterScreenName', parameters:;
    };

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
              break; //break when image is found
            } //end if y element contains scanImgCID
          } //end if y element contains image
        } //end element(y) for loop
        break; //break if found multipart, don't need to run anymore
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

            //next, get a list of items that have the uspsMailID.  All mailpieces have these.
            var docMailIDItems = doc.querySelectorAll(
                'a[originalsrc*=\'${widget.mailPiece.uspsMID}\']');

            String reminderItem = "";
            String trackingItem = "";
            bool reminderMatch = false;
            bool trackingMatch = false;

            for (int j = 0; j < docMailIDItems.length; j++) {

              //find the element that contains "Set a Reminder"
              if (reminderMatch == false) {
                if (docMailIDItems[j].outerHtml.toString().contains(
                    "pages/reminder")) {
                  reminderItem = docMailIDItems[j].outerHtml.toString();
                  reminderMatch = true;
                }
              }

              //find the element that contains "Learn More"
              if (trackingMatch == false) {
                if ( docMailIDItems[j].innerHtml.toString().contains(
                    "alt=\"Learn More\"") ) {
                  trackingItem = docMailIDItems[j].outerHtml.toString();
                  trackingMatch = true;
                }
              }
              //stop searching after finding the correct matches
              if (trackingMatch == true && reminderMatch == true){
                break;
              }
            }

            //get a list of links, only the first link should matter
            List<String> reminderLinkList = await _getLinks(reminderItem);

            //get a list of links, if tracking match is not found it wont load a tracking link in set state below
            List<String> trackingLinkList = await _getLinks(trackingItem);

            //finally, set the state of the links to the matched element
            setState(() {
              hasDoMore = true;
              //get the number out of the matched text
              reminderLinkUrl = Uri.parse(reminderLinkList[0]);
              if(trackingMatch == true ) {
                learnMoreLinkUrl = Uri.parse(trackingLinkList[0]);
                hasLearnMore = true;
              }
              loading = false;
            });
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

        link = link.replaceAll('"', ""); //get rid of quotes
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

  //Function to strip out all line feeds \n to make sure test would wrap, then add it back
  //for shorter blocks such as address or title blocks - currently set to 50 characters.
  //Future<String> _reformatMailPieceString(String x) async
  _reformatMailPieceString(String x) {
    final find = '\n';
    final replaceWith = ' ';
    final String original = x;
    final originalSplit = x.split('\n');
    for(int i=0; i< originalSplit.length; i++) {
        if(originalSplit[i].length < 50)
          originalSplit[i] += '\n';
    };
    return originalSplit.join(' ');
  }

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
        title: 'Mail Piece',
      ),
      body:  //in the main page, if loading is false, load container, if loading is true, run circ prog indicator
          loading == true ? Center(
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children:[ CircularProgressIndicator(),
                                    Text(
                                      '\nLOADING MAIL PIECE...',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(51, 51, 102, 1.0)),
                                    )
                                  ])
                              ):
        SingleChildScrollView(
          child:
          Container(
          alignment: Alignment.topCenter,
          margin: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 35.0),
          child: Center(
            widthFactor: .85,
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
                margin: EdgeInsets.all(15),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Wrap(
                      direction: Axis.vertical,
                      alignment: WrapAlignment.start,
                      spacing: 15,
                      children: [
                        Row(
                          children:[
                                Text(
                                'RECEIVED: ',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, )),
                                Text(
                                    DateFormat('yyyy/MM/dd')
                                        .format(widget.mailPiece.timestamp),
                                style: TextStyle(fontSize: 15)),
                              ],
                        ),
                        Row(
                          children:[
                            Visibility(
                              visible: hasDoMore,
                              child:
                              Container(
                                width: MediaQuery.of(context).size.width/1.15,
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
                                              if (await canLaunchUrl(learnMoreLinkUrl!)) {
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
                                          if (await canLaunchUrl(reminderLinkUrl!)) {
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
                                ]),
                              ),
                            )
                          ]
                        ),
                        Row(
                            children:[
                                  Container(
                                    width: MediaQuery.of(context).size.width/1.15,
                                    child: LinkWell(
                                      mailPieceText,
                                      style: TextStyle(color: Color.fromRGBO(51, 51, 102, 1.0), fontStyle: FontStyle.italic),),
                                  )
                                    ],
                        ),
                      ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }


} //end of class MailPieceViewWidget
