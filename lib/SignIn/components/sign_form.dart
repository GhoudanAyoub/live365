import 'package:LIVE365/components/custom_surfix_icon.dart';
import 'package:LIVE365/components/default_button.dart';
import 'package:LIVE365/components/form_error.dart';
import 'package:LIVE365/forgot_password/forgot_password_screen.dart';
import 'package:LIVE365/helper/keyboard.dart';
import 'package:LIVE365/services/auth_service.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import '../../theme.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _emailContoller = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool remember = false;
  final List<String> errors = [];

  var submitted = false;
  var buttonText = "Continue";

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

  TextFormField buildPasswordFormField() {
    return TextFormField(
      style: TextStyle(color: Colors.white),
      controller: _passwordController,
      obscureText: true,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        } else if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
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
        labelStyle: textTheme().bodyText2,
        labelText: "Password",
        hintStyle: textTheme().bodyText2,
        hintText: "Enter your password",
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
        hintStyle: textTheme().bodyText2,
        labelStyle: textTheme().bodyText2,
        labelText: "Email",
        hintText: "Enter your email",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor,
                onChanged: (value) {
                  setState(() {
                    remember = value;
                  });
                },
              ),
              Text("Remember me"),
              Spacer(),
              GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, ForgotPasswordScreen.routeName),
                child: Text(
                  "Forgot Password",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: buttonText,
            submitted: submitted,
            press: () async {
              AuthService auth = AuthService();
              if (_formKey.currentState.validate()) {
                submitted = true;
                KeyboardUtil.hideKeyboard(context);
                String success;
                try {
                  removeError(error: success);
                  success = await auth.loginUser(
                    email: _emailContoller.text,
                    password: _passwordController.text,
                  );
                  if (success == firebaseAuth.currentUser.uid) {
                    /* Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));*/
                    Navigator.pop(context);
                    Scaffold.of(context)
                        .showSnackBar(SnackBar(content: Text('Welcome Back')));
                  } else {
                    addError(error: success);
                    submitted = false;
                  }
                } catch (e) {
                  submitted = false;
                  addError(error: success);
                  showInSnackBar(
                      '${auth.handleFirebaseAuthError(e.toString())}');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$value"),
      duration: Duration(seconds: 2),
    ));
  }
}
