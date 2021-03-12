import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:typetypego/config/config.dart';
import 'package:typetypego/config/palette.dart';
import 'package:typetypego/services/tools.dart';

/// The white container with the text field, the start button and the info text.
class TextInputBox extends StatelessWidget {
  /// The focusNode for the text field.
  final FocusNode focusNode;

  /// The controller for the text field.
  final TextEditingController? controller;

  /// Called when the start button is pressed.
  ///
  /// * [String] = the validated text from the text field.
  final Function(String)? onStart;

  TextInputBox(
      {required this.focusNode, required this.controller, this.onStart});

  // The form key for the text field.
  final _formKey = GlobalKey<FormState>();

  /// Validates the text from the [TextInputBoxTextField],
  /// unfocuses the [focusNode] and calls [onStart()].
  void _validate() {
    if (_formKey.currentState!.validate()) {
      focusNode.unfocus();
      onStart!(controller!.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // We need the constraints so we can give the text field a maxWordLength.
      builder: (context, constraints) => Container(
        color: Palette.white,
        padding: EdgeInsets.fromLTRB(
            Config.margin, Config.margin, Config.margin, Config.margin / 2),
        child: Column(
          children: [
            // The text field.
            TextInputBoxTextField(
              focusNode: focusNode,
              controller: controller,
              formKey: _formKey,

              // Calculates the maxWordLength from the available space in the TypeTestBox.
              // Note: the TypeTestBox is the same width as this TextInputBox.
              maxWordLength:
                  ((constraints.maxWidth - Config.typeTestBoxPadding * 2) ~/
                      Config.typeTestBoxCharacterWidth),
            ),

            // The start button.
            TextInputBoxStartButton(onPressed: _validate),
            SizedBox(height: Config.margin),

            // The info text.
            TextInputBoxInfoText(),
          ],
        ),
      ),
    );
  }
}

/// The text field displayed in the [TextInputBox].
class TextInputBoxTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode focusNode;
  final GlobalKey formKey;
  final int maxWordLength;

  TextInputBoxTextField(
      {required this.controller,
      required this.focusNode,
      required this.formKey,
      required this.maxWordLength});

  @override
  _TextInputBoxTextFieldState createState() => _TextInputBoxTextFieldState();
}

class _TextInputBoxTextFieldState extends State<TextInputBoxTextField> {
  String _value = "";
  String _difficulty = "VERY EASY";

  /// Calculates the difficulty of the [value] and updates [_value] and [_difficulty] accordingly.
  void _updateDifficulty(String value) {
    setState(() {
      final String trimmedValue = value.trim();
      _value = trimmedValue;
      if (trimmedValue.isNotEmpty) {
        // Create a list of all the easy characters.
        final List<String> easyCharacters =
            "abcdefghijklmnopqrstuvwxyz".split("")..addAll([" ", "\n"]);

        double difficultyPoints = 0;

        // Loop through the text in the textbox.
        trimmedValue.split("").forEach((String element) {
          // True if the character is not easy.
          if (!easyCharacters.contains(element)) {
            // Add 0.25 to difficultPoints if the character is a capital letter.
            if (easyCharacters.contains(element.toLowerCase()))
              difficultyPoints += 0.25;
            // Add 0.5 to difficultPoints if the character is a number.
            else if (double.tryParse(element) != null)
              difficultyPoints += 0.5;
            // Add 1 to difficultPoints if the character is a anything else, e.g. !, :, #,...
            else
              difficultyPoints++;
          }
        });

        // Calculate the difficulty by dividing the points by the square root of the length of text.
        final double difficulty = difficultyPoints / sqrt(trimmedValue.length);

        // Update the difficuly text according to the calculated difficulty.
        if (difficultyPoints < 0.75)
          _difficulty = "VERY EASY";
        else if (difficulty < 1)
          _difficulty = "EASY";
        else if (difficulty < 1.25)
          _difficulty = "MEDIUM";
        else if (difficulty < 1.5)
          _difficulty = "HARD";
        else
          _difficulty = "VERY HARD";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SizedBox(
        height: 200,
        child: TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          validator: (value) {
            final String trimmedValue = value!.trim();
            // True if the text field is empty.
            if (trimmedValue.isEmpty)
              return 'Paste some text in here and then click "GO!" to start';
            // True if the value is less than 5.
            else if (trimmedValue.length < Config.minTextLength)
              return "There's not enough text to test yourself on (min 5 characters)";
            // True if there is a word that is longer than maxWordLength.
            else if (trimmedValue
                    .split(' ')
                    .reduce((value, element) =>
                        value.length > element.length ? value : element)
                    .length >
                widget.maxWordLength) {
              return 'A word is too long (try making your window bigger)';
            }
            return null;
          },
          onChanged: _updateDifficulty,
          maxLines: null,
          minLines: null,
          expands: true,
          maxLength: 1000,
          cursorColor: Palette.blue,
          textAlignVertical: TextAlignVertical.top,
          style: TextStyle(color: Palette.blueGrey),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(Config.margin / 2),
            hintText: 'Paste your text here!',
            hintStyle: TextStyle(
                color: Palette.blueGrey.withOpacity(0.5), fontSize: 16),
            errorStyle: TextStyle(color: Palette.red, fontSize: 16),
            counterStyle: TextStyle(color: Palette.blueGrey, fontSize: 16),
            counterText:
                (_value.isNotEmpty ? "Difficulty: $_difficulty  -  " : "") +
                    "${_value.length}/1000",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Config.borderRadius)),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Config.borderRadius),
              borderSide: BorderSide(color: Palette.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Config.borderRadius),
              borderSide: BorderSide(color: Palette.red, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// The button thats starts the test in the [TextInputBox].
class TextInputBoxStartButton extends StatelessWidget {
  /// Called when this button is pressed.
  final Function? onPressed;

  TextInputBoxStartButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
          primary: Palette.blue,
          padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
        ),
        child: Text(
          'GO!',
          style: TextStyle(
            color: Palette.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        onPressed: onPressed as void Function()?,
      ),
    );
  }
}

/// The info text displayed at the bottom of the [TextInputBox].
class TextInputBoxInfoText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 25,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(fontFamily: 'BalooThambi2', color: Palette.blueGrey),
          children: [
            TextSpan(
              text:
                  '©️ TypeTypeGo! 2021 - v${Config.appVersion} - Developed by Jacob Drew 2021 - View the source code on ',
            ),
            TextSpan(
              text: Config.repositoryUrl,
              style: TextStyle(color: Palette.blue, fontFamily: 'BalooThambi2'),
              recognizer: TapGestureRecognizer()
                ..onTap = Tools.openRepositorySite,
            ),
          ],
        ),
      ),
    );
  }
}
