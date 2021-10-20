import 'dart:io';

import 'package:LIVE365/camera/videoo.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  static final String pageRoute = "/";

  CameraPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _CameraView());
  }
}

class _CameraView extends StatefulWidget {
  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<_CameraView> {
  List<CameraDescription> _cameras;
  CameraController _controller;
  CameraDescription _activeCamera;
  String _filePath;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    _getAvailableCameras();
    _controller = CameraController(_activeCamera, ResolutionPreset.high);
  }

  Future<void> _getAvailableCameras() async {
    try {
      final cameras = await availableCameras();
      setState(() {
        _cameras = cameras;
      });
    } catch (e) {
      print("_getAvailableCameras $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _cameraView() {
    if (_controller == null || !_controller.value.isInitialized) {
      return _activeCamera == null ? Placeholder() : Container();
    }
    return Center(
        child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
                border: Border.all(
              color: _controller != null && _controller.value.isRecordingVideo
                  ? Colors.redAccent
                  : Colors.transparent,
              width: 1.0,
            )),
            child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: CameraPreview(_controller))));
  }

  String _getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _takePhoto(BuildContext context) async {
    if (!_controller.value.isInitialized) {
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_camera';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_getTimestamp()}.jpg';

    if (_controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await _controller.takePicture(filePath);
      setState(() {
        _filePath = filePath;
        _showBottomSheet(context);
      });
    } on CameraException catch (e) {
      print(e);
    }
  }

  Future<void> _startVideoRecording() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_camera';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_getTimestamp()}.mp4';

    if (_controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      await _controller.startVideoRecording(filePath);
      setState(() {
        _filePath = filePath;
      });
    } on CameraException catch (e) {
      print(e);
    }
  }

  Future<void> _stopVideoRecording(BuildContext context) async {
    if (!_controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await _controller.stopVideoRecording();
      setState(() {
        _showBottomSheet(context);
      });
    } on CameraException catch (e) {
      print(e);
    }
  }

  String _getLensDirectionText(CameraLensDirection lensDirection) {
    switch (lensDirection) {
      case CameraLensDirection.back:
        return "Back";
        break;
      case CameraLensDirection.front:
        return "Frontal";
        break;
      case CameraLensDirection.external:
        return "External";
        break;
    }
    return '';
  }

  Widget _lensControl(CameraDescription cameraDescription) {
    String text = _getLensDirectionText(cameraDescription.lensDirection);
    return RaisedButton(
      child: Text("$text ${cameraDescription.name}"),
      onPressed: () {
        setState(() {
          _activeCamera = cameraDescription;
          _setCameraController(cameraDescription);
        });
      },
    );
  }

  void _setCameraController(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(cameraDescription, ResolutionPreset.medium);

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraListWidget() {
    final List<Widget> cameras = <Widget>[];
    if (_cameras == null || _cameras.isEmpty) {
      return Text('No cameras found');
    } else {
      for (CameraDescription cameraDescription in _cameras) {
        cameras.add(_lensControl(cameraDescription));
      }
    }

    return Flexible(
        fit: FlexFit.loose,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: cameras));
  }

  Widget _getActiveCamera() {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _activeCamera == null
              ? "Выберите камеру"
              : "${_getLensDirectionText(_activeCamera.lensDirection)} ${_activeCamera.name}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ));
  }

  void _showBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Center(
              child: LimitedBox(
            child:
                _isVideo ? Video(File(_filePath)) : Image.file(File(_filePath)),
            maxHeight: 300,
          ));
        });
  }

  String get buttonText => !_isVideo
      ? "Take a photo"
      : "${_controller != null && _controller.value.isRecordingVideo ? "Stop recording" : "Record video"}";

  IconData get buttonIcon => !_isVideo ? Icons.photo_camera : Icons.videocam;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(child: _cameraView(), height: 300),
          _getActiveCamera(),
          _cameraListWidget(),
          RaisedButton.icon(
            icon: Icon(buttonIcon),
            label: Text(buttonText),
            onPressed: _activeCamera == null
                ? null
                : () {
                    if (_isVideo) {
                      if (_controller.value.isRecordingVideo) {
                        _stopVideoRecording(context);
                      } else {
                        _startVideoRecording();
                      }
                    } else {
                      _takePhoto(context);
                    }
                  },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Photo'),
              Switch(
                onChanged: (bool value) {
                  setState(() {
                    _isVideo = value;
                  });
                },
                value: _isVideo,
              ),
              Text('Video'),
            ],
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    ));
  }
}
