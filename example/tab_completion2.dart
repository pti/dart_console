import 'package:dart_console/dart_console.dart';
import 'package:dart_console/src/output_builder.dart';

/// Prompts to read a line of text. Pressing tab iterates through matching words. Matching words are written to the
/// line below the prompt.
void main() {
  final c = Console();
  c.writeLine('<ctrl+c>, <ctrl+d> or q exits');

  Coordinate? markedPosition;
  int? currentRow;

  void markPosition() {
    markedPosition = c.cursorPosition;
  }

  void restorePosition() {
    if (markedPosition != null) {
      c.cursorPosition = markedPosition;
      markedPosition = null;
    }
  }

  void ensureLineBelow() {
    if (c.cursorPosition?.row == c.windowHeight - 1) {
      c.writeLine();
      c.cursorUp();
    }
  }

  void writeBelow(String text) {
    c.hideCursor();
    c.cursorPosition = Coordinate(currentRow! + 1, 0);
    c.eraseLine();
    c.write(text);
    c.showCursor();
  }

  String truncate(String text) {
    final consoleWidth = c.windowWidth;
    if (text.length <= consoleWidth) return text;
    return '${text.substring(0, consoleWidth - 1)}…';
  }

  List<String>? suggestions;
  var selectedSuggestion = 0;

  BufferState? callback(BufferState buffer, Key key) {

    if (key.isControl && (key.controlChar == ControlCharacter.ctrlC || key.controlChar == ControlCharacter.ctrlD)) {
      throw BreakException(key.controlChar, buffer);
    }

    markPosition();

    const completions = ['apple', 'avocado', 'banana', 'blueberry', 'cloudberry', 'lemon', 'lime', 'orange', 'peach', 'pear', 'pineapple', 'pomegranate', 'strawberry', 'watermelon'];
    final word = buffer.text.trim();
    final matching = suggestions ?? completions.where((name) => name.contains(word));
    writeBelow(truncate(matching.join(', ')));
    //writeBelow('text=${buffer.text} index=${buffer.index} key=$key');
    restorePosition();

    if (key.isControl && key.controlChar == ControlCharacter.tab && matching.isNotEmpty) {
      // Tab can be used to iterate through the matching suggestions.
      if (suggestions == null) {
        suggestions = matching.toList();
        selectedSuggestion = 0;
      } else {
        selectedSuggestion = (selectedSuggestion + 1) % suggestions!.length;
      }

      final selected = suggestions![selectedSuggestion];
      return BufferState(selected, selected.length);

    } else {
      suggestions = null;
      return null;
    }
  }

  void resetLine() {
    c.writeLine();
    c.eraseCursorToEnd();
  }

  const prompt = r'fruit> ';
  var colorIndex = 0;

  while (true) {
    try {
      suggestions = null;
      currentRow = c.cursorPosition?.row ?? 0;
      ensureLineBelow();
      c.write(prompt);

      c.showCursor();
      final line = c.readLine(cancelOnBreak: false, cancelOnEOF: false, callback: callback)!;
      c.hideCursor();

      c.eraseLine();

      if (line.toLowerCase() == 'q' || line.toLowerCase() == 'quit') {
        break;
      }

      if (line.isNotEmpty) {
        final fg = 16 + colorIndex;
        final bg = 231 - colorIndex;

        c.write(OutputBuilder()
            //.color(foreground: ConsoleColor.black, background: ConsoleColor.brightYellow)
            .color8bit(foreground: fg, background: bg)
            .write('Read')
            .color(background: ConsoleColor.black, foreground: ConsoleColor.brightWhite)
            .write(' >$line<')
            .newLine()
            .toString());
        c.resetColorAttributes();

        colorIndex = (colorIndex + 1) % 215;
      }

    } on BreakException catch (be) {
      resetLine();

      if (be.buffer.text.isEmpty) {
        break;
      }
    }
  }

  c.eraseCursorToEnd();
  c.resetColorAttributes();
  c.showCursor();
}

class BreakException implements Exception {
  final ControlCharacter controlChar;
  final BufferState buffer;

  BreakException(this.controlChar, this.buffer);
}
