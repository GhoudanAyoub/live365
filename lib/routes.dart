import 'package:LIVE365/Settings/setting_screen.dart';
import 'package:flutter/material.dart';

import 'SignIn/sign_in_screen.dart';
import 'SignUp/sign_up_screen.dart';
import 'SplashScreen/splash_screen.dart';
import 'forgot_password/forgot_password_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  SettingScreen.routeName: (context) => SettingScreen()
  /*LoginSuccessScreen.routeName: (context) => LoginSuccessScreen(),
  CompleteProfileScreen.routeName: (context) => CompleteProfileScreen(),
  OtpScreen.routeName: (context) => OtpScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  DetailsScreen.routeName: (context) => DetailsScreen(),
  CartScreen.routeName: (context) => CartScreen(),
  ProfileScreen.routeName: (context) => ProfileScreen(),*/
};
