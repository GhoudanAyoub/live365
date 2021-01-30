import 'package:LIVE365/components/live_cart_info_show.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../SizeConfig.dart';

class PictureCard extends StatelessWidget {
  final String image;
  final String name;
  final String Views;
  final String Like;
  final String Comments;

  const PictureCard(
      {Key key, this.image, this.name, this.Views, this.Like, this.Comments})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      height: getProportionateScreenHeight(300),
                      width: getProportionateScreenWidth(350),
                      child: CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 500),
                        fadeInCurve: Curves.easeIn,
                        placeholder: (context, progressText) =>
                            Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    Positioned(
                      left: 10.0,
                      top: 10.0,
                      right: 10.0,
                      child: LiveCardInfoShow(
                          image: image, name: name, views: Views),
                    ),
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      width: getProportionateScreenWidth(350),
                      height: getProportionateScreenHeight(300),
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                              Colors.black,
                              Colors.black.withOpacity(0.1),
                            ])),
                      ),
                    ),
                    Positioned(
                      left: 10.0,
                      bottom: 15.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: 10.0,
                          ),
                          SvgPicture.asset("assets/icons/Heart Icon_2.svg"),
                          SizedBox(
                            width: 2.0,
                          ),
                          Text(
                            Like,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 14.0),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          SvgPicture.asset("assets/icons/Chat bubble Icon.svg"),
                          SizedBox(
                            width: 2.0,
                          ),
                          Text(
                            Comments,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 12.0),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: getProportionateScreenHeight(10)),
            ],
          ),
        ));
  }
}
