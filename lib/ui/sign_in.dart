import 'package:flutter/material.dart';
import 'package:summer2022/utility/Keychain.dart';
import 'package:summer2022/utility/Client.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:summer2022/services/analytics_service.dart';
import 'package:summer2022/services/cache_service.dart';
import 'package:summer2022/utility/locator.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  static const kPrimaryColor = Color(0xFF6F35A5);
  static const kPrimaryLightColor = Color(0xFFF1E6FF);
  static const double defaultPadding = 16.0;

  @override
  void initState() {
    super.initState();
    locator<AnalyticsService>().logScreens(name: "signIn");
    //FirebaseAnalytics.instance.setCurrentScreen(screenName: "SignIn");
    /*FirebaseAnalytics.instance.logEvent(
      name: 'screen_view',
      parameters: {
        'screenName': 'SignIn',
        'screenClass': 'signIn.dart',
      },
    );*/
  }
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showLoginErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Center(
            child: Text("Login Error"),
          ),
          content: SizedBox(
            height: 50.0, // Change as per your requirement
            width: 75.0, // Change as per your requirement
            child: Center(
              child: Text(
                "Login credentials failed.",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(51, 51, 102, 1),
      //bottomNavigationBar: const BottomBar(),
      //appBar: TopBar(title: "Sign In"),
      body: SingleChildScrollView(
        child: Container(
        width: MediaQuery.of(context).size.width,
        height: 700.0,
        child: SafeArea(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Container(
                padding: const EdgeInsets.all(15.0),
                width: 350,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(16.0)),
                ),
              //padding: const EdgeInsets.all(2.0),
              //child: Text("MailSpeak"),
                  child: Form(
                    child: Column(
                      children: [
                        /*Container(
                          alignment: Alignment.center,
                          child: Text("MailSpeak",
                            style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),)
                        ),*/
                        Container(
                          alignment: Alignment.center,
                          child: Image.asset("assets/icon/applogo-mailspeak-200.png" ),
                        ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      alignment: Alignment.center,
                      child: Text("USPS Informed Delivery Registered Email"),
                      ),
                        Container(
                      padding: const EdgeInsets.only(top: 15),
                      alignment: Alignment.center,
                      child: TextField(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'E-Mail Address',
                        ),
                        controller: emailController,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      alignment: Alignment.center,
                      child: TextField(
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        controller: passwordController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Password',
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.only(top: 15),
                      alignment: Alignment.center,
                      child: OutlinedButton(
                        onPressed: () async {
                          String email = emailController.text.toString();
                          String password =
                          passwordController.text.toString();
                          //If email validated through enough mail then switch to the main screen, if not, add error text to the to show on the screen
                          var loggedIn = await Client()
                              .getImapClient(email, password);
                          //Store the credentials into the the secure storage only if validated
                          if (loggedIn) {
                            Keychain().addCredentials(email, password);
                            await CacheService.updateMail(email, password);
                            Navigator.pushNamed(context, '/main');
                          } else {
                            showLoginErrorDialog();
                            context.loaderOverlay.hide();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(51, 51, 102, 1),
                          shadowColor: Colors.grey,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(5))),
                        ),
                        child: const Text(
                          "RETRIEVE MAIL",
                          style: TextStyle(color: Colors.white)                          ,
                        ),
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      alignment: Alignment.center,
                      child: Text(
                        "Not registered, click here."),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 0),
                      alignment: Alignment.center,
                      child: Text("Check out our privacy policy."),
                    ),
                      ],
                    ),
                  ),
              ),
            ]
            ),
          ),
        ),
        ),
    );
  }
}
