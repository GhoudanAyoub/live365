import 'package:LIVE365/SignUp/sign_up_screen.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Don’t have an account? ",
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(
          height: 15,
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, SignUpScreen.routeName),
          child: Text(
            "Sign Up",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
