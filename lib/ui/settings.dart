import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/ui/floating_home_button.dart';
import 'package:summer2022/ui/top_app_bar.dart';
import 'package:summer2022/ui/bottom_app_bar.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/utility/locator.dart';
import 'package:summer2022/ui/assistant_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:summer2022/firebase_options.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  SettingWidgetState createState() => SettingWidgetState();
}

GlobalConfiguration cfg = GlobalConfiguration();

class SettingWidgetState extends AssistantState<SettingsWidget> {
  GlobalConfiguration cfg = GlobalConfiguration();

  var url1 = Uri.parse("https://www.google.com/policies/privacy/");
  var url2 = Uri.parse("https://firebase.google.com/policies/analytics");
  var url3 =
  Uri.parse("https://www.apple.com/legal/privacy/data/en/app-store/");
  var url4 = Uri.parse("https://informeddelivery.usps.com");

  @override
  void initState() {
    super.initState();
    locator<AnalyticsService>().logScreens(name: "Settings");
  }

  void showTermsAndConditionsDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.only(top: 17, left: 20, right: 20, bottom: 20),
            title: Center(
                child: Text.rich(
                    TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        )
                    )
                )
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text(
                  'Close'
              ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
            content: Container(
              height: 300,
              width: 400,
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 5,
                radius: Radius.circular(20),
                scrollbarOrientation: ScrollbarOrientation.right,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        textAlign: TextAlign.justify,
                        TextSpan(
                            text: 'These terms and conditions outline the rules and regulations for the use of Mailspeak.'
                                '\n\nBy using this app we assume you accept these terms and conditions. Do not continue to use MailSpeak if you do not agree to take all of the terms and conditions stated on this page.'
                                '\n\nThe following terminology applied to these Terms and Conditions, Privacy Statement, Disclaimer Notice, and all Agreements: "Client", "You" and "Your" refers to you, the person logged onto this app and compliant to the terms and conditions outlined by United Global Master Coders. "UGMC", "Ourselves", "We", "Our" and "Us", refers to United Global Master Coders. "Party", "Parties", or "Us", refers to both the Client and ourselves. All terms refer to the offer, acceptance and consideration of payment necessary to undertake the process of our assistance to the Client in the most appropriate manner for the express purpose of meeting the Client’s needs in respect of provision of UGMC’s stated services, in accordance with and subject to, prevailing law of the United States. Any use of the above terminology or other words in the singular, plural, capitalization and/or he/she or they, are taken as interchangeable and therefore as referring to same.',
                            children: <TextSpan>[
                              TextSpan(
                                text: '\n\nLicense',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                )
                              ),
                              TextSpan(
                                text: '\n\nUnless otherwise stated, MailSpeak and/or its licensors own the intellectual property rights for all material on MailSpeak. All intellectual property rights are reserved. You may access this from MailSpeak for your own personal use subjected to restrictions set in these terms and conditions. '
                                    '\n\nYou must not:'
                                    '\n\n- Replenish material from MailSpeak'
                                    '\n- Sell, rent, or sub-license material from MailSpeak'
                                    '\n- Reproduce, duplicate, or copy material from MailSpeak'
                                    '\n\nThis agreement shall begin on the date hereof.'
                              ),
                              TextSpan(
                                text: '\n\nHyperlinking to our App',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: '\n\nThe following organizations may link to our App without prior written approval:'
                                    '\n\n- Government agencies;'
                                    '\n- Search Engines;'
                                    '\n- New organizations'
                                    '\n- Online directory distributors may link to our App in the same manner as they hyperlink to the Websites of other listed business; and'
                                    '\n- System wide Accredited Businesses except soliciting non-profit organizations, charity shopping malls, and charity fundraising groups which may not hyperlink to our App.'
                                    '\n\nThese organizations may link to our App, to publications, or to other app information so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products and/or services; and (c) fits within the context of the linking party’s website.'
                                    '\n\nWe may consider and approve other link requests from the following types of organizations:'
                                    '\n\n- commonly-known consumer and/or business information sources;'
                                    '\n- dot.com community sites;'
                                    '\n- associations or other groups representing charities;'
                                    '\n- online directory distributors;'
                                    '\n- internet portals;'
                                    '\n- accounting, law and consulting firms; and'
                                    '\n- educational institutions and trade associations.'
                                    '\n\nWe will approve link requests from these organizations if we decide that: (a) the link would not make us look unfavorably to ourselves or to our accredited businesses; (b) the organization does not have any negative records with us; (c) the benefit to us from the visibility of the hyperlink compensates the absence of MailSpeak; and (d) the link is in the context of general resource information.'
                                    '\n\nThese organizations may link to our App so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement or approval of the linking party and its products or services; and (c) fits within the context of the linking party’s site.'
                                    '\n\nIf you are one of the organizations listed in paragraph 2 above and are interested in linking to our App, you must inform us by sending an e-mail to MailSpeak. Please include your name, your organization name, contact information as well as the URL of your site, a list of any URLs from which you intend to link to our App, and a list of the URLs on our site to which you would like to link. Wait 2-3 weeks for a response.'
                                    '\n\nApproved organizations may hyperlink to our App as follows:'
                                    '\n\n- By use of our corporate name; or;'
                                    '\n- By use of the uniform resource locator being linked to; or;'
                                    '\n- By use of any other description of our App being linked to that makes sense within the context and format of content on the linked site of the party.'
                                    '\n\nNo use of the MailSpeak logo or other artwork will be allowed for linking absent a trademark license agreement.',
                              ),
                              TextSpan(
                                  text: '\n\niFrames',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: '\n\nWithout prior approval and written permission, you may not create frames that alter in any way the visual presentation or appearance of our App.'
                              ),
                              TextSpan(
                                text: '\n\nContent Liability',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: '\n\nWe shall not be hold responsible for any content that appears on your App. You agree to protect and defend us against all claims that is rising on our App. No link(s) should appear on any Website that may be interpreted as libelous, obscene or criminal, or which infringes, otherwise violates, or advocates the infringement or other violation of, any third party rights.',
                              ),
                              TextSpan(
                                  text: '\n\nYour Privacy',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: '\n\nPlease read the Privacy Policy.',
                              ),
                              TextSpan(
                                  text: '\n\nReservation of Rights',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: '\n\nWe reserve the right to request that you remove all links or any particular link to our App. You approve to immediately remove all links to our App upon request. We also reserve the right to amen these terms and conditions and it’s linking policy at any time. By continuously linking to our App, you agree to be bound to and follow these linking terms and conditions.',
                              ),
                              TextSpan(
                                  text: '\n\nRemoval of links from our App',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: '\n\nIf you find any link on our App that is offensive for any reason, you are free to contact and inform us any moment. We will consider requests to remove links but we are not obligated to or so or to respond to you directly. We do not ensure that the information on this App is correct, we do not warrant its completeness or accuracy; nor do we promise to ensure that the App remains available or that the material on the App is kept up to date.',
                              ),
                              TextSpan(
                                  text: '\n\nDisclaimer',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold
                                  )
                              ),
                              TextSpan(
                                text: '\n\nTo the maximum extent permitted by applicable law, we exclude all representations, warranties, and conditions to our App and its usage. Nothing in this disclaimer will:'
                                    '\n\n- limit or exclude our or your liability for death or personal injury;'
                                    '\n- limit or exclude our or your liability for fraud or fraudulent misrepresentation;'
                                    '\n- limit any of our or your liabilities in any way that is not permitted under applicable law; or'
                                    '\n- exclude any of our or your liabilities that may not be excluded under applicable law.'
                                    '\n\nThe limitations and prohibitions of liability set in this Section and elsewhere in this disclaimer: (a) are subject to the preceding paragraph; and (b) govern all liabilities arising under the disclaimer, including liabilities arising in contract, in tort and for breach of statutory duty.'
                                    '\n\nAs long as the App and the information and services on the App are provided free of charge, we will not be liable for any loss or damage of any nature.',
                              ),
                        ],
                            style: TextStyle(
                              fontSize: 14,
                            )
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
        );
      },
    );
  }

  void showPrivacyPolicyDialog(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            contentPadding: EdgeInsets.only(top: 17, left: 20, right: 20, bottom: 20),
            title: Center(
                child: Text.rich(
                    TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        )
                    )
                )
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))
            ),
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
                  padding: MaterialStateProperty.all(EdgeInsets.only(top: 8, left: 45, right: 45, bottom: 8)),
                  textStyle: MaterialStateProperty.all(TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                ),
                onPressed: (){
                  Navigator.of(context).pop();
                }, child: Text(
                  'Close'
              ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
            content: Container(
              height: 300,
              width: 400,
              child: Scrollbar(
                thumbVisibility: true,
                thickness: 5,
                radius: Radius.circular(20),
                scrollbarOrientation: ScrollbarOrientation.right,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      RichText(
                        textAlign: TextAlign.justify,
                          text: TextSpan(children: [
                            TextSpan(
                              text:
                              'United Global Master Coders has created a free app called MailSpeak. This Mobile Application is provided at no cost and is intended for use as is. '
                                  '\n\nThis page is used to inform app users of our policies regarding the collection, use, and disclosure of Personal Information should they decide to use our Service.'
                                  '\n\nIf you choose to use our Service, then you agree to the collection and use of information in relation to this policy. The Personal Information that we collect is used for providing and improving the Service. We will not use or share your information with anyone except as described in this Privacy Policy.'
                                  '\n\nInformation Collection and Use'
                                  '\n\nFor a better experience, while using our Service, we may require you to provide us with certain personally identifiable information, including but not limited to email, email password. The information that we request will be retained by us and used as described in this privacy policy. '
                                  '\n\nThe app does use third party services that may collect information used to identify you.'
                                  '\n\nLink to privacy policy of third-party service providers used by the app',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                                text: '\n\n• Google Play Services\n\n',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(url1);
                                  }),
                            TextSpan(
                                text: '• Google Firebase Analytics\n\n',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(url2);
                                  }),
                            TextSpan(
                                text: '• Apple App Store\n\n',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(url3);
                                  }),
                            TextSpan(
                              text:
                              'Affiliates and Business Partners\n\nWe share your information with our affiliates and business partners for internal business purposes, including for customer support, evaluation, marketing, and technical operations. \n\nLog Data\n\nWe want to inform you that whenever you use our Service, in a case of an error in the app we collect data and information (through third party products) on your phone called Log Data. This Log Data may include information such as your device Internet Protocol (“IP”) address, device name, operating system version, the configuration of the app when utilizing our Service, the time and date of your use of the Service, and other statistics. \n\nCookies\n\nCookies are files with a small amount of data that are commonly used as anonymous unique identifiers. These are sent to your browser from the websites that you visit and are stored on your devices internal memory. \n\nThis Service does not use these “cookies” explicitly. However, the app may use third party code and libraries that use “cookies” to collect information and improve their services. You have the option to either accept or refuse these cookies and know when a cookie is being sent to your device. If you choose to refuse our cookies, you may not be able to use some portions of this Service. \n\nService Providers\n\nWe may employ third-party companies and individuals due to the following reasons: \n\n•To facilitate our Service; \n\n•To provide the Service on our behalf; \n\n•To perform Service-related services; or\n\n•To assist us in analyzing how our Service is used. \n\nWe want to inform users of this Service that these third parties have access to your Personal Information. The reason is to perform the tasks assigned to them on our behalf. However, they are obligated not to disclose or use the information for any other purpose. \n\nSecurity\n\nWe value your trust in providing us your Personal Information, thus we are striving to use commercially acceptable means of protecting it. But remember that no method of transmission over the internet, or method of electronic storage is 100% secure and reliable, and we cannot guarantee its absolute security. \n\nLinks to Other Sites\n\nThis Service may contain links to other sites. If you click on a third-party link, you will be directed to that site. Note that these external sites are not operated by us. Therefore, we strongly advise you to review the Privacy Policy of these websites. We have no control over and assume no responsibility for the content, privacy policies, or practices of any third-party sites or services. \n\nChildren’s Privacy\n\nThese Services do not address anyone under the age of 13. We do not knowingly collect personally identifiable information from children under 13. In the case we discover that a child under 13 has provided us with personal information, we immediately delete this from our servers. If you are a parent or guardian and you are aware that your child has provided us with personal information, please contact us so that we will be able to do necessary actions.\n\nChanges to This Privacy Policy\n\nWe may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page. These changes are effective immediately after they are posted on this page.\n\nContact Us\n\nIf you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us.\n\n',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          ]))
                    ],
                  ),
                ),
              ),
            )
        );
      },
    );
  }

  void askConfirmationDialog() {
    Widget noButton =
      ElevatedButton(
        style: ButtonStyle(
          backgroundColor:
          MaterialStateProperty.all(Color.fromRGBO(51, 51, 102, 1)),
          padding: MaterialStateProperty.all(
              EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8)),
          textStyle: MaterialStateProperty.all(
            TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onPressed: () => Navigator.pop(context),
        child: Text('No'),
      );
    Widget yesButton =
      ElevatedButton(
        style: ElevatedButton.styleFrom(
            side: BorderSide(color: Color.fromRGBO(51, 51, 102, 1)),
            backgroundColor: Colors.white,
            foregroundColor: Color.fromRGBO(51, 51, 102, 1),
            padding: EdgeInsets.only(top: 8, left: 20, right: 20, bottom: 8),
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
        ),
        onPressed: () => _deleteEverything(),
        child: Text('Yes'),
      );

    //setup Alert Dialog
    AlertDialog confirmation = AlertDialog(
      title: Center(
        child: Text.rich(
          TextSpan(
            text: 'Delete Confirmation',
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      content: SizedBox(
        height: 50.0, // Change as per your requirement
        width: 75.0, // Change as per your requirement
        child: Center(
            child: Text.rich(
                textAlign: TextAlign.left,
                TextSpan(
                    text: 'Are you sure you want to delete all cached data?  This will delete everything and log you out.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    )
                )
            )
        ),
      ),
      actions: [yesButton, noButton],
    );

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return confirmation;
        });
  }

  void _deleteEverything() {
    // Remove saved login
    Keychain().deleteAll();
    // reset to default app settings
    cfg.loadFromAsset("app_settings");
    // clear cache
    CacheService.getInstance().clearAllCachedData();
    // return to login screen
    Navigator.pushNamed(context, '/sign_in');
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
      appBar: TopBar(title: 'Settings'),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 35.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Card(
                        elevation: 0,
                        child: ListTile(
                          leading: Icon(
                            Icons.content_paste_search_sharp,
                          ),
                          title: Text.rich(
                            TextSpan(
                              text: "Legal Notices",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey, width: 0.75)),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 25, right: 25),
                          title: Semantics(
                            excludeSemantics: true,
                            label: "Terms and Conditions",
                            button: true,
                            child: Text.rich(
                              TextSpan(
                                text: "Terms and Conditions",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right_rounded),
                          onTap: () {
                            showTermsAndConditionsDialog();
                            FirebaseAnalytics.instance.logEvent(name: 'TermsAndConditions',parameters:{'RequestedDialog':'Yes'});
                          },
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey, width: 0.75)),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.only(left: 25, right: 25),
                          title: Semantics(
                            excludeSemantics: true,
                            label: "Privacy Policy",
                            button: true,
                            child:Text.rich(
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),),
                            trailing: Icon(Icons.keyboard_arrow_right_rounded),
                          onTap: () {
                            showPrivacyPolicyDialog();
                            FirebaseAnalytics.instance.logEvent(name: 'PrivacyPolicy',parameters:{'RequestedDialog':'Yes'});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10.0),
                Container(
                    alignment: Alignment.center,
                    child: OutlinedButton(
                      onPressed: () async {
                        askConfirmationDialog();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(231, 25, 33, 1),
                        shadowColor: Colors.grey,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(5))),
                      ),
                      child: const Text(
                        "Delete All Local Data",
                        style: TextStyle(color: Colors.white),
                        semanticsLabel: "Delete Local Data",
                      ),
                    )
                ),
            ],
          ),
        ),
        ],
      ),
    );
  }
}
