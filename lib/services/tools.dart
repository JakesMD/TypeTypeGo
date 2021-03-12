// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:typetypego/config/config.dart';

class Tools {
  /// Opens the GitHub repository website in a new tab.
  static void openRepositorySite() {
    js.context.callMethod(
      'open',
      ["https://" + Config.repositoryUrl],
    );
  }

  static String formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    var millis = (milliseconds % 100).toString().padLeft(2, '0');
    return "$minutes:$seconds:$millis";
  }
}
