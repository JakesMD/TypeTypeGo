import 'package:flutter/material.dart';
import 'package:typetypego/config/config.dart';
import 'package:typetypego/config/consts.dart';
import 'package:typetypego/config/palette.dart';

/// The blue-grey container with the type test text.
class TypeTestBox extends StatefulWidget {
  final _TypeTestBoxState _typeTestBoxState = _TypeTestBoxState();

  @override
  _TypeTestBoxState createState() => _typeTestBoxState;

  /// Generates the [TypeTestBoxCharacter]s and rebuilds.
  void generateCharacters(List charactersData) =>
      _typeTestBoxState.generateCharacters(charactersData);

  /// Rebuilds the [TypeTestBoxCharacter] at [index] with the new [state] and [isAtCursor].
  void updateCharacter(
          {@required int index,
          @required int state,
          @required bool isAtCursor}) =>
      _typeTestBoxState.updateCharacter(
          index: index, state: state, isAtCursor: isAtCursor);
}

class _TypeTestBoxState extends State<TypeTestBox> {
  List<List> _words = [];
  List<TypeTestBoxCharacter> _characters = [];

  /// Generates [_characters] and rebuilds.
  void generateCharacters(List charactersData) {
    setState(() {
      _characters = [];
      _words = [];
      List word = [];
      int index = -1;

      charactersData.forEach((element) {
        index++;

        // Creates a new TypeTestBoxCharacter and adds it to _characters.
        _characters.add(
          TypeTestBoxCharacter(
            key: GlobalKey(),
            character: element[0],
            initialIsAtCursor: index == 0,
          ),
        );

        // Adds the character string to the current word.
        word.add(element[0]);

        // Adds the word to _words if the character string is a word-breaker.
        // This will help wrap the characters into a readable text in _generateCharacterText().
        if (Config.wordBreakCharacters.contains(element[0])) {
          // The last item in word is the index of the word.
          _words.add(word..add(index - word.length + 1));
          word = [];
        }
      });

      // Adds the final word if it didn't end with a word-breaker.
      if (word.length > 0) _words.add(word..add(index - word.length + 1));
    });
  }

  /// Generates a list of lines ([Row] => [Row] => [TypeTestBoxCharacter]) for the [ListView].
  List<Row> _generateCharacterText(BoxConstraints constraints) {
    List<Row> lines = [];
    List<Widget> line = [];
    int lineLength = 0;
    _words.forEach((word) {
      // Generates the word made up of TypeTestBoxCharacters.
      final Row wordRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
            word.length - 1, (index) => _characters[word.last + index]),
      );

      // Creates a new line if the wordRow doesn't fit on the end of the current line.
      if ((lineLength + word.length - 1) * Config.typeTestBoxCharacterWidth >
          constraints.maxWidth) {
        lines.add(Row(children: line));
        line = [];
        lineLength = 0;
      }
      // Creates a new line if word ends with a newline.
      if (word[word.length - 2] == Consts.returnSymbol) {
        line.add(wordRow);
        lines.add(Row(children: line));
        line = [];
        lineLength = 0;
      }
      // Add the wordRow to the current line.
      else {
        line.add(wordRow);
        lineLength += word.length - 1;
      }
    });
    // Adds the last line to lines.
    if (line.isNotEmpty) lines.add(Row(children: line));
    return lines;
  }

  /// Rebuilds the [TypeTestBoxCharacter] at [index] with the new [state] and [isAtCursor].
  ///
  /// Rebuilding like this instead of calling [setState()] prevents all the other [TypeTestBoxCharacter]s from being rebuilt.
  void updateCharacter(
          {@required int index,
          @required int state,
          @required bool isAtCursor}) =>
      _characters[index].update(state, isAtCursor);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.blueGrey,
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Config.typeTestBoxPadding, 0, Config.typeTestBoxPadding, 0),
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            padding: EdgeInsets.fromLTRB(
                0, Config.typeTestBoxPadding, 0, Config.typeTestBoxPadding),
            children: _generateCharacterText(constraints),
          ),
        ),
      ),
    );
  }
}

/// Represents a character of the type test text displayed in the [TypeTestBox].
class TypeTestBoxCharacter extends StatefulWidget {
  final String character;
  final bool initialIsAtCursor;

  /// This is needed to make sure it's visible.
  final GlobalKey key;

  TypeTestBoxCharacter(
      {@required this.key,
      @required this.character,
      this.initialIsAtCursor = false})
      : super(key: key);

  final _TypeTestBoxCharacterState _typeTestBoxCharacterState =
      _TypeTestBoxCharacterState();

  @override
  _TypeTestBoxCharacterState createState() => _typeTestBoxCharacterState;

  /// Rebuilds this with the new [state] and [isAtCursor].
  void update(int state, bool isAtCursor) =>
      _typeTestBoxCharacterState.update(state, isAtCursor);
}

class _TypeTestBoxCharacterState extends State<TypeTestBoxCharacter> {
  int _state = 0;
  bool _isAtCursor = false;

  /// Rebuilds this with the new [state] and [isAtCursor].
  void update(int state, bool isAtCursor) {
    setState(() {
      _state = state;
      _isAtCursor = isAtCursor;

      if (isAtCursor)
        // Scroll down to it's position in the ListView if it's not visible
        Scrollable.ensureVisible(widget.key.currentContext, alignment: 0.25);
    });
  }

  @override
  void initState() {
    super.initState();
    _isAtCursor = widget.initialIsAtCursor;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 4, 1, 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          height: 38,
          width: Config.typeTestBoxCharacterWidth - 2,
          decoration: BoxDecoration(
            // The color is different depending on the state.
            color: _state == Consts.neutralState
                ? Palette.blue.withAlpha(50)
                : _state == Consts.correctState
                    ? Palette.green.withAlpha(50)
                    : _state == Consts.halfCorrectState
                        ? Palette.orange.withAlpha(50)
                        : Palette.red.withAlpha(50),
            border: Border(
              bottom: BorderSide(
                // Shows a white border if the cursor is at this character.
                color: _isAtCursor ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            widget.character,
            style: TextStyle(
                fontSize: 24,
                color: Palette.white,
                fontFamily: 'SourceCodePro'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
