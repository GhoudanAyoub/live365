import 'package:LIVE365/home/home_screen.dart';
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
  HomeScreen.routeName: (context) => HomeScreen(),
};
