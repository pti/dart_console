import 'dart:math';

import 'package:dart_console/dart_console.dart';
import 'package:dart_console/src/output_builder.dart';

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

BufferState? completion(BufferState buffer, Key lastPressed) {
  // Start from index-1 in case currently at a space character position.
  var wordStart = buffer.text.lastIndexOf(' ', max(buffer.index - 1, 0));
  if (wordStart < buffer.index) wordStart += 1; // Skip the space.
  final word = buffer.text.substring(wordStart, buffer.index);
  final completed = completeCommand(word);

  if (completed == null) {
    return null;
  }

  if (lastPressed.isControl && lastPressed.controlChar == ControlCharacter.tab) {
    final newIndex = wordStart + completed.length;
    final newText = buffer.text.substring(0, wordStart) + completed + buffer.text.substring(buffer.index);
    return BufferState(newText, newIndex);
  }

  // Write the text that can be tab-completed in different color.
  final output = OutputBuilder()
    .write(buffer.text.substring(0, buffer.index))
    .foreground(ConsoleColor.brightWhite)
    .write(completed.substring(word.length))
    .foreground(ConsoleColor.brightGreen)
    .write(buffer.text.substring(buffer.index))
    .toString();
  return BufferState(buffer.text, buffer.index, output);
}

void main() {
  const prompt = '>>> ';

  while (true) {
    console.setForegroundColor(ConsoleColor.brightBlue);
    console.write(prompt);
    console.resetColorAttributes();
    console.setForegroundColor(ConsoleColor.brightGreen);
    final response = console.readLine(cancelOnEOF: true, callback: completion, startColumn: prompt.length);

    if (response == null) break;
    print(response.toUpperCase());
  }
}
