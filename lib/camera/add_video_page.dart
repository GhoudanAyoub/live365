import 'dart:async';

import 'package:LIVE365/models/FakeRepository.dart';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AddVideoPage extends StatefulWidget {
  @override
  _AddVideoPageState createState() => _AddVideoPageState();
}

class _AddVideoPageState extends State<AddVideoPage> {
  CameraController _cameraController;
  List<CameraDescription> cameras;
  int selectedCameraIndex;

  TextStyle _textStyle = TextStyle(color: Colors.white, fontSize: 11);
  Color color = Colors.white;
  int _pageSelectedIndex = 1;
  PageController controller = PageController();
  var currentPageValue = 0.0;
  bool _isRecording = false;
  String _filePath;
  int time;
  @override
  void initState() {
    super.initState();
    time = 15;
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIndex = 1;
        });
        _initCameraController(cameras[selectedCameraIndex]).then((void v) {});
      } else {
        print('No camera available');
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
    print(errorText);
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

/*
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await controller.dispose();
    }
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: enableAudio,
    );

// If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }
*/
  @override
  Widget build(BuildContext context) {
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
              _bottomWidget(),
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
      bottom: 60,
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
                  Container(
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
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                    "Effects",
                    style: _textStyle,
                  )
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.radio_button_checked,
                    size: 40,
                    color: Colors.red,
                  ),
                  onPressed: _isRecording ? null : _onRecord,
                ),
                Center(
                  child: Text(time.toString()),
                )
              ],
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Image.asset("assets/images/gallery.png"),
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

  Widget _bottomWidget() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
          height: 50,
          width: 100,
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: Stack(
            children: <Widget>[
              PageView.builder(
                itemCount: FakeRepository.dataList.length,
                onPageChanged: (int index) {
                  setState(() {
                    _pageSelectedIndex = index;
                  });
                },
                scrollDirection: Axis.horizontal,
                controller: PageController(
                    initialPage: 1, keepPage: true, viewportFraction: 0.2),
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${FakeRepository.dataList[index]}",
                      style: TextStyle(
                          color: _pageSelectedIndex == index
                              ? Colors.white
                              : Colors.grey),
                    ),
                  );
                },
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                ),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _isRecording ? _onStop : null;
    super.dispose();
  }
}
