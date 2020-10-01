import 'package:flutter/material.dart';
import 'package:flutter_ui_templates/ui_widgets/page.dart';

class ProfilePage extends Page {
  @override
  _ProfilePageState createState() => _ProfilePageState();
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
