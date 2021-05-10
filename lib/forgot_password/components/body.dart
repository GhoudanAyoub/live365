import 'package:LIVE365/components/custom_surfix_icon.dart';
import 'package:LIVE365/components/default_button.dart';
import 'package:LIVE365/components/form_error.dart';
import 'package:LIVE365/firebaseService/FirebaseService.dart';
import 'package:flutter/material.dart';

import '../../SizeConfig.dart';
import '../../constants.dart';
import '../../theme.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: Column(
            children: [
              SizedBox(height: 60),
              Text(
                "Forgot Password",
                style: TextStyle(
                  fontSize: getProportionateScreenWidth(28),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Please enter your email and we will send \nyou a link to return to your account",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 60),
              ForgotPassForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPassForm extends StatefulWidget {
  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _emailContoller = TextEditingController();
  List<String> errors = [];
  String email;
  var submitted = false;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailContoller,
            style: TextStyle(color: Colors.white),
            keyboardType: TextInputType.emailAddress,
            onSaved: (newValue) => email = newValue,
            onChanged: (value) {
              if (value.isNotEmpty && errors.contains(kEmailNullError)) {
                setState(() {
                  errors.remove(kEmailNullError);
                });
              } else if (emailValidatorRegExp.hasMatch(value) &&
                  errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.remove(kInvalidEmailError);
                });
              }
              return null;
            },
            validator: (value) {
              if (value.isEmpty && !errors.contains(kEmailNullError)) {
                setState(() {
                  errors.add(kEmailNullError);
                });
              } else if (!emailValidatorRegExp.hasMatch(value) &&
                  !errors.contains(kInvalidEmailError)) {
                setState(() {
                  errors.add(kInvalidEmailError);
                });
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: "Email",
              hintText: "Enter your email",
              labelStyle: textTheme().bodyText2,
              hintStyle: textTheme().bodyText2,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Mail.svg"),
            ),
          ),
          SizedBox(height: 10),
          FormError(errors: errors),
          SizedBox(height: 20),
          DefaultButton(
            text: "Continue",
            submitted: submitted,
            press: () {
              if (_formKey.currentState.validate()) {
                submitted = true;
                final auth = FirebaseService();
                auth.sendPasswordResetEmail(_emailContoller.text);
                Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                        'A password reset link has been sent to ${_emailContoller.text}')));
              }
            },
          ),
        ],
      ),
    );
  }
}
