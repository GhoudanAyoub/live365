import 'package:LIVE365/utils/firebase.dart';
import 'package:flutter/material.dart';

import 'components/body.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Body(profileId: firebaseAuth.currentUser.uid);
  }
}
