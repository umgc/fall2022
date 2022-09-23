import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bottom_app_bar.dart';
import 'package:summer2022/models/Digest.dart';
import 'package:summer2022/main.dart';

class OtherMailWidget extends StatefulWidget {
  final List<Digest> emails;

  const OtherMailWidget({required this.emails});

  @override
  State<OtherMailWidget> createState() {
    return OtherMailWidgetState();
  }
}

class OtherMailWidgetState extends State<OtherMailWidget> {
  // ReadMail? reader;
  late int index;
  FontWeight commonFontWt = FontWeight.w500;
  double commonFontSize = 28;

  @override
  void initState() {
    // index must be initialed before build or emails won't iterate
    super.initState();
  }

  MimeMessage getCurrentEmailMessage() {
    return widget.emails[index].message;
  }

  String removeLinks(Digest d) {
    RegExp linkExp = RegExp(
        r"(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])");
    RegExp carotsExpn = RegExp(r"\<https.+?\>");
    RegExp squaresExpn = RegExp(r"\[.+?\]");
    RegExp squaresExpn2 = RegExp(r"\[(.|\n|\r)*\]");
    RegExp tagsExpn = RegExp(r"r/");
    String text =
        d.message.decodeTextPlainPart() ?? ""; //get body text of email

    text = text.replaceAll(linkExp, '');
    text = text.replaceAll('\r', '');
    text = text.replaceAll('\r\n', '\n');
    text = text.replaceAll('\n\n', '');
    text = text.replaceAll(carotsExpn, '');
    text = text.replaceAll(squaresExpn, '');
    text = text.replaceAll(squaresExpn2, '');
    text = text.replaceAll(tagsExpn, '');

    return text;
  }

  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      return '${diff.inDays} day(s) ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hour(s) ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute(s) ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} second(s) ago';
    } else {
      return 'just now';
    }
  }

  void swipeLeftRight(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // User swiped Left
      print("Swep Left to Right");
      setState(() {
        seekBack();
      });
    } else if (details.primaryVelocity! < 0) {
      // User swiped Right
      print("Swap Right to Left");
      setState(() {
        seekForward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int emailsLen = widget.emails.length;
    var parsedDate =
        DateTime.parse(widget.emails[index].message.decodeDate().toString());
    final DateFormat formatter = DateFormat('yyyy-MM-dd h:mm:ss');
    final String formatted = formatter.format(parsedDate);
    String timeAgo = convertToAgo(parsedDate);
    return GestureDetector(
      onHorizontalDragEnd: swipeLeftRight,
       child: Scaffold(
          bottomNavigationBar: const BottomBar(),
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              formatted,
              style: TextStyle(fontWeight: commonFontWt, fontSize: commonFontSize),
            ),
            backgroundColor: Colors.grey,
            leading: Builder(
              builder: (BuildContext context) {
                return BackButton(
                  onPressed: () { navKey.currentState!.pushNamed('/main');},
                );
              },
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                  width: double.infinity,
                ),
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: RichText(
                      text: TextSpan(children: <TextSpan>[
                        const TextSpan(
                            text: 'SUBJECT: ',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 2)),
                        TextSpan(
                            text: widget.emails[index].message
                                .decodeSubject()
                                .toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16)),
                        const TextSpan(
                            text: '\nSENDER: ',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 2)),
                        TextSpan(
                            text: widget.emails[index].message
                                .decodeSender()
                                .toString(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16)),
                        const TextSpan(
                            text: '\nSENT: ',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                height: 2)),
                        TextSpan(
                            text: '$timeAgo\n\n',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16)),
                        TextSpan(
                            text: removeLinks(widget.emails[index]),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.normal,
                                fontSize: 16)),
                      ]),
                    ),
                    //.horizontal
                  ),
                ),
                const SizedBox(
                  height: 15,
                  width: double.infinity,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    FloatingActionButton(
                      backgroundColor: Colors.grey,
                      heroTag: "f1",
                      onPressed: () {
                        seekBack();
                      },
                      child: const Icon(Icons.skip_previous),
                    ),
                    Text(
                      '${emailsLen - (index)}/$emailsLen',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.grey,
                      heroTag: "f2",
                      onPressed: () {
                        seekForward();
                      },
                      child: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
    );
  }

  void seekBack() {
    setState(() {
      if (index != widget.emails.length - 1) {
        index++;
      }
      // reader!.setCurrentMail(widget.emails[index].message);
      
    });
    // try {
    //   setTtsState(TtsState.playing);
    //   readMailPiece();
    // } catch(e) {
    //   debugPrint("ERROR: Seek back: ${e.toString()}");
    // }
  }

  void seekForward() {
    if (mounted) {
      setState(() {
        if (index != 0) {
          index--;
        }
        // reader!.setCurrentMail(widget.emails[index].message);
      });
      // try {
      //   setTtsState(TtsState.playing);
      //   readMailPiece();
      // } catch(e) {
      //   debugPrint("ERROR: Seek forward: ${e.toString()}");
      // }
      // autoplay();
    }
  }

  // Future<bool> readMailPiece() async {
  //   try{
  //     if(reader != null) {
  //       await reader!.readEmailInfo();
  //     }
  //   } catch (e) {
  //     debugPrint("ERROR: Read mail piece: ${e.toString()}");
  //   }
  //   return true;
  // }
}
