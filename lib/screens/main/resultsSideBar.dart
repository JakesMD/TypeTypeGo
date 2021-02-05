import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:typetypego/config/config.dart';
import 'package:typetypego/config/palette.dart';

/// The blue container with 3 circular percent indicators that displays the results of the typing test.
class ResultsSideBar extends StatefulWidget {
  /// Called when the restart button is pressed.
  final Function onRestart;

  ResultsSideBar({this.onRestart});

  final _ResultsSideBarState _resultsSideBarState = _ResultsSideBarState();

  @override
  _ResultsSideBarState createState() => _resultsSideBarState;

  /// Updates the circular percent indicators with the new wpm, accuracy and common mistakes results.
  void update(
          {@required double wpm,
          @required double accuracy,
          @required List<String> commonMistakes}) =>
      _resultsSideBarState.update(
          wpm: wpm, accuracy: accuracy, commonMistakes: commonMistakes);
}

class _ResultsSideBarState extends State<ResultsSideBar> {
  double _wpm = 0;
  double _wpmPercent = 0;
  double _accuracy = 0;
  double _score = 0;
  double _scorePercent = 0;
  List<String> _commonMistakes = [];

  /// Updates the circular percent indicators with the new wpm, accuracy and common mistakes results.
  ///
  /// Rebuilding like this instead of calling [setState()] on the [MainScreen] prevents everything from being rebuilt
  /// everytime a key is pressed.
  void update(
      {@required double wpm,
      @required double accuracy,
      @required List<String> commonMistakes}) {
    setState(() {
      _wpm = wpm;
      _wpmPercent = _wpm / Config.wpmTarget;
      _accuracy = accuracy;
      _score = _wpm * (accuracy * 100);
      _scorePercent = _score / Config.scoreTarget;
      _commonMistakes = commonMistakes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // This scroll view prevents errors from occuring when the window height is to short.
      child: Container(
        padding: EdgeInsets.all(20),
        width: 250,
        height: MediaQuery.of(context).size.height > 850
            ? MediaQuery.of(context).size.height
            : 850,
        color: Palette.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // The WPM results.
            ResultsCircularPercentIndicator(
              percent: _wpmPercent < 1 ? _wpmPercent : 1,
              valueText: '${_wpm.toInt()}',
              title: 'WPM',
            ),

            // The accuracy results.
            ResultsCircularPercentIndicator(
              percent: _accuracy,
              valueText: '${(_accuracy * 100).toInt()}%',
              title: 'Accuracy',
            ),

            // The score results.
            ResultsCircularPercentIndicator(
              percent: _scorePercent < 1 ? _scorePercent : 1,
              valueText: '${_score.toInt()}',
              title: 'Score',
            ),

            // The most incorrect characters.
            SizedBox(
              height: 80,
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _commonMistakes.length,
                        (index) => ResultsMistakeCharacter(
                            character: _commonMistakes[index]),
                      ),
                    ),
                  ),
                  Text(
                    'Common Mistakes',
                    style: TextStyle(
                      color: Palette.blueGrey,
                      fontSize: 24,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),

            // The restart button.
            IconButton(
              icon: Icon(Icons.refresh_rounded),
              iconSize: 75,
              color: Palette.white,
              onPressed: widget.onRestart,
            ),
          ],
        ),
      ),
    );
  }
}

/// The [CircularPercentIndicator] that displays results on the [ResultsSideBar].
class ResultsCircularPercentIndicator extends StatelessWidget {
  final double percent;
  final String valueText;
  final String title;

  ResultsCircularPercentIndicator(
      {@required this.percent, @required this.valueText, @required this.title});

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: 175,
      circularStrokeCap: CircularStrokeCap.round,
      backgroundColor: Palette.blueGrey,
      progressColor: Palette.white,
      lineWidth: 15,
      percent: percent,
      animateFromLastPercent: true,
      animation: true,
      animationDuration: 250,
      center: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              valueText,
              style: TextStyle(
                color: Palette.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
                height: 1,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Palette.blueGrey,
                fontSize: 24,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Represents a character that is frequently typed incorrectly on the [ResultsSideBar].
class ResultsMistakeCharacter extends StatelessWidget {
  final String character;

  ResultsMistakeCharacter({@required this.character});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 1, 15),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 38,
          width: Config.typeTestBoxCharacterWidth - 2,
          decoration: BoxDecoration(color: Palette.white),
          child: Text(
            character,
            style: TextStyle(
                fontSize: 24,
                color: Palette.blueGrey,
                fontFamily: 'SourceCodePro'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
