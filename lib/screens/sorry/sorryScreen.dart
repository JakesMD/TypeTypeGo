import 'package:flutter/material.dart';
import 'package:typetypego/config/config.dart';
import 'package:typetypego/config/palette.dart';
import 'package:typetypego/services/tools.dart';

/// A screen with a small sorry message and help info.
///
/// Displayed when the user is not on a desktop.
class SorryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.white,
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(15.0),
          children: [
            Text(
              'Sorry, there! 😞',
              style: TextStyle(
                color: Palette.blueGrey,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "This is only meant for desktops and laptops.\nIf you're on a desktop, try zooming out or maximizing your window.",
              style: TextStyle(
                color: Palette.blueGrey,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Text(
              '©️ TypeTypeGo! 2021 - v${Config.appVersion}\nDeveloped by Jacob Drew 2021',
              style: TextStyle(
                color: Palette.blueGrey,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            GestureDetector(
              onTap: Tools.openRepositorySite,
              child: Text(
                Config.repositoryUrl,
                style: TextStyle(
                  color: Palette.blue,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
