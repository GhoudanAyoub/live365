import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'SizeConfig.dart';

final String CurrentClient = FirebaseAuth.instance.currentUser.uid;

const appBgColor = Color(0xFF000000);
const primary = Color(0xFFFC2D55);
const secondary = Color(0xFF19D5F1);
const white = Color(0xFFFFFFFF);
const black = Color(0xFF000000);
const orange = Color(0xFFFF7643);
const deepOrange = Colors.deepOrange;
const online = Color(0xFF66BB6A);
const red = Colors.red;
const blue_story = Colors.blueAccent;
const grey_toWhite = Color(0xFFe9eaec);
const GTextColorWhite = Colors.white;
const GBottomNav = Color.fromARGB(225, 33, 37, 49);
const kPrimaryColor = Color(0xFFFF4444);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFFA53E), Color(0xFFFF7643)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Colors.grey;

const kAnimationDuration = Duration(milliseconds: 200);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.white,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp emailValidatorRegExp =
    RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
const String kNameNullError = "Please Enter your Name";
const String kEmailNullError = "Please Enter your email";
const String kInvalidEmailError = "Please Enter Valid Email";
const String kPassNullError = "Please Enter your password";
const String kShortPassError = "Password is too short";
const String kMatchPassError = "Passwords don't match";
const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";
const String kAddressNullError = "Please Enter your address";
const String messagesListClass = "messagesList";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}

//Function from stuck overflow
getMessageType(isMe, messageType) {
  if (isMe) {
    // start message
    if (messageType == 1) {
      return BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(5),
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30));
    }
    // middle message
    else if (messageType == 2) {
      return BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(5),
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30));
    }
    // end message
    else if (messageType == 3) {
      return BorderRadius.only(
          topRight: Radius.circular(5),
          bottomRight: Radius.circular(30),
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(30));
    }
    // standalone message
    else {
      return BorderRadius.all(Radius.circular(30));
    }
  }
  // for sender bubble
  else {
    // start message
    if (messageType == 1) {
      return BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomLeft: Radius.circular(5),
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30));
    }
    // middle message
    else if (messageType == 2) {
      return BorderRadius.only(
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(5),
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30));
    }
    // end message
    else if (messageType == 3) {
      return BorderRadius.only(
          topLeft: Radius.circular(5),
          bottomLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30));
    }
    // standalone message
    else {
      return BorderRadius.all(Radius.circular(30));
    }
  }
}
