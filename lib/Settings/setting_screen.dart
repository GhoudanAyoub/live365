import 'package:LIVE365/SignIn/sign_in_screen.dart';
import 'package:LIVE365/constants.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:LIVE365/helper/PaypalPayment.dart';
import 'package:LIVE365/profile/components/edit_profile.dart';
import 'package:LIVE365/profile/components/profile_menu.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  final users;

  const SettingScreen({Key key, this.users}) : super(key: key);
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future ref = paymentRef.doc(firebaseAuth.currentUser.uid).get();
    print(ref);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              ProfileMenu(
                text: "Edit Profile",
                icon: "assets/icons/User Icon.svg",
                press: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfile(
                        user: widget.users,
                      ),
                    ),
                  )
                },
              ),
              ProfileMenu(
                text: "Contact Us",
                icon: "assets/icons/Bell.svg",
                press: _launchURL4,
              ),
              ProfileMenu(
                text: "Rate Us",
                icon: "assets/icons/Question mark.svg",
                press: _launchURL3,
              ),
              ProfileMenu(
                text: "Buy Coins",
                icon: "assets/icons/Question mark.svg",
                press: () {
                  chooseUpload(context);
                },
              ),
              ProfileMenu(
                text: "Terms and Conditions",
                icon: "assets/icons/Question mark.svg",
                press: _launchURL,
              ),
              ProfileMenu(
                text: "Privacy Policy for LIVE365",
                icon: "assets/icons/Question mark.svg",
                press: _launchURL2,
              ),
              ProfileMenu(
                text: "Log Out",
                icon: "assets/icons/Log out.svg",
                press: () async {
                  logOut(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  logOut(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            backgroundColor: GBottomNav,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  FirebaseService().signOut();
                  Navigator.pushNamed(context, SignInScreen.routeName);
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
  }

  _launchURL() async {
    const url = 'http://www.live365.sg/Terms.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL2() async {
    const url = 'http://www.live365.sg/Privacy.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL3() async {
    const url =
        'https://play.google.com/store/apps/details?id=com.ghoudan.live365';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURL4() async {
    const url = 'http://www.live365.sg/contact%20us.html';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  chooseUpload(BuildContext context) {
    return showModalBottomSheet(
      backgroundColor: GBottomNav,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 1.2,
          child: Container(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 2 * MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.height,
              decoration: new BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 2 * MediaQuery.of(context).size.height / 3 - 50,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4.0, 0, 0, 0),
                          child: MaterialButton(
                            minWidth: 0,
                            onPressed: () {},
                            child: Icon(
                              Icons.lock_clock,
                              color: Colors.white,
                              size: 20.0,
                            ),
                            shape: CircleBorder(),
                            elevation: 2.0,
                            color: Colors.red,
                            padding: const EdgeInsets.all(12.0),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Text(
                            'Purchase Coins',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                        FutureBuilder<DocumentSnapshot>(
                          future: paymentRef
                              .doc(firebaseAuth.currentUser.uid)
                              .get(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return Text("Something went wrong");
                            }

                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              Map<String, dynamic> data = snapshot.data.data();
                              if (data != null)
                                return Text("Full Name: ${data.toString()} ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white));
                            }

                            return Text("Balance : 0",
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white));
                          },
                        ),
                        Divider(
                          color: Colors.grey[800],
                          thickness: 0.5,
                          height: 0,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 150, 0, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: clipsWidget(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget clipsWidget() {
    return Container(
      height: 250,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      child: Row(
        children: [
          Column(
            children: [
              roundedContainer(Colors.redAccent, "assets/gift/Bike.png", 200),
              SizedBox(
                height: 15,
              ),
              roundedContainer(
                  Colors.greenAccent, "assets/gift/balloon.png", 25),
            ],
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            children: [
              roundedContainer(
                  Colors.orangeAccent, "assets/gift/Camera.png", 100),
              SizedBox(height: 15),
              roundedContainer(Colors.purpleAccent, "assets/gift/Car.png", 300),
            ],
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            children: [
              roundedContainer(Colors.blue, "assets/gift/Drinks.png", 15),
              SizedBox(
                height: 15,
              ),
              roundedContainer(
                  Colors.lightGreenAccent, "assets/gift/Flower.png", 10),
            ],
          ),
          SizedBox(
            width: 15,
          ),
          Column(
            children: [
              roundedContainer(Colors.white, "assets/gift/Glasses.png", 70),
              SizedBox(
                height: 15,
              ),
              roundedContainer(
                  Colors.deepOrangeAccent, "assets/gift/Ice Cream.png", 25),
            ],
          ),
          SizedBox(width: 15),
          Column(
            children: [
              roundedContainer(Colors.pink, "assets/gift/Love.png", 500),
              SizedBox(
                height: 15,
              ),
              roundedContainer(Colors.brown, "assets/gift/Ring.png", 1000),
            ],
          ),
        ],
      ),
    );
  }

  Widget roundedContainer(Color color, assetName, price) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            print("${(price * 100) / 1000}\$");
            checkPacket((price * 100) / 1000);
          },
          child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: Hero(
                tag: "image-",
                child: Image(
                  image: AssetImage(assetName),
                  height: 40,
                ),
              )),
        ),
        Text(
          "${price.toString()} C/${(price * 100) / 1000}\$",
          style: TextStyle(color: Colors.white),
        )
      ],
    );
  }

  void checkPacket(price) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) =>
            PaypalPayment('LIVE365 ${price.toString()} Coin', price.toString()),
      ),
    ); // Item Name and Item Price
  }
}
