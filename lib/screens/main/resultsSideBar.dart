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

  /// Updates the circular percent indicators with the new wpm and accuracy results.
  void update({@required double wpm, @required double accuracy}) =>
      _resultsSideBarState.update(wpm: wpm, accuracy: accuracy);
}

class _ResultsSideBarState extends State<ResultsSideBar> {
  double _wpm = 0;
  double _wpmPercent = 0;
  double _accuracy = 0;
  double _score = 0;
  double _scorePercent = 0;

  /// Updates the circular percent indicators with the new wpm and accuracy results.
  ///
  /// Rebuilding like this instead of calling [setState()] on the [MainScreen] prevents everything from being rebuilt
  /// everytime a key is pressed.
  void update({@required double wpm, @required double accuracy}) {
    setState(() {
      _wpm = wpm;
      _wpmPercent = _wpm / Config.wpmTarget;
      _accuracy = accuracy;
      _score = _wpm * (accuracy * 100);
      _scorePercent = _score / Config.scoreTarget;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // This scroll view prevents errors from occuring when the window height is to short.
      child: Container(
        padding: EdgeInsets.all(20),
        width: 250,
        height: MediaQuery.of(context).size.height > 800
            ? MediaQuery.of(context).size.height
            : 800,
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
