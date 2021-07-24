import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  @override
  _State createState() => _State();
}

class _State extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    FirebaseService.changeStatus("Online");
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(body: Body()));
  }

  @override
  void dispose() async {
    FirebaseService.changeStatus("Away");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    FirebaseService.changeStatus("Away");
  }
}
