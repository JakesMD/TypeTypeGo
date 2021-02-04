import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:typetypego/config/config.dart';
import 'package:typetypego/config/consts.dart';
import 'package:typetypego/config/palette.dart';
import 'package:typetypego/screens/main/resultsSideBar.dart';
import 'package:typetypego/screens/main/textInputBox.dart';
import 'package:typetypego/screens/main/typeTestBox.dart';

/// The screen with the actual content of the type test app.
///
/// Displayed only if the user is on a desktop.

// The StatefulHookWidget is needed for useFocusNode() and useTextEditingController().
class MainScreen extends StatefulHookWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TypeTestBox _typeTestBox = TypeTestBox();
  FocusNode _typeTestFocusNode;
  ResultsSideBar _resultsSideBar;
  String _typeTestText = '';
  List<List> _charactersData = [];
  int _cursorIndex = 0;
  int _accuracy = 0;
  DateTime _startTime;
  bool _isRestarting = false;

  //String _debugText = '';

  /// Calculates the WPM and accuracy and updates the [_resultsSideBar].
  void _updateResultsSideBar() {
    final double wpm = (_cursorIndex / 5) /
        (DateTime.now().difference(_startTime).inMilliseconds / 60000);
    final double accuracy = _accuracy / _cursorIndex;
    _resultsSideBar.update(wpm: wpm, accuracy: accuracy);
  }

  /// Clears old test data, creates new data from [newText] and updates the other widgets accordingly.
  void _restart(String newText) async {
    // This tells _onKey() to ignore all key presses during the restart.
    _isRestarting = true;

    // Resets all the old test data.
    _typeTestText = newText;
    _charactersData = [];
    _cursorIndex = 0;
    _accuracy = 0;
    _startTime = null;

    // Create a new list of characters from newText.
    newText.replaceAll('\n', Consts.returnSymbol).split('').forEach(
          // first element is the actual character string, second element is the state of the character.
          (character) => _charactersData.add([character, Consts.correctState]),
        );

    // Resets the ResultsSideBar.
    _resultsSideBar.update(wpm: 0, accuracy: 0);

    // Rebuilds the TypeTestBoxCharacters in the TypeTestBox.
    _typeTestBox.generateCharacters(_charactersData);

    // Starts listening for key inputs.
    FocusScope.of(context).requestFocus(_typeTestFocusNode);
    //_typeTestFocusNode.requestFocus(); // <-- this doesn't work on release app for some reason??!!

    // Once all the widgets are built we can allow key presses again.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _isRestarting = false,
    );
  }

  /// Checks whether to ignore the key press and validates the key press if false.
  void _onKey(RawKeyEvent event) {
    //setState(() => _debugText = event.runtimeType.toString());
    // True if the key is being pressed.
    if (event.runtimeType.toString() == "RawKeyDownEvent" ||
        event.runtimeType.toString().contains("minified:m")) {
      // True if and the key doesn't need to be ignored.
      if (!Config.ignoredKeys.contains(event.character) && !_isRestarting) {
        // Starts the test when the first key is pressed.
        if (_startTime == null) _startTime = DateTime.now();

        // event.character returns null if the spacebar is pressed for some reason!!??
        if (event.data.logicalKey.debugName == "Space")
          _validateInput(" ");
        else if (event.character == "Enter")
          _validateInput(Consts.returnSymbol);
        else
          _validateInput(event.character);
      }
    }
  }

  /// Validates the key press and updates the test data and widgets accordingly.
  void _validateInput(String input) {
    // True if backspace is pressed and the cursor isn't at the start of the test.
    if (input == "Backspace") {
      if (_cursorIndex > 0) {
        // Goes back to previous position and resets the corresponding TypeTestBoxCharacters.
        _typeTestBox.updateCharacter(
            index: _cursorIndex, state: Consts.neutralState, isAtCursor: false);
        _typeTestBox.updateCharacter(
            index: _cursorIndex - 1,
            state: Consts.neutralState,
            isAtCursor: true);
        _cursorIndex--;
        if (_accuracy > 0) _accuracy--;

        // Sets this new character's state to halfCorrectState if it was once incorrectState.
        if (_charactersData[_cursorIndex][1] != Consts.correctState)
          _charactersData[_cursorIndex][1] = Consts.halfCorrectState;
      }
    }
    // True if backspace isn't pressed and the cursor isn't at the end of the test.
    else if (_cursorIndex < _charactersData.length) {
      // True if the input is correct.
      if (input == _charactersData[_cursorIndex][0]) {
        // Only sets the state to correctState if it wasn't once incorrectState.
        if (_charactersData[_cursorIndex][1] != Consts.halfCorrectState)
          _charactersData[_cursorIndex][1] = Consts.correctState;
        // Boosts the accuracy.
        _accuracy++;
      }
      // True if the input is wrong.
      else
        _charactersData[_cursorIndex][1] = Consts.incorrectState;

      // Update the corresponding TypeTestBoxCharacters.
      _typeTestBox.updateCharacter(
        index: _cursorIndex,
        state: _charactersData[_cursorIndex][1],
        isAtCursor: false,
      );

      // Moves to the next position.
      _cursorIndex++;

      // Updates the next TypeTestBoxCharacter if the cursor is not at the end of the text.
      if (_cursorIndex < _charactersData.length)
        _typeTestBox.updateCharacter(
            index: _cursorIndex, state: Consts.neutralState, isAtCursor: true);
      // Prevents listening to key inputs if the cursor is at the end of the test.
      else {
        _typeTestFocusNode.unfocus();
        FocusScope.of(context).requestFocus(FocusNode());
      }
      // Updates the ResultSideBar with the new results.
      if (_cursorIndex > 4) _updateResultsSideBar();
    }
  }

  @override
  void initState() {
    super.initState();

    // Restarts the test when the restart button is pressed on the ResultsSideBar.
    _resultsSideBar = ResultsSideBar(onRestart: () => _restart(_typeTestText));

    // Starts a test with the initial type text once everything has been built.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _restart(Config.initialTypeTestText),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gets the focus node for the TypeTestBox.
    _typeTestFocusNode = useFocusNode();

    // Gets the focus node for the TextInputBox.
    final FocusNode textInputFocusNode = useFocusNode();

    // Gets the controller for the TextInputBox.
    final TextEditingController textInputController =
        useTextEditingController();

    return Scaffold(
      backgroundColor: Palette.blueGrey,
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                /*Text(
                  _debugText,
                  style: TextStyle(color: Colors.red),
                ),*/
                Expanded(
                  child: RawKeyboardListener(
                    focusNode: _typeTestFocusNode,
                    onKey: _onKey,
                    child: _typeTestBox,
                  ),
                ),
                TextInputBox(
                  focusNode: textInputFocusNode,
                  controller: textInputController,
                  onStart: _restart,
                ),
              ],
            ),
          ),
          _resultsSideBar,
        ],
      ),
    );
  }
}
