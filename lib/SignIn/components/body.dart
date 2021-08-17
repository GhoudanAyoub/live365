import 'package:LIVE365/components/custom_card.dart';
import 'package:LIVE365/components/no_account_text.dart';
import 'package:LIVE365/components/socal_card.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../SizeConfig.dart';
import 'sign_form.dart';

class Body extends StatelessWidget {
  bool isSignIn = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  FacebookLogin facebookLogin = FacebookLogin();
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                Text(
                  "Welcome",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getProportionateScreenWidth(28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Sign in with your email and password  \nor continue with social media",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                SignForm(),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                SizedBox(height: getProportionateScreenHeight(20)),
                NoAccountText(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 150,
                      height: 1,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                    Divider(
                      indent: 5,
                      endIndent: 5,
                    ),
                    Text(
                      "OR",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white),
                    ),
                    Divider(
                      indent: 5,
                      endIndent: 5,
                    ),
                    SizedBox(
                      width: 150,
                      height: 1,
                      child: Container(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomCard(
                      borderRadius: BorderRadius.circular(20.0),
                      child: SocalCard(
                        icon: "assets/icons/google-icon.svg",
                        Name: "Join with Google",
                        press: () async {
                          await signInWithGoogle(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle(context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Checking Your Account.."),
      duration: Duration(seconds: 2),
    ));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("please Wait.."),
      duration: Duration(seconds: 2),
    ));
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    UserCredential userdata =
        await _firebaseAuth.signInWithCredential(credential).catchError((e) {
      print("Error===>" + e.toString());
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("please Wait.."),
      duration: Duration(seconds: 2),
    ));
    FirebaseService.addUsers(userdata.user);
    Navigator.pushNamed(context, HomeScreen.routeName);
  }

  Future<void> handleLogin(context) async {
    final FacebookLoginResult result = await facebookLogin.logIn(['email']);
    switch (result.status) {
      case FacebookLoginStatus.cancelledByUser:
        print(result.errorMessage);
        break;
      case FacebookLoginStatus.error:
        print(result.errorMessage);
        break;
      case FacebookLoginStatus.loggedIn:
        try {
          await loginWithfacebook(result, context);
        } catch (e) {
          print(e);
        }
        break;
    }
  }

  Future loginWithfacebook(FacebookLoginResult result, context) async {
    final FacebookAccessToken accessToken = result.accessToken;
    AuthCredential credential =
        FacebookAuthProvider.credential(accessToken.token);
    await _auth.signInWithCredential(credential).catchError((e) {
      print(e.toString());
    }).then((value) => () {
          FirebaseService.addUsers(value.user);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
        });
    isSignIn = true;
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}
