import 'package:LIVE365/SignIn/sign_in_screen.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/profile/components/profile_menu.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatelessWidget {
  static String routeName = "/setting";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              ProfileMenu(
                text: "My Account",
                icon: "assets/icons/User Icon.svg",
                press: () => {},
              ),
              ProfileMenu(
                text: "Contact Us",
                icon: "assets/icons/Bell.svg",
                press: _launchURL4,
              ),
              ProfileMenu(
                text: "Rate Us",
                icon: "assets/icons/Question mark.svg",
                press: _launchURL3,
              ),
              ProfileMenu(
                text: "Terms and Conditions",
                icon: "assets/icons/Question mark.svg",
                press: _launchURL,
              ),
              ProfileMenu(
                text: "Privacy Policy for LIVE365",
                icon: "assets/icons/Question mark.svg",
                press: _launchURL2,
              ),
              ProfileMenu(
                text: "Log Out",
                icon: "assets/icons/Log out.svg",
                press: () async {
                  FirebaseService().signOut();
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  _launchURL() async {
    const url = 'http://www.live365.sg/Terms.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL2() async {
    const url = 'http://www.live365.sg/Privacy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL3() async {
    const url = 'https://play.google.com/store/apps';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL4() async {
    const url = 'http://www.live365.sg/contact%20us.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
