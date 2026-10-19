import 'package:flutter/foundation.dart';

class Logger {
  static void log(Object message) {
    debugPrint(message.toString());
  }
}
