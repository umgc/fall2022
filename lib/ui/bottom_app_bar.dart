import 'package:flutter/material.dart';

import '../main.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  BottomBarState createState() => BottomBarState();
}

class BottomBarState extends State<BottomBar> {
  bool micOn = true;
  bool speakerOn = true;
  double commonIconSize = 110;
  bool micStatus = false;
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        // MODE Dialog Box
        padding: const EdgeInsets.only(top: 0, bottom: 0, left: 0, right: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            /*
            IconButton(
              icon: Icon(
                (speakerOn == true)
                    ? Icons.volume_up_outlined
                    : Icons.volume_off_rounded,
                size: commonIconSize,
              ),
              onPressed: () {
                setState(
                  () {
                    speakerOn = !speakerOn;
                  },
                );
              },
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                (micOn == true) ? Icons.mic_none : Icons.mic_off,
                size: commonIconSize,
              ),
              onPressed: () {
                setState(
                  () {
                    micOn = !micOn;
                  },
                );
              },
            ),
            */
            // Padding(
            //   // MODE Dialog Box
            //   padding:
            //       const EdgeInsets.only(top: 0, bottom: 80, left: 25, right: 0),
            //   child: IconButton(
            //       icon: Icon(Icons.help_outline, size: commonIconSize),
            //       onPressed: () {
            //         print("Say commands out loud");
            //       }),
            // ),
            const Spacer(),
            recordButton(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  GestureDetector recordButton() {
    var micNotActive = Padding(
      // MODE Dialog Box
      padding: const EdgeInsets.only(top: 5, bottom: 10, left: 0, right: 30),
      child:
          Icon(Icons.mic_sharp, size: commonIconSize + 10, color: Colors.black),
    );
    var micActive = Padding(
      // MODE Dialog Box
      padding: const EdgeInsets.only(top: 5, bottom: 10, left: 0, right: 30),
      child:
          Icon(Icons.mic_sharp, size: commonIconSize + 10, color: Colors.red),
    );

    return GestureDetector(
      // TODO:  Proper nav for this
        onTap: () {
          Navigator.pushNamed(context, '/chat');
        },
        onLongPress: () {
          setState(() {
            micStatus = true;
          });
        },
        onLongPressUp: () {
          setState(() {
            micStatus = false;
          });
        },
        onDoubleTap: () {
          setState(() {
            micStatus = false;
          });
        },
        child: micStatus ? micActive : micNotActive);
  }
}
