import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Function onTap;
  final BorderRadius borderRadius;
  final bool elevated;
  final Color color;

  CustomCard({
    @required this.child,
    this.onTap,
    this.borderRadius,
    this.elevated = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: elevated
          ? BoxDecoration(
              borderRadius: borderRadius,
              color: color == null ? Theme.of(context).cardColor : color,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[300].withOpacity(0.8),
                  blurRadius: 8.0,
                  spreadRadius: 0.0,
                  offset: Offset(
                    0.0,
                    2.0,
                  ),
                ),
              ],
            )
          : BoxDecoration(
              borderRadius: borderRadius,
              color: Theme.of(context).cardColor,
            ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
