import 'dart:convert';
import 'dart:io';
import 'package:enough_mail/codecs.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';
import 'package:summer2022/models/MailPiece.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:html/parser.dart';
import 'package:summer2022/services/mail_fetcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:summer2022/utility/linkwell.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/locator.dart';

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
  late bool hasSetReminder = false;
  late bool hasDoMore = false;
  late Uri? learnMoreLinkUrl = null;
  late Uri? reminderLinkUrl = null;

  MailPieceViewWidgetState();

  @override
  void initState() {
    //initial page loading state
    super.initState();
    setState(() {
      loading = true;
    });

    //display mailpiece data to console for record
    debugPrint("Loading data for mailpiece:"
            "\nid: " +
        widget.mailPiece.id.toString() +
        "\nscanImgCID: " +
        widget.mailPiece.scanImgCID.toString() +
        "\nuspsMID: " +
        widget.mailPiece.uspsMID.toString() +
        "\ndate: " +
        widget.mailPiece.timestamp.toString());

    //update mailPiece string data
    mailPieceText = _reformatMailPieceString(originalText);

    if (widget.mailPiece.scanImgCID != "") {
      _getMailPieceEmail();
    } else {
      // scanImgCID = "" means no image or links will be found. dont check email and remove do more section
      setState(() {
        mailImage = null;
        reminderLinkUrl = null;
        learnMoreLinkUrl = null;

        hasLearnMore = false;
        hasSetReminder = false;
        hasDoMore = false;

        loading = false;
      });
    }
    locator<AnalyticsService>().logScreens(name: 'Email');
    FirebaseAnalytics.instance.logEvent(
        name: 'EMail', parameters: {'uspsMID': widget.mailPiece.uspsMID});
  } //end init state


  //get the image of the mail piece
  Future<void> _getMailPieceEmail() async {
    MailFetcher mf1 = new MailFetcher();

    //get digest email only if not passed when calling page
    digest = widget.digest ??
        await mf1.getMailPieceDigest(widget.mailPiece.timestamp);

    MimeMessage m1 = digest.message;

    _getImgFromEmail(m1);
    //_mailPieceEmailTest(m1);  //only un-comment this when needing to test mailpiece loading functionality

    if (widget.mailPiece.uspsMID != "") {
      _getLinkHtmlFromEmail(m1);
    } else {
      // uspsMID = "" means it was not a correctly loaded mailPiece.  No links so skip function
      setState(() {
        reminderLinkUrl = null;
        learnMoreLinkUrl = null;

        hasLearnMore = false;
        hasSetReminder = false;
        hasDoMore = false;

        loading = false;
      });
    } //end else if uspsMID is = ""

    if (Firebase.apps.length != 0) {
      var EventParams = ['screen_view,page_location, page_referrer'];
      /*await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );*/
      FirebaseAnalytics.instance.setUserProperty(
          name: 'USPS_Email_MID', value: widget.mailPiece.uspsMID);
      // FirebaseAnalytics.instance
      //   .logEvent(name: 'AnalyticsParameterScreenName', parameters:;
    }
    ;
  } //end getMailPieceEmail

  void _getImgFromEmail(MimeMessage m) async {

    String? picture = null;
    for ( int x = 0; x < m.allPartsFlat.length; x++ ) {
      if ( m.allPartsFlat[x].decodeHeaderValue("Content-ID").toString().contains(widget.mailPiece.scanImgCID) ) {
        picture = m.allPartsFlat[x].decodeContentMessage().toString();
        break;
      }
    }
    if (picture != null) {
        //These are base64 encoded images with formatting, remove all returns and lines
        picture = picture.replaceAll("\r\n", "");
        debugPrint(
            "Loaded Image for scanImgCID: " + widget.mailPiece.scanImgCID);
        setState(() {
          mailImage = Image.memory(base64Decode(picture!));
        });
      } else {
        debugPrint('Image data could not be found');
      }

  } //end getImgFromEmail

  //sets state of URLs given the found email based on mailPiece
  void _getLinkHtmlFromEmail(MimeMessage m) async {

    MimePart textHtmlPart = m.getPartWithMediaSubtype(MediaSubtype.textHtml)!;

    //get the parts into an html document to make it searchable.
    var doc = parse( textHtmlPart.decodeTextHtmlPart() );

    //next, get a list of items that have the uspsMailID.  All mailpieces have these.
    var docMailIDItems =
        doc.querySelectorAll('a[originalsrc*=\'${widget.mailPiece.uspsMID}\']');

    if (docMailIDItems.length == 0) {
      docMailIDItems =
          doc.querySelectorAll('a[href*=\'${widget.mailPiece.uspsMID}\']');
    }

    // if the mailpiece is older than 30 days, skip the set reminder search
    Duration diff = DateTime.now().difference(widget.mailPiece.timestamp);
    if (diff.inDays >= 30) {
      hasSetReminder = false;
    } else {
      hasSetReminder = true;
    }

    String trackingItem = "";
    bool trackingMatch = false;

    bool reminderMatch = false;
    String reminderItem = "";

    if (hasSetReminder == true) {
      for (int j = 0; j < docMailIDItems.length; j++) {
        //find the element that contains "Set a Reminder"
        if (reminderMatch == false) {
          if (docMailIDItems[j]
              .outerHtml
              .toString()
              .contains("pages/reminder")) {
            reminderItem = docMailIDItems[j].outerHtml.toString();
            reminderMatch = true;
          }
        }

        //find the element that contains "Learn More"
        if (trackingMatch == false) {
          if (docMailIDItems[j]
              .innerHtml
              .toString()
              .contains("alt=\"Learn More\"")) {
            trackingItem = docMailIDItems[j].outerHtml.toString();
            trackingMatch = true;
          }
        }
        //stop searching after finding the correct matches
        if (trackingMatch == true && reminderMatch == true) {
          break;
        }
      }

      //get a list of links, only the first link should matter
      List<String> reminderLinkList = await _getUrlLinks(reminderItem);

      //get a list of links, if tracking match is not found it wont load a tracking link in set state below
      List<String> trackingLinkList = await _getUrlLinks(trackingItem);

      //finally, set the state of the links to the matched element
      setState(() {
        //get the number out of the matched text
        reminderLinkUrl = Uri.parse(reminderLinkList[0]);
        if (trackingMatch == true) {
          learnMoreLinkUrl = Uri.parse(trackingLinkList[0]);
          hasLearnMore = true;
        }

        if ((hasLearnMore || hasSetReminder) == true) {
          hasDoMore = true;
        } else {
          hasDoMore = false;
        }

        loading = false;
      }); //end of if SetReminder is true functions
    } else {
      //start of processing is SetReminder is false
      for (int j = 0; j < docMailIDItems.length; j++) {
        //find the element that contains "Learn More"
        if (trackingMatch == false) {
          if (docMailIDItems[j]
              .innerHtml
              .toString()
              .contains("alt=\"Learn More\"")) {
            trackingItem = docMailIDItems[j].outerHtml.toString();
            trackingMatch = true;
          }
        }
        //stop searching after finding the correct matches
        if (trackingMatch == true) {
          break;
        }
      }

      //get a list of links, if tracking match is not found it wont load a tracking link in set state below
      List<String> trackingLinkList = await _getUrlLinks(trackingItem);

      //finally, set the state of the links to the matched element
      setState(() {
        if (trackingMatch == true) {
          learnMoreLinkUrl = Uri.parse(trackingLinkList[0]);
          hasLearnMore = true;
          hasDoMore = true;
        }
        loading = false;
      });
    } //end else for tracking only link
  } //end getLinkHtmlEmail


  //this function tries to get URL links from a String
  List<String> _getUrlLinks(String x) {
    try {
      List<String> list = [];
      RegExp linkExp = RegExp(r'"(https:\/\/informeddelivery(.*?))"');

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
  } //end _getUrlLinks

  //Function to strip out all line feeds \n to make sure test would wrap, then add it back
  //for shorter blocks such as address or title blocks - currently set to 50 characters.
  //Future<String> _reformatMailPieceString(String x) async
  _reformatMailPieceString(String x) {
    final find = '\n';
    final replaceWith = ' ';
    final String original = x;
    final originalSplit = x.split('\n');
    for (int i = 0; i < originalSplit.length; i++) {
      if (originalSplit[i].length < 50) originalSplit[i] += ' ';
    }
    ;
    return originalSplit.join('\n');
  }


  //this function returns a String with how many days ago the mailpiece was received
  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 2) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays} day ago';
    } else {
      return 'Today';
    }
  } //end convertToAgo

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
      body: //in the main page, if loading is false, load container, if loading is true, run circ prog indicator
          loading == true
              ? Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      CircularProgressIndicator(),
                      Text(
                        '\nLOADING MAIL PIECE...',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(51, 51, 102, 1.0)),
                      )
                    ]))
              : SingleChildScrollView(
                  child: Container(
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
                        mailImage ??
                            Text("Image Not Available"), //load link to photo
                        Container(
                          margin: EdgeInsets.all(15),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Wrap(
                              direction: Axis.vertical,
                              alignment: WrapAlignment.start,
                              spacing: 15,
                              children: [
                                //Row(
                                //children: [
                                Text(
                                    'RECEIVED: ' +
                                        DateFormat('yyyy/MM/dd').format(
                                            widget.mailPiece.timestamp) +
                                        ', ' +
                                        convertToAgo(
                                            widget.mailPiece.timestamp),
                                    style: TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                        if (widget.mailPiece.links != null &&
                            widget.mailPiece.links!.isNotEmpty)
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: widget.mailPiece.links!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                            child: RichText(
                                          text: TextSpan(
                                              text: "View " +
                                                  widget
                                                      .mailPiece.links![index],
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 15),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  //Code to launch your URL
                                                  String text = widget
                                                      .mailPiece.links![index];
                                                  if (text.isNotEmpty) {
                                                    text = text.replaceAll(
                                                        ']', "");
                                                    text = text.replaceAll(
                                                        '[', "");
                                                    text = text.replaceAll(
                                                        ' ', "");
                                                    if (!text.startsWith(
                                                            'http') &&
                                                        !text.startsWith(
                                                            'https')) {
                                                      text = 'https://' + text;
                                                    }
                                                  }
                                                  Uri uri = Uri.parse(text);
                                                  print(uri.toString());
                                                  FirebaseAnalytics.instance
                                                      .logEvent(
                                                          name:
                                                              'Link_Navigated',
                                                          parameters: {
                                                        'itemId': text
                                                      });
                                                  if (await launchUrl(uri)) {
                                                    //await launchUrl(uri);
                                                  } else {
                                                    throw 'Could not launch ';
                                                  }
                                                }),
                                        ));
                                      }))),
                        if (widget.mailPiece.emailList != null &&
                            widget.mailPiece.emailList!.isNotEmpty)
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount:
                                          widget.mailPiece.emailList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                            child: RichText(
                                          text: TextSpan(
                                              text: "Email " +
                                                  widget.mailPiece
                                                      .emailList![index],
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 15),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  //Code to launch your URL
                                                  Uri uri = Uri.parse(
                                                      "mailto:" +
                                                          widget.mailPiece
                                                                  .emailList![
                                                              index]);
                                                  if (await launchUrl(uri)) {
                                                    await launchUrl(uri);
                                                  } else {
                                                    throw 'Could not launch ';
                                                  }
                                                }),
                                        ));
                                      }))),
                        if (widget.mailPiece.phoneNumbersList != null &&
                            widget.mailPiece.phoneNumbersList!.isNotEmpty)
                          Container(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: widget
                                          .mailPiece.phoneNumbersList!.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Container(
                                            child: RichText(
                                          text: TextSpan(
                                              text: "Contact " +
                                                  widget.mailPiece
                                                      .phoneNumbersList![index],
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 15),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () async {
                                                  //Code to launch your URL
                                                  Uri uri = Uri.parse("tel:" +
                                                      widget.mailPiece
                                                              .phoneNumbersList![
                                                          index]);
                                                  if (await launchUrl(uri)) {
                                                    await launchUrl(uri);
                                                  } else {
                                                    throw 'Could not launch ';
                                                  }
                                                }),
                                        ));
                                      }))),
                        Row(children: [
                          Visibility(
                            visible: hasDoMore,
                            child: Container(
                              width: MediaQuery.of(context).size.width / 1.15,
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
                                      if (await canLaunchUrl(
                                          learnMoreLinkUrl!)) {
                                        await launchUrl(learnMoreLinkUrl!);
                                        FirebaseAnalytics.instance.logEvent(
                                            name: 'LearnMore_Clicked',
                                            parameters: {
                                              'itemId': widget.mailPiece.uspsMID
                                            });
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
                                Visibility(
                                  visible: hasSetReminder,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      if (await canLaunchUrl(
                                          reminderLinkUrl!)) {
                                        await launchUrl(reminderLinkUrl!);
                                        FirebaseAnalytics.instance.logEvent(
                                            name: 'SetAReminder_Clicked',
                                            parameters: {
                                              'itemId': widget.mailPiece.uspsMID
                                            });
                                      } else {
                                        throw 'Could not launch $reminderLinkUrl';
                                      }
                                    },
                                    icon:
                                        Icon(Icons.calendar_month, size: 40.0),
                                    label: Text('Set a Reminder'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      textStyle: const TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          )
                        ]),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width / 1.15,
                              child: LinkWell(
                                mailPieceText,
                                style: TextStyle(
                                    color: Color.fromRGBO(51, 51, 102, 1.0),
                                    fontStyle: FontStyle.italic),
                              ),
                            )
                          ],
                        ),
                      ]),
                    ),
                  ),
                ),
    );
  }


  //mailPieceEmailTest is just a function used to test the mailPiece processing,
  // but per email, and without saving.  It can take awhile to verify the main mailpiece processor
  //works in mail_fetcher since it executes automatically and can process a lot of emails
  void _mailPieceEmailTest (MimeMessage email) {

    /*
    int mimePartMatch1 = -1;
    int mimePartMatch2 = -1;
    String mimePartMatchLevel = '';

    var mimeParts = email.mimeData!.parts!;
    RegExp test1 = RegExp(r'multipart|text/html');

    for (int x = 0; x < mimeParts.length; x++) {
      String elementXString = mimeParts[x].contentType?.mediaType
          .toString() ?? "";
      if (test1.hasMatch(elementXString!)) {
        if (elementXString.contains("text/html")) {
          mimePartMatch1 = x;
          mimePartMatchLevel = "One";
          break;
        } else {
          for (int y = 0; y < mimeParts[x].parts!.length; y++) {
            String subPartTopType =
            mimeParts[x].parts![y].contentType!.mediaType.toString();

            if (subPartTopType.contains("text/html")) {
              mimePartMatch1 = x;
              mimePartMatch2 = y;
              mimePartMatchLevel = "Two";
              break;
            } //end y has text/html
          } //end y loop
        } //end else
      } //end x has either multipart or text/html
    } //end x loop

    var textHtmlPart = mimeParts[0];

    if (mimePartMatchLevel == 'One') {
      textHtmlPart = mimeParts[mimePartMatch1];
    } else if (mimePartMatchLevel == 'Two') {
      textHtmlPart = mimeParts[mimePartMatch1].parts![mimePartMatch2];
    }

     */

    for ( int x = 0; x < email.allPartsFlat.length; x++ ) {
      if ( email.allPartsFlat[x].decodeHeaderValue("Content-ID").toString().contains(widget.mailPiece.scanImgCID) ) {
        debugPrint(email.allPartsFlat[x].decodeHeaderValue("Content-ID").toString());
      }
    }


    MimePart textHtmlPart = email.parts!.first;

    if ( email.getPartWithMediaSubtype(MediaSubtype.textHtml) != null ) {
      textHtmlPart = email.getPartWithMediaSubtype(MediaSubtype.textHtml)!;
    }

    //get the parts into an html document to make it searchable.

    var doc = parse( textHtmlPart.decodeTextHtmlPart() );

    //#############start mailPieceId section################

    //this section of code finds the USPS mailpiece ID in the email associated with the
    //image CID.  Useful in getting links per mailpiece.

    String? mailPieceId = "";
    //need to get text/html section of email

    if (widget.mailPiece.scanImgCID.contains("ra_0_") ) { //start code for ride along processing

      //first step is to get all elements that are image, and have alt text 'scanned image of your mail piece'.
      var rideAlongItems = doc.querySelectorAll(
          'img[alt*=\'ride along content for your mail piece\']');

      int matchingIndex = -1;
      for (int i = 0; i < rideAlongItems.length; i++) {
        if (rideAlongItems[i]
            .attributes
            .toString()
            .contains(widget.mailPiece.scanImgCID)) {
          matchingIndex = i;
          break;
        }
      }

      //print debug error that the scanImgCID didn't find a match.
      if (matchingIndex == -1) {
        debugPrint("For mailPiece " +
            widget.mailPiece.scanImgCID +
            " there was no associated ID.");
      }

      //next, get a list of items that have the tracking link.  All ride alongs have a tracking link.
      var trackingItems = doc.querySelectorAll('a[originalsrc*=\'informeddelivery.usps.com/tracking\']');

      if ( trackingItems.length == 0 ) {
        trackingItems = doc.querySelectorAll(
            'a[href*=\'informeddelivery.usps.com/tracking\']');
      }

      //need a counter for times the reminder mailPiece with image was found
      int trackingCount = 0;
      //find a reminder with the image tag, this eliminates the duplicate tag with the "Set a Reminder" text
      for (int i = 0; i < trackingItems.length; i++) {
        if (trackingItems[i].innerHtml.toString().contains("img")) {
          //we want to get the mailPieceID of the matching mailPiece.  Will help with getting other items
          if (trackingCount == matchingIndex) {
            var regex = RegExp(
                r'mailpiece=\d*\&'); //finds the string mailpieceId=digits to "
            var regexNum = RegExp(r'\d+'); //get numbers only

            var mpID1 =
            regex.firstMatch(trackingItems[i].outerHtml.toString());

            mailPieceId = regexNum
                .firstMatch(mpID1![0]!.toString())![0]!
                .toString();

            debugPrint("Date: " +
                DateFormat('yyyy/MM/dd').format(widget.mailPiece.timestamp) +
                "; scanImgCID: " +
                widget.mailPiece.scanImgCID +
                "; has matching USPS-ID: " +
                mailPieceId);

            //break out of for after finding correct mailPiece
            break;
          }
          trackingCount++;
        }
      } //end for loop for trackingItems
    } else { //start code for normal mailpiece

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
            .contains(widget.mailPiece.scanImgCID)) {
          matchingIndex = i;
          break;
        }
      }

      //print debug error that the scanImgCID didn't find a match.
      if (matchingIndex == -1) {
        debugPrint("For mailPiece " +
            widget.mailPiece.scanImgCID +
            " there was no associated ID.");
      }

      //next, get a list of items that have the reminder link.  They all have the reminder link.
      var reminderItems = doc.querySelectorAll('a[originalsrc*=\'informeddelivery.usps.com/box/pages/reminder\']');
      //'a[\'*informeddelivery.usps.com/box/pages/reminder\']');


      if ( reminderItems.length == 0 ) {
        reminderItems = doc.querySelectorAll(
            'a[href*=\'informeddelivery.usps.com/box/pages/reminder\']');
      }

      //need a counter for times the reminder mailPiece with image was found
      int reminderCount = 0;
      //find a reminder with the image tag, this eliminates the duplicate tag with the "Set a Reminder" text
      for (int i = 0; i < reminderItems.length; i++) {
        if (reminderItems[i].innerHtml.toString().contains("img")) {
          //we want to get the mailPieceID of the matching mailPiece.  Will help with getting other items
          if (reminderCount == matchingIndex) {
            var regex = RegExp(
                r'(mailpieceId=)(\d*\")'); //finds the string mailpieceId=digits to "

            var regexNum = RegExp(r'\d+'); //get numbers only

            /*
            var mpID1 =
            regex.firstMatch(reminderItems[i].outerHtml.toString());
             */

            mailPieceId = regex.firstMatch( reminderItems[i].outerHtml.toString() )?[2].toString() ?? '';

            /*
            mailPieceId = regexNum
                .firstMatch(mpID1![0]!.toString())![0]!
                .toString();
 */

            debugPrint("Date: " +
                DateFormat('yyyy/MM/dd').format(widget.mailPiece.timestamp) +
                "; scanImgCID: " +
                widget.mailPiece.scanImgCID +
                "; has matching USPS-ID: " +
                mailPieceId);

            //break out of for after finding correct mailPiece
            break;
          }
          reminderCount++;
        } //end if reminder item has img
      }//end for loop for reminderItems
    } //end else for normal mailpiece process

  }//end mailPieceEmailTest



} //end of class MailPieceViewWidget
