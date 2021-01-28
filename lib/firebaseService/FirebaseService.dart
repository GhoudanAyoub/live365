import 'package:LIVE365/models/message.dart';
import 'package:LIVE365/models/message_list.dart';
import 'package:LIVE365/models/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils.dart';

class FirebaseService {
  static final liveCollection = 'liveuser';
  static final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('LIVE365Users');
  static String Client_displayName = FirebaseAuth.instance.currentUser.email;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final _fireStore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<String> get onAuthStateChanged => _firebaseAuth.authStateChanges().map(
        (User user) => user?.uid,
      );

  //USER LIVE
  static void createLiveUser({name, id, time, image}) async {
    final snapShot =
        await _fireStore.collection(liveCollection).doc(name).get();
    if (snapShot.exists) {
      await _fireStore
          .collection(liveCollection)
          .doc(name)
          .update({'name': name, 'channel': id, 'time': time, 'image': image});
    } else {
      await _fireStore
          .collection(liveCollection)
          .doc(name)
          .set({'name': name, 'channel': id, 'time': time, 'image': image});
    }
  }

  static void deleteUser({username}) async {
    await _fireStore.collection('liveuser').doc(username).delete();
  }

  // USER DATA
  static Future addUsers(User user) async {
    FirebaseFirestore.instance.collection("Users").doc(user.displayName).set({
      'id': user.uid,
      'name': user.displayName,
      'email': user.email,
      'img': FirebaseAuth.instance.currentUser.photoURL,
      'like': 0,
      'following': 0,
      'followers': 0,
      'quot': '',
      'subName': ''
    });
  }

  static Stream<List<users>> GetUserData() => FirebaseFirestore.instance
      .collection("Users")
      .orderBy("followers", descending: true)
      .snapshots()
      .transform(Utils.transformer(users.fromJson));

  //Friend data

