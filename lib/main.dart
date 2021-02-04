import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:typetypego/config/palette.dart';
import 'package:typetypego/screens/main/mainScreen.dart';
import 'package:typetypego/screens/sorry/sorryScreen.dart';

void main() {
  runApp(TypeTypeGoApp());
}

class TypeTypeGoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TypeTypeGo!',
      theme: ThemeData(
        fontFamily: 'BalooThambi2',
        primaryColor: Palette.blue,
      ),
      home: Wrapper(),
    );
  }
}

/// Navigates to the [MainScreen] if the user is on a desktop
/// and navigates to the [SorryScreen] if the user is not on a desktop.
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, sizingInformation) {
        if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
          return MainScreen();
        }
        return SorryScreen();
      },
    );
  }
}
