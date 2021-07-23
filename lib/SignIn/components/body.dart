import 'dart:convert';

import 'package:LIVE365/components/custom_card.dart';
import 'package:LIVE365/components/no_account_text.dart';
import 'package:LIVE365/components/socal_card.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/home/home_screen.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../SizeConfig.dart';
import 'sign_form.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool isSignIn = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final FacebookLogin facebookSignIn = new FacebookLogin();

  String name = '', image;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(10)),
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
                SizedBox(height: 40),
                NoAccountText(),
                SizedBox(height: 10),
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
                SizedBox(height: 5),
                isSignIn != false
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(height: 1),
                SizedBox(height: 10),
                isSignIn == false
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomCard(
                            borderRadius: BorderRadius.circular(20.0),
                            child: SocalCard(
                              icon: "assets/icons/google-icon.svg",
                              Name: "Join with Google",
                              press: () async {
                                await signInWithGoogle(context)
                                    .whenComplete(() async {
                                  var u = await FirebaseService.addUsers(
                                      firebaseAuth.currentUser);
                                  setState(() {
                                    isSignIn = false;
                                  });
                                  Navigator.pushNamed(
                                      context, HomeScreen.routeName);
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          CustomCard(
                              borderRadius: BorderRadius.circular(20.0),
                              color: Colors.blue.withOpacity(0.8),
                              child: SocalCard(
                                  icon: "assets/icons/facebook.svg",
                                  Name: "Join with Facebook",
                                  color: Colors.white,
                                  press: () async {
                                    loginWithFacebook(context)
                                        .whenComplete(() async {
                                      var u = await FirebaseService.addUsers(
                                          firebaseAuth.currentUser);
                                      setState(() {
                                        isSignIn = false;
                                      });
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreen()));
                                    });
                                  })),
                        ],
                      )
                    : SizedBox(height: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signInWithGoogle(context) async {
    setState(() {
      isSignIn = true;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Checking Your Account..")));
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("please Wait..")));
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    UserCredential userdata =
        await _firebaseAuth.signInWithCredential(credential);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("please Wait.."),
      duration: Duration(seconds: 2),
    ));
  }

  Future loginWithFacebook(context) async {
    setState(() {
      isSignIn = true;
    });
    final FacebookLoginResult result = await facebookSignIn.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=first_name,picture&access_token=${accessToken.token}');
        final profile = jsonDecode(graphResponse.body);
        setState(() {
          name = profile['first_name'];
          image = profile['picture']['data']['url'];
        });

        AuthCredential credential =
            FacebookAuthProvider.credential(accessToken.token);
        await _auth.signInWithCredential(credential);
        break;
      case FacebookLoginStatus.cancelledByUser:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Login cancelled by the user."),
          duration: Duration(seconds: 2),
        ));
        break;
      case FacebookLoginStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Something went wrong with the login process.\n'
              'Here\'s the error Facebook gave us: ${result.errorMessage}'),
          duration: Duration(seconds: 2),
        ));
        break;
    }
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$value"),
      duration: Duration(seconds: 2),
    ));
  }
}
