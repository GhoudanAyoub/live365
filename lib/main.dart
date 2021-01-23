import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:live365/SizeConfig.dart';
import 'package:live365/routes.dart';
import 'package:live365/theme.dart';

import 'SplashScreen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context)  {
    SizeConfig().init(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme(),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}