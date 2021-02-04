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
}
