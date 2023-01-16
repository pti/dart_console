import 'package:dart_console/dart_console.dart';

final console = Console.scrolling();

final commands = ['java', 'dart', 'pascal', 'delphi'];
String? completeCommand(String buffer) {
  if (buffer.isEmpty) return null;
  for (final command in commands) {
    if (command.startsWith(buffer) && buffer.length < command.length) {
      return command;
    }
  }
  return null;
}

String? suggestedCompletion;
String? completion(String text, Key lastPressed) {
  if (lastPressed.isControl) {
    final completion = suggestedCompletion;
    suggestedCompletion = null;
    if (lastPressed.controlChar == ControlCharacter.tab && completion != null) {
      // Write remaining characters to the screen.
      console.write(completion.substring(text.length));
      // Let the `Console.readLine()` API know the replacement text.
      return completion;
    }
    return null;
  }

  final int prefixStart = text.lastIndexOf(' ');
  var completion = completeCommand(text.substring(prefixStart + 1));
  if (completion != null) {
    if (prefixStart >= 0) {
      completion = text.substring(0, prefixStart) + ' ' + completion;
    }

    suggestedCompletion = completion;

    // Write the text that can be tab-completed in different color.
    final old = console.cursorPosition;
    console.setForegroundColor(ConsoleColor.brightWhite);
    console.write(completion.substring(text.length));
    console.cursorPosition = old;

    // Reset color to what it used to be.
    console.setForegroundColor(ConsoleColor.brightGreen);
  }

  return null;
}

void main() {
  while (true) {
    console.setForegroundColor(ConsoleColor.brightBlue);
    console.write('>>> ');
    console.resetColorAttributes();
    console.setForegroundColor(ConsoleColor.brightGreen);
    final response = console.readLine(cancelOnEOF: true, callback: completion);

    if (response == null) break;
    print(response.toUpperCase());
  }
}
