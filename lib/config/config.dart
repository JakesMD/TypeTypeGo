import 'package:typetypego/config/consts.dart';

class Config {
  static const String repositoryUrl = "github.com/JakesMD/TypeTypeGo";
  static const String appVersion = "1.0.0"; // TODO: update app version
  static const List<String> ignoredKeys = [
    "Shift",
    "Alt",
    "AltGraph",
    "Control"
  ];
  static const List<String> wordBreakCharacters = [
    ' ',
    '-',
    ';',
    ',',
    Consts.returnSymbol
  ];
  static const int wpmTarget = 150;
  static const int scoreTarget = 15000;
  static const double typeTestBoxCharacterWidth = 22;
  static const double typeTestBoxPadding = 59;
  static const String initialTypeTestText = '''Welcome to TypeTypeGo!
Simply enter some text into the text field below, click "GO!" and start typing! On the right you can see your WPM (words per minute), accuracy and total score. Click the "refresh" icon to restart the test.''';
}
