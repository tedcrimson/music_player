import 'package:flutter/material.dart';
import 'package:music_player/const.dart';

class ShadowWidget extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double spreadRadius;
  final double blurRadius;
  final double offset;
  final Color backgroundColor;
  final Gradient gradient;
  ShadowWidget({
    this.child,
    this.width,
    this.height,
    this.spreadRadius = 10,
    this.blurRadius = 25,
    this.offset = 20,
    this.backgroundColor = light,
    this.gradient,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          // color: Colors.deepPurple,
          color: backgroundColor,
          // gradient: LinearGradient(
          //   colors: [
          //     Color.fromRGBO(226, 237, 254, 1),
          //     Color.fromRGBO(183, 199, 219, 1),
          //   ],
          //   begin: Alignment.topLeft,
          //   end: Alignment.bottomRight,
          //   stops: [0, 1],
          // ),
          boxShadow: [
            BoxShadow(
                color: Color.fromRGBO(131, 143, 180, 0.5),
                offset: Offset(offset, offset),
                spreadRadius: spreadRadius,
                blurRadius: blurRadius),
            BoxShadow(
                color: Colors.white70,
                offset: Offset(-offset, -offset),
                spreadRadius: spreadRadius - 1,
                blurRadius: blurRadius),
          ]),
      child: FractionallySizedBox(
        widthFactor: 0.93,
        heightFactor: 0.93,
        // padding: EdgeInsets.all(max(width, height) / 5.0),
        child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(1, 1),
                      spreadRadius: 0.5,
                      blurRadius: 2),
                ],
                gradient: gradient),
            child: child),
      ),
    );
  }
}
