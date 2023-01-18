import 'package:dart_console/dart_console.dart';
import 'package:dart_console/src/ansi.dart';

class OutputBuilder {
  final buffer = StringBuffer();

  OutputBuilder();

  OutputBuilder write(String str) {
    if (str.isNotEmpty) buffer.write(str);
    return this;
  }

  OutputBuilder color({ConsoleColor? foreground, ConsoleColor? background}) {

    if (foreground != null && background != null) {
      buffer.write('\x1b[${foreground.foregroundCode};${background.backgroundCode}m');
    }

    if (foreground != null) this.foreground(foreground);
    if (background != null) this.background(background);
    return this;
  }

  /// Valid color code values are 0-255.
  /// - 0-15:  standard colors (same as in [ConsoleColor]).
  /// - 16-231: 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (0 ≤ r, g, b ≤ 5)
  /// - 232-255: grayscale from dark to light in 24 steps.
  /// https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit
  OutputBuilder color8bit({int? foreground, int? background}) {
    assert(foreground == null || foreground >= 0 && foreground < 256);
    assert(background == null || background >= 0 && background < 256);
    if (foreground != null) buffer.write(ansiSetExtendedForegroundColor(foreground));
    if (background != null) buffer.write(ansiSetExtendedBackgroundColor(background));
    return this;
  }

  OutputBuilder foreground(ConsoleColor color) {
    buffer.write(color.ansiSetForegroundColorSequence);
    return this;
  }

  OutputBuilder background(ConsoleColor color) {
    buffer.write(color.ansiSetBackgroundColorSequence);
    return this;
  }

  OutputBuilder resetColor() {
    buffer.write(ansiResetColor);
    return this;
  }

  OutputBuilder newLine() {
    buffer.write('\n');
    return this;
  }

  @override
  String toString() => buffer.toString();

  void reset() {
    buffer.clear();
  }
}
