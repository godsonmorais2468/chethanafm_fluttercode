import 'dart:developer';
import 'package:flutter/foundation.dart';

class Debug {
  static void trace(dynamic object, {String status = 'info', bool isError = false, bool isSuccess = false}) {
    if (kDebugMode) {
      // Get the color based on the status
      String color = _getColorByStatus(status);

      // Customize the log message with color
      String coloredMessage = _colorize(object.toString(), color);

      // Print using the log function
      log(coloredMessage);

      // Optionally log errors separately
      if (isError) {
        localLogWriter(coloredMessage, isError: true);
      } else {
        localLogWriter(coloredMessage);
      }
    }
  }

  static String _getColorByStatus(String status) {
    final Map<String, String> statusColors = {
      'error': 'red',
      'success': 'green',
      'info': 'cyan',
      'warning': 'yellow',
    };

    // Default to 'info' if status is unknown
    return statusColors[status] ?? 'white';
  }

  static String _colorize(String message, String color) {
    const String resetColor = '\x1B[0m'; // Reset color
    final Map<String, String> colorCodes = {
      'red': '\x1B[31m',
      'green': '\x1B[32m',
      'yellow': '\x1B[33m',
      'blue': '\x1B[34m',
      'magenta': '\x1B[35m',
      'cyan': '\x1B[36m',
      'white': '\x1B[37m',
    };

    // If the color is not in the map, default to white
    String selectedColor = colorCodes[color] ?? colorCodes['white']!;
    return '$selectedColor$message$resetColor';
  }
}

void localLogWriter(String text, {bool isError = false}) {
  // Implement your favorite logging system here
  // This could write to a file, send logs to a server, etc.
  // Just make sure to handle the 'isError' flag as needed.
}
