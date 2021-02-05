import 'package:LIVE365/components/indicators.dart';
import 'package:LIVE365/components/text_form_builder.dart';
import 'package:LIVE365/models/User.dart';
import 'package:LIVE365/utils/firebase.dart';
import 'package:LIVE365/utils/validation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

import 'edit_profile__model_view.dart';

class EditProfile extends StatefulWidget {
  final UserModel user;

  const EditProfile({this.user});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  UserModel user;
  bool valuesecond;

  String currentUid() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    valuesecond = widget.user.msgToAll;
  }

  @override
  Widget build(BuildContext context) {
    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);
    return ModalProgressHUD(
      progressIndicator: circularProgress(context),
      inAsyncCall: viewModel.loading,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Edit Profile"),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: GestureDetector(
                  onTap: () => viewModel.editProfile(context),
                  child: Text(
                    'SAVE',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.0,
                      color: Theme.of(context).accentColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            SizedBox(height: 20.0),
            Center(
              child: GestureDetector(
                onTap: () => viewModel.pickImage(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        offset: new Offset(0.0, 0.0),
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: viewModel.imgLink != null
                      ? Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: CircleAvatar(
                            radius: 65.0,
                            backgroundImage: NetworkImage(viewModel.imgLink),
                          ),
                        )
                      : viewModel.image == null
                          ? Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CircleAvatar(
                                radius: 65.0,
                                backgroundImage:
                                    NetworkImage(widget.user.photoUrl),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: CircleAvatar(
                                radius: 65.0,
                                backgroundImage: FileImage(viewModel.image),
                              ),
                            ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            buildForm(viewModel, context)
          ],
        ),
      ),
    );
  }

  buildForm(EditProfileViewModel viewModel, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Form(
        key: viewModel.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20.0),
            TextFormBuilder(
              enabled: !viewModel.loading,
              initialValue: widget.user.username,
              prefix: Feather.user,
              hintText: "Username",
              textInputAction: TextInputAction.next,
              validateFunction: Validations.validateName,
              onSaved: (String val) {
                viewModel.setUsername(val);
              },
            ),
            SizedBox(height: 10.0),
            Text(
              "Bio",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              maxLines: null,
              style: TextStyle(color: Colors.white),
              initialValue: widget.user.bio,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (String value) {
                if (value.length > 1000) {
                  return 'Bio must be short';
                }
                return null;
              },
              onSaved: (String val) {
                viewModel.setBio(val);
              },
              onChanged: (String val) {
                viewModel.setBio(val);
              },
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Checkbox(
                    value: this.valuesecond,
                    onChanged: (bool value) {
                      setState(() {
                        this.valuesecond = value;
                        viewModel.setMsgAll(value);
                      });
                    }),
                Text(
                  "Receive Message From All",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
