import 'package:LIVE365/components/cam_icon.dart';
import 'package:LIVE365/components/selectedtext.dart';
import 'package:LIVE365/style/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../constants.dart';

enum TikTokPageTag {
  home,
  search,
  msg,
  me,
}

class TikTokTabBar extends StatelessWidget {
  final Function(TikTokPageTag) onTabSwitch;
  final Function() onAddButton;

  final bool hasBackground;
  final TikTokPageTag current;

  const TikTokTabBar({
    Key key,
    this.onTabSwitch,
    this.current,
    this.onAddButton,
    this.hasBackground: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;
    Widget row = Row(
      children: <Widget>[
        Expanded(
            child: InkWell(
          onTap: () => onTabSwitch?.call(TikTokPageTag.home),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/Phone.svg",
                  color: white,
                ),
              ),
              Center(
                child: SelectText(
                  isSelect: current == TikTokPageTag.home,
                  title: 'Home',
                ),
              )
            ],
          ),
        )),
        Expanded(
            child: InkWell(
          onTap: () => onTabSwitch?.call(TikTokPageTag.search),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/Search Icon.svg",
                  color: white,
                ),
              ),
              Center(
                child: SelectText(
                  isSelect: current == TikTokPageTag.search,
                  title: 'Search',
                ),
              )
            ],
          ),
        )),
        Expanded(
          child: InkWell(onTap: () => onAddButton?.call(), child: CamIcon()),
        ),
        Expanded(
            child: InkWell(
          onTap: () => onTabSwitch?.call(TikTokPageTag.msg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/Chat bubble Icon.svg",
                  color: white,
                ),
              ),
              Center(
                child: SelectText(
                  isSelect: current == TikTokPageTag.msg,
                  title: 'Inbox',
                ),
              )
            ],
          ),
        )),
        Expanded(
            child: InkWell(
          onTap: () => onTabSwitch?.call(TikTokPageTag.me),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                icon: SvgPicture.asset(
                  "assets/icons/Search Icon.svg",
                  color: white,
                ),
              ),
              Center(
                child: SelectText(
                  isSelect: current == TikTokPageTag.me,
                  title: 'Me',
                ),
              )
            ],
          ),
        )),
      ],
    );
    return Container(
      color: hasBackground ? GBottomNav : ColorPlate.back2.withOpacity(0),
      child: Container(
        padding: EdgeInsets.only(bottom: padding.bottom),
        height: 70 + padding.bottom,
        child: row,
      ),
    );
  }
}
