import 'package:flutter/material.dart';
import 'package:flutter_ui_templates/ui_widgets/base_page.dart';

class ProfilePage extends BasePage {
  @override
  _ProfilePageState createState() => _ProfilePageState();

  @override
  String get name => '';
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Profile"),
      ),
    );
  }
}
