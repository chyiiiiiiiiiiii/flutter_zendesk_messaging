/// Zendesk Messaging SDK Flutter Plugin.
///
/// A Flutter plugin for integrating Zendesk Messaging SDK into your mobile
/// applications. Provides in-app customer support messaging with
/// multi-conversation support, real-time events, and JWT authentication.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:zendesk_messaging/zendesk_messaging.dart';
///
/// // Initialize
/// await ZendeskMessaging.initialize(
///   androidChannelKey: 'your_android_key',
///   iosChannelKey: 'your_ios_key',
/// );
///
/// // Show messaging UI
/// await ZendeskMessaging.show();
/// ```
///
/// ## Event Handling
///
/// ```dart
/// ZendeskMessaging.eventStream.listen((event) {
///   switch (event) {
///     case UnreadMessageCountChanged(:final totalUnreadCount):
///       print('Unread: $totalUnreadCount');
///     case AuthenticationFailed(:final isJwtExpired):
///       if (isJwtExpired) refreshToken();
///     default:
///       break;
///   }
/// });
///
/// await ZendeskMessaging.listenUnreadMessages();
/// ```
///
/// ## Logging Configuration
///
/// ```dart
/// // Enable/disable logging
/// ZendeskMessagingConfig.enableLogging = true;
///
/// // Use custom logger
/// ZendeskMessagingConfig.logger = (message, {error, stackTrace}) {
///   MyLogger.log(message, error: error);
/// };
/// ```
library zendesk_messaging;

// Enums
export 'src/enums/authentication_type.dart';
export 'src/enums/connection_status.dart';

// Models
export 'src/models/zendesk_login_response.dart';
export 'src/models/zendesk_message.dart';
export 'src/models/zendesk_user.dart';

// Events (zendesk_event.dart includes all event classes via part files)
export 'src/events/zendesk_event.dart';
export 'src/events/event_parser.dart';

// Config
export 'src/zendesk_messaging_config.dart';

// Main API
export 'src/zendesk_messaging.dart';
