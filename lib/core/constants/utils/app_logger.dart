import 'dart:developer' as dev;

class AppLogger {
  static void info(String message, {String name = 'APP'}) {
    dev.log(message, name: name);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String name = 'APP'}) {
    dev.log(message, name: name, error: error, stackTrace: stackTrace);
  }

  static void api(String message, {Object? error, StackTrace? stackTrace}) {
    dev.log(message, name: 'API', error: error, stackTrace: stackTrace);
  }

  static void navigation(String message) {
    dev.log(message, name: 'NAV');
  }

  static void locator(String message) {
    dev.log(message, name: 'LOCATOR');
  }
}
