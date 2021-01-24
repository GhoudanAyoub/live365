import 'package:flutter/material.dart';

import 'components/body.dart';

class ProfileScreen extends StatelessWidget {
  List ImageList = [
    {
      "image":
          "https://p16-tiktokcdn-com.akamaized.net/aweme/720x720/tiktok-obj/1663771856684033.jpeg",
    },
    {
      "image":
          "https://p16-tiktokcdn-com.akamaized.net/aweme/720x720/tiktok-obj/1663771856684033.jpeg",
    },
    {
      "image":
          "https://p16-tiktokcdn-com.akamaized.net/aweme/720x720/tiktok-obj/ba13e655825553a46b1913705e3a8617.jpeg",
    },
    {
      "image":
          "https://p16-tiktokcdn-com.akamaized.net/aweme/720x720/tiktok-obj/1664576339652610.jpeg",
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
