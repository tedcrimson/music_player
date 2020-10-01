import 'package:flutter/material.dart';
import 'package:music_player/const.dart';
import 'package:music_player/widgets/shadow_widget.dart';

class MyButton extends StatelessWidget {
  final IconData icon;
  final double width;
  final double height;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final Gradient gradient;
  final Function onTap;

  MyButton(this.icon,
      {this.width = 50,
      this.height = 50,
      this.iconSize = 20,
      this.iconColor = dark,
      this.backgroundColor = light,
      this.gradient,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    return ShadowWidget(
        width: width,
        height: height,
        offset: 5,
        spreadRadius: 2,
        blurRadius: 8,
        backgroundColor: backgroundColor,
        gradient: gradient ??
            RadialGradient(
              center: Alignment(.1, .1),
              colors: [
                // Colors.red,
                Color.fromRGBO(224, 234, 254, 1),
                Colors.white60,
                // Color(0xfffafafa),
              ],
              stops: [0.4, .7],
              radius: .9,
            ),
        child: FlatButton(
          onPressed: onTap,
          highlightColor: Colors.transparent,
          splashColor: Colors.black12,
          shape: new CircleBorder(),
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor,
            ),
          ),
        ));
  }
}
