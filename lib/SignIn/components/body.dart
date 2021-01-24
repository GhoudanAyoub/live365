import 'package:flutter/material.dart';
import 'package:live365/components/no_account_text.dart';
import 'package:live365/components/socal_card.dart';
import 'package:live365/firebaseService/FirebaseService.dart';

import '../../SizeConfig.dart';
import 'sign_form.dart';

class Body extends StatelessWidget {
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
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                Text(
                  "Welcome Back",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocalCard(
                      icon: "assets/icons/google-icon.svg",
                      press: () async {
                        dynamic result =
                            await FirebaseService.signInWithGoogle(context);

                        if (result != null) {
                          // Navigator.pushNamed(context, HomeScreen.routeName);
                        }
                      },
                    ),
                    SocalCard(
                      icon: "assets/icons/facebook-2.svg",
                      press: () {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("Coming Soon")));
                      },
                    ),
                    SocalCard(
                      icon: "assets/icons/twitter.svg",
                      press: () {
                        Scaffold.of(context).showSnackBar(
                            SnackBar(content: Text("Coming Soon")));
                      },
                    ),
                  ],
                ),
                SizedBox(height: getProportionateScreenHeight(20)),
                NoAccountText(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}