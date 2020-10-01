import 'package:flutter/material.dart';
import 'package:flutter_ui_templates/ui_widgets/base_page.dart';
import 'package:music_player/widgets/my_button.dart';

import '../const.dart';

class MyPage extends StatelessWidget {
  final String title;
  final EdgeInsets padding;
  final ScrollPhysics physics;
  final Widget child;
  final Map<String, Function> actions; //todo change
  final VoidCallback onBackPressed;
  final bool scrollable;
  final bool canPop;

  MyPage({
    this.title,
    this.padding = const EdgeInsets.all(25.0),
    this.physics,
    this.child,
    this.actions,
    this.onBackPressed,
    this.scrollable = true,
    this.canPop = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(builder: (_, cc) {
      BoxConstraints constraints = cc;
      if (scrollable) constraints = cc.copyWith(minHeight: cc.maxHeight, maxHeight: double.infinity);

      return Container(
          constraints: constraints,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color.fromRGBO(223, 233, 254, 1), Color.fromRGBO(230, 238, 246, 1)],
                  stops: [0, 1],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Column(children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    canPop
                        ? MyButton(Icons.arrow_back, onTap: () {
                            Navigator.of(context).pop();
                          })
                        : SizedBox(width: 50),
                    Text(
                      title ?? "",
                      style: TextStyle(color: dark, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    actions != null
                        ? MyButton(Icons.menu, onTap: () {})
                        : SizedBox(
                            width: 50,
                          )
                  ],
                ),
              ),
            ),
            Expanded(
                child: Padding(
              padding: padding,
              child: child,
            ))
          ]));
    }));
  }
}
