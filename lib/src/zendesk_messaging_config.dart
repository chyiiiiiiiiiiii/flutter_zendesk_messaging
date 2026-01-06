import 'package:flutter/foundation.dart';

/// Signature for custom logger functions.
///
/// [message] is the log message.
/// [error] is the optional error object associated with the log.
/// [stackTrace] is the optional stack trace.
typedef ZendeskLogger = void Function(
  String message, {
  Object? error,
  StackTrace? stackTrace,
});

/// Configuration for [ZendeskMessaging].
///
/// Use this class to configure logging behavior and other global settings.
///
/// Example:
/// ```dart
/// // Enable logging (default in debug mode)
/// ZendeskMessagingConfig.enableLogging = true;
///
/// // Use custom logger
/// ZendeskMessagingConfig.logger = (message, {error, stackTrace}) {
///   MyCustomLogger.log(message, error: error);
/// };
///
/// // Disable logging in production
/// ZendeskMessagingConfig.enableLogging = false;
/// ```
class ZendeskMessagingConfig {
  ZendeskMessagingConfig._();

  static const String _tag = 'ZendeskMessaging';

  /// Whether debug logging is enabled.
  ///
  /// Defaults to `true` in debug mode ([kDebugMode]), `false` in release.
  static bool enableLogging = kDebugMode;

  /// Custom logger callback.
  ///
  /// If set, this function will be called instead of the default [debugPrint].
  /// Set to `null` to use the default logger.
  static ZendeskLogger? logger;

  /// Log a debug message.
  ///
  /// This method respects [enableLogging] and [logger] settings.
  static void log(String message, {Object? error, StackTrace? stackTrace}) {
    if (!enableLogging) return;

    final fullMessage = '[$_tag] $message';

    if (logger case final logger?) {
      logger(fullMessage, error: error, stackTrace: stackTrace);
    } else {
      if (error case final error?) {
        debugPrint('$fullMessage: $error');
        if (stackTrace case final stackTrace?) {
          debugPrint(stackTrace.toString());
        }
      } else {
        debugPrint(fullMessage);
      }
    }
  }

  /// Log an error message.
  ///
  /// Always logs regardless of [enableLogging] setting if the error is serious.
  /// For routine errors, use [log] instead.
  static void logError(
    String message, {
    required Object error,
    StackTrace? stackTrace,
  }) {
    log(message, error: error, stackTrace: stackTrace);
  }
}
