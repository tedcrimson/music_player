import 'package:flutter_ui_templates/library/localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_templates/ui_widgets/navigation/bottom_navigation_item.dart';
import 'package:flutter_ui_templates/ui_widgets/navigation/tabmodel.dart';
import 'package:music_player/const.dart';

class MyBottomItem extends MyBottomNavigationItem {
  MyBottomItem(TabModel model) : super(model: model);

  @override
  BottomNavigationBarItem buildItem() {
    return BottomNavigationBarItem(
        icon: Container(
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.all(Radius.elliptical(20, 18))),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Icon(
            model.icon,
            color: Colors.grey,
          ),
        ),
        activeIcon: Material(
          borderRadius: BorderRadius.all(Radius.elliptical(20, 18)),
          color: mainColor,
          elevation: 2,

          // decoration: BoxDecoration(
          //     ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            // padding: const EdgeInsets.all(8.0),
            child: Icon(
              model.icon,
              color: Colors.white,
            ),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.only(top: 2, left: 4, right: 4),
          child: Text(
            model.name.i18n.toUpperCase(),
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: model.selected
            ? model.selectedBackgroundColor
            : model.backgroundColor);
  }
}
