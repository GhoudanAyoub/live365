import 'dart:async';
import 'dart:io';

import 'package:LIVE365/SizeConfig.dart';
import 'package:LIVE365/Upload/composents/create_video.dart';
import 'package:LIVE365/Upload/composents/video_view_model.dart';
import 'package:LIVE365/camera/videoo.dart';
import 'package:LIVE365/components/IconBtnWithCounter.dart';
import 'package:LIVE365/components/default_button.dart';
import 'package:LIVE365/constants.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../camera/share_video.dart';
import '../theme.dart';

class AddVideoPage extends StatefulWidget {
  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  CameraController _cameraController;
  List<CameraDescription> cameras;
  int selectedCameraIndex;

  VideoViewModel viewModel;
  TextStyle _textStyle = TextStyle(color: Colors.white, fontSize: 11);
  Color color = Colors.white;
  int _pageSelectedIndex = 1;
  PageController controller = PageController();
  var currentPageValue = 0.0;
  bool _isRecording = false;
  String _filePath;
  int time = 15;
  int timetoshow = 15;
  bool _isVideo = true;
  bool submitted = false;
  @override
  void initState() {
    super.initState();
    time = 15;
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 0;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Camera Available"),
          duration: Duration(seconds: 2),
        ));
      }
    }).catchError((err) {
      print('Error :${err.code}Error message : ${err.message}');
    });

    controller.addListener(() {
      setState(() {
        currentPageValue = controller.page;
      });
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController.dispose();
    }
    _cameraController =
        CameraController(cameraDescription, ResolutionPreset.high);

    _cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (_cameraController.value.hasError) {
        print('Camera error ${_cameraController.value.errorDescription}');
      }
    });

    try {
      await _cameraController.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error:${e.code}\nError message : ${e.description}';
  }

  void _onPlay() => OpenFile.open(_filePath);

  Future<void> _onStop() async {
    await _cameraController.stopVideoRecording();
    setState(() => _isRecording = false);
  }

  Future<void> _onRecord() async {
    var directory = await getTemporaryDirectory();
    _filePath = directory.path + '/${DateTime.now()}.mp4';
    _cameraController.startVideoRecording(_filePath);
    setState(() => _isRecording = true);
  }

  void _onSwitchCamera() {
    selectedCameraIndex =
        selectedCameraIndex < cameras.length - 1 ? selectedCameraIndex + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIndex];
    _initCameraController(selectedCamera);
  }

  String get buttonText => !_isVideo
      ? "Take a photo"
      : "${_cameraController != null && _cameraController.value.isRecordingVideo ? "Stop recording" : "Record video"}";

  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _startVideoRecording() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_camera';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_getTimestamp()}.mp4';

    if (_cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await _cameraController.startVideoRecording(filePath);
      setState(() {
        _filePath = filePath;
      });
    } on CameraException catch (e) {
      print(e);
    }
    new Future.delayed(Duration(seconds: time), () {
      _stopVideoRecording(context);
    });
  }

  Future<void> _stopVideoRecording(BuildContext context) async {
    if (!_cameraController.value.isRecordingVideo) {
      return null;
    }

    try {
      await _cameraController.stopVideoRecording();
      setState(() {
        viewModel.setMediaUrl(File(_filePath));
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShareVideo(
                file: _filePath,
                viewModel: viewModel,
              ),
            ));
      });
    } on CameraException catch (e) {
      print(e);
    }
  }

  void _showBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: GBottomNav,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext bc) {
          return FractionallySizedBox(
            heightFactor: 2.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(30.0),
                  ),
                  child: Stack(
                    children: [
                      Center(
                          child: Container(
                        height: SizeConfig.screenHeight,
                        width: SizeConfig.screenWidth,
                        child: Video(File(_filePath)),
                      )),
                      Positioned(
                        bottom: 100,
                        right: 10,
                        child: IconBtnWithCounter(
                          svgSrc: 'assets/icons/arrow_right.svg',
                          press: () {
                            Navigator.pop(context);
                            _showSaveSheet(context);
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  void _showSaveSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: GBottomNav,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext bc) {
          return FractionallySizedBox(
            heightFactor: 2.5,
            child: Column(
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
                        initialValue: viewModel.description,
                        keyboardType: TextInputType.name,
                        onChanged: (val) => viewModel.setVideoTitle(val),
                        decoration: InputDecoration(
                          labelStyle: textTheme().bodyText2,
                          hintStyle: textTheme().bodyText2,
                          labelText: "videoTitle",
                          hintText: "Enter your videoTitle",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        initialValue: viewModel.description,
                        keyboardType: TextInputType.name,
                        onChanged: (val) => viewModel.setSongName(val),
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
                        initialValue: viewModel.description,
                        keyboardType: TextInputType.name,
                        onChanged: (val) => viewModel.setDescription(val),
                        decoration: InputDecoration(
                          labelStyle: textTheme().bodyText2,
                          hintStyle: textTheme().bodyText2,
                          labelText: "Description",
                          hintText: "Enter your Description",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        initialValue: viewModel.tags,
                        keyboardType: TextInputType.name,
                        onChanged: (val) => viewModel.setTags(val),
                        decoration: InputDecoration(
                          labelStyle: textTheme().bodyText2,
                          hintStyle: textTheme().bodyText2,
                          labelText: "Hashtags",
                          hintText: "Enter your Hashtags",
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                      ),
                      SizedBox(height: 20.0),
                      DefaultButton(
                        text: "Upload",
                        press: () async {
                          await viewModel.uploadVideos();
                          Navigator.pop(context);
                          viewModel.resetVedio();
                          submitted = true;
                        },
                        submitted: submitted,
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<VideoViewModel>(context);
    return ResponsiveBuilder(
      builder: (BuildContext context, SizingInformation sizingInformation) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              _cameraController.value.isInitialized
                  ? Container(
                      child: CameraPreview(_cameraController),
                    )
                  : Container(),
              _topRowWidget(context),
              _bottomRowWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _topRowWidget(context) {
    return Positioned(
      top: 30,
      left: 10,
      right: 20,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _cameraController.dispose();
                },
                child: Icon(
                  Icons.close,
                  color: color,
                )),
            Container(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.music_note,
                    color: color,
                  ),
                  Text(
                    "Sounds",
                    style: _textStyle,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton.icon(
                  onPressed: _onSwitchCamera,
                  icon: Icon(
                    CupertinoIcons.switch_camera,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: Text(
                    "flip",
                    style: _textStyle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomRowWidget() {
    return Positioned(
      bottom: 20,
      left: 10,
      right: 10,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (time == 15)
                          time = 30;
                        else
                          time = 15;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.purple.withOpacity(.4),
                          Colors.blue.withOpacity(.4)
                        ]),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Image.asset("assets/images/effects.png"),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${time.toString()} s",
                    style: _textStyle,
                  )
                ],
              ),
            ),
            Column(
              children: [
                Center(
                    child: IconButton(
                  icon: Icon(
                    Icons.radio_button_checked,
                    size: 40,
                    color: _cameraController.value.isRecordingVideo
                        ? Colors.red
                        : Colors.white,
                  ),
                  onPressed: () {
                    if (_cameraController.value.isRecordingVideo) {
                      _stopVideoRecording(context);
                    } else {
                      _startVideoRecording();
                    }
                  },
                )),
              ],
            ),
            Container(
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateVideo()),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Image.asset("assets/images/gallery.png"),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "Upload",
                    style: _textStyle,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _cameraController.value.isRecordingVideo
        ? _stopVideoRecording(context)
        : null;
    super.dispose();
  }
}
