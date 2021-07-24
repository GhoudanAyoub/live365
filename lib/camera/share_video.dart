import 'dart:io';

import 'package:LIVE365/Upload/composents/video_view_model.dart';
import 'package:LIVE365/camera/videoo.dart';
import 'package:LIVE365/components/default_button.dart';
import 'package:flutter/material.dart';

import '../SizeConfig.dart';
import '../theme.dart';

class ShareVideo extends StatefulWidget {
  final String file;
  final VideoViewModel viewModel;
  const ShareVideo({Key key, this.file, this.viewModel}) : super(key: key);
  @override
  _ShareVideoState createState() => _ShareVideoState();
}

class _ShareVideoState extends State<ShareVideo> {
  bool submitted = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
        child: Column(
          children: [
            Container(
              height: 300,
              width: SizeConfig.screenWidth,
              child: Video(File(widget.file)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        initialValue: widget.viewModel.description,
                        keyboardType: TextInputType.name,
                        onChanged: (val) => widget.viewModel.setVideoTitle(val),
                        decoration: InputDecoration(
                          labelStyle: textTheme().bodyText2,
                          hintStyle: textTheme().bodyText2,
                          labelText: "videoTitle",
                          hintText: "Enter your videoTitle",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        initialValue: widget.viewModel.description,
                        keyboardType: TextInputType.name,
                        onChanged: (val) => widget.viewModel.setSongName(val),
                        decoration: InputDecoration(
                          labelStyle: textTheme().bodyText2,
                          hintStyle: textTheme().bodyText2,
                          labelText: "songName",
                          hintText: "Enter your songName",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        initialValue: widget.viewModel.description,
                        keyboardType: TextInputType.name,
                        onChanged: (val) =>
                            widget.viewModel.setDescription(val),
                        decoration: InputDecoration(
                          labelStyle: textTheme().bodyText2,
                          hintStyle: textTheme().bodyText2,
                          labelText: "Description",
                          hintText: "Enter your Description",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        initialValue: widget.viewModel.tags,
                        keyboardType: TextInputType.name,
                        onChanged: (val) => widget.viewModel.setTags(val),
                        decoration: InputDecoration(
                          labelStyle: textTheme().bodyText2,
                          hintStyle: textTheme().bodyText2,
                          labelText: "Hashtags",
                          hintText: "Enter your Hashtags",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      DefaultButton(
                        text: "Upload",
                        press: () async {
                          await widget.viewModel.uploadVideos();
                          Navigator.pop(context);
                          widget.viewModel.resetVedio();
                          submitted = true;
                        },
                        submitted: submitted,
                      )
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ));
  }
}
