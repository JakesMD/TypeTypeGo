import 'package:typetypego/config/consts.dart';

class Config {
  static const String repositoryUrl = "github.com/JakesMD/TypeTypeGo";
  static const String appVersion = "1.1.0"; // TODO: update app version
  static const List<String> ignoredKeys = [
    "Shift",
    "Alt",
    "AltGraph",
    "Control",
    "F1",
    "F2",
    "F3",
    "F4",
    "F5",
    "F6",
    "F7",
    "F8",
    "F9",
    "F10",
    "F11",
    "F12",
    "Function",
    "Meta",
    "Escape",
  ];
  static const List<String> wordBreakCharacters = [
    ' ',
    '-',
    ';',
    ',',
    Consts.returnSymbol
  ];
  static const int minTextLength = 5;
  static const int wpmTarget = 150;
  static const int scoreTarget = 15000;
  static const double margin = 20;
  static const double borderRadius = 20;
  static const double typeTestBoxCharacterWidth = 22;
  static const double typeTestBoxPadding = 39;
  static const String initialTypeTestText = '''Welcome to TypeTypeGo!
Simply enter some text into the text field below, click "GO!" and start typing! On the right you can see your WPM (words per minute), accuracy, total score and common mistakes. Click the "refresh" icon to restart the test.''';
}
