import 'package:flutter/material.dart';

class ProfilePic extends StatelessWidget {
  const ProfilePic({Key key, this.image}) : super(key: key);
  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.antiAlias,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage: NetworkImage(image),
            backgroundColor: Colors.transparent,
          )
        ],
      ),
    );
  }
}
