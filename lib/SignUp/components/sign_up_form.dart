import 'package:LIVE365/components/custom_surfix_icon.dart';
import 'package:LIVE365/components/default_button.dart';
import 'package:LIVE365/components/form_error.dart';
import 'package:LIVE365/home/home_screen.dart';
import 'package:LIVE365/services/auth_service.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import '../../theme.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  var submitted = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _namentoller = TextEditingController();
  TextEditingController _countryContoller = TextEditingController();
  TextEditingController _emailContoller = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String email;
  String password;
  String conform_password;
  bool remember = false;
  AuthService authService = AuthService();
  final List<String> errors = [];

  void addError({String error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
        submitted = false;
      });
  }

  void removeError({String error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
              height: 120,
              alignment: Alignment.center,
              child: Card(
                  child: Padding(
                padding: EdgeInsets.all(5),
                child: SizedBox(
                  width: double.infinity,
                  child: CountryListPick(
                    theme: CountryTheme(
                      isShowFlag: true,
                      isShowTitle: true,
                      isShowCode: false,
                      isDownIcon: true,
                    ),
                    onChanged: (CountryCode code) {
                      print(code.name); //get the country name eg: Antarctica
                      setState(() {
                        _countryContoller.text = code.name;
                      });
                    },
                  ),
                ),
              ))),
          buildENameFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildConformPassFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(40)),
          DefaultButton(
            text: "Continue",
            submitted: submitted,
            press: () async {
              try {
                if (_formKey.currentState.validate()) {
                  submitted = true;
                  bool success = await authService.createUser(
                    name: _namentoller.text,
                    email: _emailContoller.text,
                    password: _passwordController.text,
                    country: _countryContoller.text,
                  );
                  print(success);
                  if (success) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Congratulation Your Account Created')));
                  }
                }
              } catch (e) {
                print(e);
                showInSnackBar(
                    '${authService.handleFirebaseAuthError(e.toString())}');
              }
            },
          ),
        ],
      ),
    );
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  void emailExists() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: Colors.grey[800],
              ),
              height: 190,
              child: Column(
                children: [
                  Container(
                    height: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            'This Email is on Another Account',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 30, right: 25, top: 15),
                          child: Text(
                            "You can log into the account associated with that email.",
                            style: TextStyle(color: Colors.white60),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 0,
                    height: 0,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.popUntil(
                            context, ModalRoute.withName('/HomeScreen'));
                      },
                      child: Text(
                        'Log in to Existing Account',
                        style: TextStyle(color: Colors.lightBlue[400]),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  TextFormField buildConformPassFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      obscureText: true,
      onSaved: (newValue) => conform_password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.isNotEmpty && password == conform_password) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        hintText: "Re-enter your password",
        labelStyle: textTheme().bodyText2,
        hintStyle: textTheme().bodyText2,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _passwordController,
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: "Password",
        hintText: "Enter your password",
        labelStyle: textTheme().bodyText2,
        hintStyle: textTheme().bodyText2,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildEmailFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _emailContoller,
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => email = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kEmailNullError);
        } else if (emailValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidEmailError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kEmailNullError);
          return "";
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidEmailError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: textTheme().bodyText2,
        hintStyle: textTheme().bodyText2,
        labelText: "Email",
        hintText: "Enter your email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  TextFormField buildENameFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _namentoller,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNameNullError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kNameNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: textTheme().bodyText2,
        hintStyle: textTheme().bodyText2,
        labelText: "Name",
        hintText: "Enter your name",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildECountryFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _countryContoller,
      keyboardType: TextInputType.name,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kCountryNullError);
        }
        return null;
      },
      validator: (value) {
        if (value.isEmpty) {
          addError(error: kCountryNullError);
          return "";
        }
        return null;
      },
      decoration: InputDecoration(
        labelStyle: textTheme().bodyText2,
        hintStyle: textTheme().bodyText2,
        labelText: "Country",
        hintText: "Enter your Country",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}
