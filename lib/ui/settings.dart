import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/main.dart';
import 'bottom_app_bar.dart';
import 'top_app_bar.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  SettingWidgetState createState() => SettingWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();

class SettingWidgetState extends State<SettingsWidget> {
  GlobalConfiguration cfg = GlobalConfiguration();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomBar(),
      appBar: TopBar(title: 'Settings'),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: const Color.fromRGBO(228, 228, 228, 0.6),
                child: Column(
                  children: [
                    Row(
                      children: const [
                        Expanded(
                            child: Text(
                          "Envelope Details",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ))
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Sender: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("sender"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("sender", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Recipient: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("recipient"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("recipient", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Logos: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("logos"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("logos", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Links: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("links"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("links", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Sender Address: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("address"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("address", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(top: 20),
                            child: const Text(
                              "Email Details",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Subject: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("email_subject"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("email_subject", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Email Text: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("email_text"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("email_text", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Sender Address: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("email_sender"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("email_sender", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: const Text("Recipients: "),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 50),
                            child: Switch(
                              value: cfg.getValue("email_recipients"),
                              activeTrackColor: Colors.lightGreenAccent,
                              activeColor: Colors.green,
                              onChanged: (bool value) {
                                setState(() {
                                  cfg.updateValue("email_recipients", value);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: const Text("Autoplay: "),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(right: 50),
                                  child: Switch(
                                    value: cfg.getValue("autoplay"),
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                    onChanged: (bool value) {
                                      setState(() {
                                        cfg.updateValue("autoplay", value);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 10),
                            child: const Text("Next Command"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
