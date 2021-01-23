import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:live365/models/users.dart';


class FirebaseService{

static final CollectionReference userCollection = FirebaseFirestore.instance
    .collection('Live365Users');
static UserCredential userCredential;
static final String Client_displayName= FirebaseAuth.instance.currentUser.displayName;


// Auth System
 static Future signInWithGoogle(BuildContext context) async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User user = userCredential.user;
    SaveNewUserData(users(firstName: user.displayName, lastName: null, phoneNumber: user.phoneNumber, address: null),context);
    assert(FirebaseAuth.instance.currentUser.uid == user.uid);

    return user;
 }

static Future create(String email1,String pass,BuildContext context) async {
  try {
    userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email1,
        password: pass
    ).catchError((onError)=>Scaffold.of(context).showSnackBar(SnackBar(content: Text("$onError"))));

    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }
}

static Future sign(String e,String pass,BuildContext context) async {
  try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: e,
        password: pass
    ).catchError((onError)=>Scaffold.of(context).showSnackBar(SnackBar(content: Text("You Don't Have Account "))));
      return userCredential.user;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
  }
}

static checkClientData(BuildContext context) async {
  await userCollection.doc(Client_displayName.toLowerCase())
  .get()
      .catchError((onError)=>Scaffold.of(context).showSnackBar(SnackBar(content: Text("$onError"))))
      .then((snapshot) => {
        if(snapshot.exists){}
          //Navigator.pushNamed(context, LoginSuccessScreen.routeName)
        else{}
          //Navigator.pushNamed(context, CompleteProfileScreen.routeName)
      });

}

static Future<void> SaveNewUserData(users user,BuildContext context) async{
  return await userCollection.doc(Client_displayName.toLowerCase())
  .set({
    "firstName":user.firstName,
    "lastName":user.lastName,
    "phoneNumber":user.phoneNumber,
    "address":user.address
    }).catchError((onError)=>Scaffold.of(context).showSnackBar(SnackBar(content: Text("$onError"))))
      .then((value) => {}/*Navigator.pushNamed(context, OtpScreen.routeName)*/);
}

Future getData() async {
  List userList = [];
  return await userCollection.get().then((value) => {
    value.docs.forEach((element) { userList.add(element.data);})
  });
}

}