  static Future addFriendUsers(users user, String img) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser.displayName)
        .collection('Friend')
        .doc()
        .set({
      'id': user.id,
      'name': user.name,
      'img': img,
      'online': true,
      'live': false,
      'message': "",
      'created_at': DateTime.now()
    });
  }

  static Stream<List<MessageList>> getFriends() => FirebaseFirestore.instance
      .collection("Users")
      .doc(FirebaseAuth.instance.currentUser.displayName)
      .collection('Friend')
      .orderBy(MessageListField.lastMessageTime, descending: true)
      .snapshots()
      .transform(Utils.transformer(MessageList.fromJson));

  // MESSAGE DATA
  static Future addRandomUsers(users user, String img) async {
    await FirebaseFirestore.instance
        .collection("Message")
        .doc(FirebaseAuth.instance.currentUser.displayName)
        .collection('users')
        .doc()
        .set({
      'id': user.id,
      'name': user.name,
      'img': img,
      'online': true,
      'live': false,
      'message': "",
      'created_at': DateTime.now()
    });
  }

  static Stream<List<MessageList>> getUsers() => FirebaseFirestore.instance
      .collection("Message")
      .doc(FirebaseAuth.instance.currentUser.displayName)
      .collection('users')
      .orderBy(MessageListField.lastMessageTime, descending: true)
      .snapshots()
      .transform(Utils.transformer(MessageList.fromJson));

  static Future uploadMessage(
      String sender, final String receiver, String message) async {
    final refMessages = FirebaseFirestore.instance.collection('chats');

    final newMessage = messages(
      sender: sender,
      receiver: receiver,
      urlAvatar: FirebaseAuth.instance.currentUser.photoURL,
      username: FirebaseAuth.instance.currentUser.displayName,
      message: message,
      createdAt: DateTime.now(),
    );
    await refMessages.add(newMessage.toJson());
  }

  static Stream<List<messages>> getMessages() => FirebaseFirestore.instance
      .collection('chats')
      .orderBy(MessageField.createdAt, descending: true)
      .snapshots()
      .transform(Utils.transformer(messages.fromJson));

  // GET UID
  String getCurrentUID() {
    return _firebaseAuth.currentUser.uid;
  }

  // GET CURRENT USER
  Future getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  // GET CURRENT USER name
  String getCurrentUserName() {
    return _firebaseAuth.currentUser.displayName;
  }

  getProfileImage() {
    if (_firebaseAuth.currentUser.photoURL != null) {
      return _firebaseAuth.currentUser.photoURL;
    } else {
      return "https://images.unsplash.com/photo-1571741140674-8949ca7df2a7?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60";
    }
  }

  // Email & Password Sign Up
  Future createUserWithEmailAndPassword(
      String email, String password, String name) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    var userNameExists = await checkUsername(username: name);
    if (!userNameExists) {
      return -1;
    }
    // Update the username
    await updateUserName(name, authResult.user);
    addUsers(authResult.user);
    return 1;
  }

  static Future<bool> checkUsername({username}) async {
    final snapShot = await _fireStore.collection("users").doc(username).get();
    if (snapShot.exists) {
      return false;
    }
    return true;
  }

  Future updateUserName(String name, User currentUser) async {
    await currentUser.updateProfile(displayName: name);
    addUsers(currentUser);
    await currentUser.reload();
  }

  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user
        .uid;
  }

  // Sign Out
  signOut() async {
    return await _firebaseAuth.signOut();
  }

  // Reset Password
  Future sendPasswordResetEmail(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future convertUserWithEmail(
      String email, String password, String name) async {
    final currentUser = _firebaseAuth.currentUser;

    addUsers(currentUser);
    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await currentUser.linkWithCredential(credential);
    await updateUserName(name, currentUser);
  }

  Future convertWithGoogle() async {
    final currentUser = _firebaseAuth.currentUser;
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    await currentUser.linkWithCredential(credential);
    addUsers(currentUser);
    await updateUserName(_googleSignIn.currentUser.displayName, currentUser);
  }

  // GOOGLE
  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount account = await _googleSignIn.signIn();
    final GoogleSignInAuthentication _googleAuth = await account.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: _googleAuth.idToken,
      accessToken: _googleAuth.accessToken,
    );
    addUsers((await _firebaseAuth.signInWithCredential(credential)).user);
    return (await _firebaseAuth.signInWithCredential(credential)).user.uid;
  }

  // APPLE
  /*
  Future signInWithApple() async {
    final AuthorizationResult result = await AppleSignIn.performRequests([
      AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
    ]);

    switch (result.status) {
      case AuthorizationStatus.authorized:
        final AppleIdCredential _auth = result.credential;
        final OAuthProvider oAuthProvider =
        new OAuthProvider("apple.com");

        final AuthCredential credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(_auth.identityToken),
          accessToken: String.fromCharCodes(_auth.authorizationCode),
        );

        await _firebaseAuth.signInWithCredential(credential);

        // update the user information
        if (_auth.fullName != null) {
          await _firebaseAuth.currentUser.updateProfile(displayName: "${_auth.fullName.givenName} ${_auth.fullName.familyName}");
        }

        break;

      case AuthorizationStatus.error:
        print("Sign In Failed ${result.error.localizedDescription}");
        break;

      case AuthorizationStatus.cancelled:
        print("User Cancled");
        break;
    }
  }*/

  Future createUserWithPhone(String phone, BuildContext context) async {
    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: Duration(seconds: 0),
        verificationCompleted: (AuthCredential authCredential) {
          _firebaseAuth
              .signInWithCredential(authCredential)
              .then((UserCredential result) {
            Navigator.of(context).pop(); // to pop the dialog box
            Navigator.of(context).pushReplacementNamed('/home');
          }).catchError((e) {
            return "error";
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          return "error";
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          final _codeController = TextEditingController();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Text("Enter Verification Code From Text Message"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[TextField(controller: _codeController)],
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text("submit"),
                  textColor: Colors.white,
                  color: Colors.green,
                  onPressed: () {
                    var _credential = PhoneAuthProvider.credential(
                        verificationId: verificationId,
                        smsCode: _codeController.text.trim());
                    _firebaseAuth
                        .signInWithCredential(_credential)
                        .then((UserCredential result) {
                      Navigator.of(context).pop(); // to pop the dialog box
                      Navigator.of(context).pushReplacementNamed('/home');
                    }).catchError((e) {
                      return "error";
                    });
                  },
                )
              ],
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
        });
  }
}
