import 'package:LIVE365/home/components/tiktokvideogesture.dart';
import 'package:LIVE365/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TikTokVideoPage extends StatelessWidget {
  final Widget video;
  final double aspectRatio;
  final String tag;
  final double bottomPadding;

  final Widget rightButtonColumn;
  final Widget userInfoWidget;

  final bool hidePauseIcon;

  final Function onAddFavorite;
  final Function onSingleTap;

  const TikTokVideoPage({
    Key key,
    this.bottomPadding: 16,
    this.tag,
    this.rightButtonColumn,
    this.userInfoWidget,
    this.onAddFavorite,
    this.onSingleTap,
    this.video,
    this.aspectRatio: 9 / 16.0,
    this.hidePauseIcon: false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget rightButtons = rightButtonColumn ?? Container();
    Widget videoContainer = TikTokVideoGesture(
      onAddFavorite: onAddFavorite,
      onSingleTap: onSingleTap,
      child: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.black,
            alignment: Alignment.center,
            child: Container(
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: video,
              ),
            ),
          ),
        ],
      ),
    );
    Widget body = Container(
      child: Stack(
        children: <Widget>[
          videoContainer,
          Container(
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.bottomRight,
            child: rightButtons,
          ),
          /*Container(
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.bottomLeft,
            child: userInfo,
          ),*/
        ],
      ),
    );
    return body;
  }
}

class VideoLoadingPlaceHolder extends StatelessWidget {
  const VideoLoadingPlaceHolder({
    Key key,
    @required this.tag,
  }) : super(key: key);

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          colors: <Color>[
            Colors.blue,
            Colors.green,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitWave(
            size: 36,
            color: Colors.white.withOpacity(0.3),
          ),
          Container(
            padding: EdgeInsets.all(50),
            child: Text(
              tag ?? 'Unknown Tag',
              style: StandardTextStyle.normalWithOpacity,
            ),
          ),
        ],
      ),
    );
  }
}
