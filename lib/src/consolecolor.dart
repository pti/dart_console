// enums.dart

// Externally exposed enumerations used by the `Console` class.

// TODO: Update this with an enhanced enum that includes RGB and 256-color
// values, and returns a string to enable and a string to disable.

enum ConsoleColor {
  /// The named ANSI colors.
  black(30, 40),
  red(31, 41),
  green(32, 42),
  yellow(33, 43),
  blue(34, 44),
  magenta(35, 45),
  cyan(36, 46),
  white(37, 47),
  brightBlack(90, 100),
  brightRed(91, 101),
  brightGreen(92, 102),
  brightYellow(93, 103),
  brightBlue(94, 104),
  brightMagenta(95, 105),
  brightCyan(96, 106),
  brightWhite(97, 107);

  final int foregroundCode;
  final int backgroundCode;

  const ConsoleColor(this.foregroundCode, this.backgroundCode);

  String get ansiSetForegroundColorSequence => '\x1b[${foregroundCode}m';
  String get ansiSetBackgroundColorSequence => '\x1b[${backgroundCode}m';
}
