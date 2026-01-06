import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'enums/connection_status.dart';
import 'enums/push_responsibility.dart';
import 'events/event_parser.dart';
import 'events/zendesk_event.dart';
import 'models/zendesk_login_response.dart';
import 'models/zendesk_user.dart';
import 'zendesk_messaging_config.dart';

/// Zendesk Messaging SDK Flutter Plugin.
///
/// Provides access to Zendesk Messaging functionality including:
/// - User authentication (login/logout)
/// - Messaging UI display
/// - Multi-conversation navigation
/// - Unread message count tracking
/// - Event streams for various SDK events
/// - Conversation tags and fields
///
/// ## Quick Start
///
/// ```dart
/// // Initialize
/// await ZendeskMessaging.initialize(
///   androidChannelKey: 'your_android_key',
///   iosChannelKey: 'your_ios_key',
/// );
///
/// // Show messaging UI
/// await ZendeskMessaging.show();
///
/// // Listen to events
/// ZendeskMessaging.eventStream.listen((event) {
///   // Handle events
/// });
/// ```
///
/// ## Error Handling
///
/// All methods that can fail will throw exceptions. Wrap calls in try-catch:
///
/// ```dart
/// try {
///   await ZendeskMessaging.loginUser(jwt: token);
/// } catch (e) {
///   // Handle error
/// }
/// ```
///
/// ## Logging
///
/// Configure logging via [ZendeskMessagingConfig]:
///
/// ```dart
/// ZendeskMessagingConfig.enableLogging = true;
/// ```
class ZendeskMessaging {
  ZendeskMessaging._();

  static const MethodChannel _channel = MethodChannel('zendesk_messaging');

  // Stream controllers
  static final StreamController<int> _unreadMessagesCountController =
      StreamController<int>.broadcast();
  static final StreamController<ZendeskEvent> _eventController =
      StreamController<ZendeskEvent>.broadcast();

  /// Stream of unread message count changes.
  ///
  /// This is a legacy API maintained for backwards compatibility.
  /// For new code, prefer using [eventStream] and listening for
  /// [UnreadMessageCountChanged] events.
  static Stream<int> get unreadMessagesCountStream =>
      _unreadMessagesCountController.stream;

  /// Stream of all Zendesk events.
  ///
  /// Listen to this stream to receive all events from the Zendesk SDK.
  /// Use pattern matching to handle specific event types:
  ///
  /// ```dart
  /// ZendeskMessaging.eventStream.listen((event) {
  ///   switch (event) {
  ///     case UnreadMessageCountChanged(:final totalUnreadCount):
  ///       print('Unread: $totalUnreadCount');
  ///     case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
  ///       if (isJwtExpired) refreshToken();
  ///     case ConnectionStatusChanged(:final status):
  ///       print('Connection: $status');
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  static Stream<ZendeskEvent> get eventStream => _eventController.stream;

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize the Zendesk SDK.
  ///
  /// Must be called before any other ZendeskMessaging methods.
  ///
  /// [androidChannelKey] The Android SDK key from Zendesk Admin Center.
  /// [iosChannelKey] The iOS SDK key from Zendesk Admin Center.
  ///
  /// Throws [ArgumentError] if channel keys are empty.
  /// Throws [PlatformException] if initialization fails.
  ///
  /// Example:
  /// ```dart
  /// await ZendeskMessaging.initialize(
  ///   androidChannelKey: 'your_android_key',
  ///   iosChannelKey: 'your_ios_key',
  /// );
  /// ```
  static Future<void> initialize({
    required String androidChannelKey,
    required String iosChannelKey,
  }) async {
    if (androidChannelKey.isEmpty || iosChannelKey.isEmpty) {
      throw ArgumentError('Channel keys cannot be empty');
    }

    try {
      _channel.setMethodCallHandler(_onMethodCall);
      await _channel.invokeMethod('initialize', {
        'channelKey': Platform.isAndroid ? androidChannelKey : iosChannelKey,
      });
      ZendeskMessagingConfig.log('SDK initialized successfully');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'initialize failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if the Zendesk SDK is initialized.
  ///
  /// Returns `true` if initialized, `false` otherwise.
  static Future<bool> isInitialized() async {
    try {
      final result = await _channel.invokeMethod<bool>('isInitialized');
      return result ?? false;
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'isInitialized failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Invalidate the current Zendesk SDK instance.
  ///
  /// After calling this method, [initialize] must be called again before
  /// using any other ZendeskMessaging methods.
  ///
  /// Throws [PlatformException] if invalidation fails.
  static Future<void> invalidate() async {
    try {
      await _channel.invokeMethod('invalidate');
      ZendeskMessagingConfig.log('SDK invalidated');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'invalidate failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ============================================================================
  // UI Navigation
  // ============================================================================

  /// Show the Zendesk Messaging UI.
  ///
  /// Opens the default messaging interface. If multi-conversations is enabled,
  /// navigates to the most recent conversation.
  ///
  /// Throws [PlatformException] if the UI cannot be shown.
  static Future<void> show() async {
    try {
      await _channel.invokeMethod('show');
      ZendeskMessagingConfig.log('Messaging UI shown');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'show failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Show a specific conversation.
  ///
  /// [conversationId] The ID of the conversation to display.
  ///
  /// Requires multi-conversations to be enabled in Zendesk Admin Center.
  ///
  /// Throws [ArgumentError] if conversationId is empty.
  /// Throws [PlatformException] if the conversation cannot be shown.
  static Future<void> showConversation(String conversationId) async {
    if (conversationId.isEmpty) {
      throw ArgumentError('conversationId cannot be empty');
    }

    try {
      await _channel.invokeMethod('showConversation', {
        'conversationId': conversationId,
      });
      ZendeskMessagingConfig.log('Showing conversation: $conversationId');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'showConversation failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Show the conversation list.
  ///
  /// Displays the list of all conversations for the current user.
  /// Requires multi-conversations to be enabled in Zendesk Admin Center.
  ///
  /// Throws [PlatformException] if the list cannot be shown.
  static Future<void> showConversationList() async {
    try {
      await _channel.invokeMethod('showConversationList');
      ZendeskMessagingConfig.log('Conversation list shown');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'showConversationList failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Start a new conversation.
  ///
  /// Opens the messaging UI to begin a new conversation.
  /// Requires multi-conversations to be enabled in Zendesk Admin Center.
  ///
  /// Throws [PlatformException] if a new conversation cannot be started.
  static Future<void> startNewConversation() async {
    try {
      await _channel.invokeMethod('startNewConversation');
      ZendeskMessagingConfig.log('New conversation started');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'startNewConversation failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ============================================================================
  // Authentication
  // ============================================================================

  /// Login a user with JWT authentication.
  ///
  /// [jwt] A valid JWT token generated by your backend.
  ///
  /// Returns a [ZendeskLoginResponse] containing user information.
  ///
  /// Throws [ArgumentError] if jwt is empty.
  /// Throws [PlatformException] if login fails.
  ///
  /// Example:
  /// ```dart
  /// final response = await ZendeskMessaging.loginUser(jwt: token);
  /// print('Logged in as: ${response.id}');
  /// ```
  static Future<ZendeskLoginResponse> loginUser({required String jwt}) async {
    if (jwt.isEmpty) {
      throw ArgumentError('JWT cannot be empty');
    }

    try {
      final result = await _channel.invokeMethod('loginUser', {'jwt': jwt});
      final arguments = result == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(result);
      ZendeskMessagingConfig.log('User logged in');
      return ZendeskLoginResponse.fromMap(arguments);
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'loginUser failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Logout the current user.
  ///
  /// Clears user authentication and session data.
  ///
  /// Throws [PlatformException] if logout fails.
  static Future<void> logoutUser() async {
    try {
      await _channel.invokeMethod('logoutUser');
      ZendeskMessagingConfig.log('User logged out');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'logoutUser failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if a user is currently logged in.
  ///
  /// Returns `true` if logged in, `false` otherwise.
  static Future<bool> isLoggedIn() async {
    try {
      final result = await _channel.invokeMethod<bool>('isLoggedIn');
      return result ?? false;
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'isLoggedIn failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get the current user information.
  ///
  /// Returns a [ZendeskUser] if a user is available, or `null` otherwise.
  static Future<ZendeskUser?> getCurrentUser() async {
    try {
      final result = await _channel.invokeMethod('getCurrentUser');
      if (result == null) return null;
      return ZendeskUser.fromMap(Map<String, dynamic>.from(result));
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'getCurrentUser failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ============================================================================
  // Messages
  // ============================================================================

  /// Get the total unread message count.
  ///
  /// Returns the number of unread messages across all conversations.
  static Future<int> getUnreadMessageCount() async {
    try {
      final result = await _channel.invokeMethod<int>('getUnreadMessageCount');
      return result ?? 0;
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'getUnreadMessageCount failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get unread message count for a specific conversation.
  ///
  /// [conversationId] The ID of the conversation.
  ///
  /// Returns the number of unread messages in the specified conversation.
  ///
  /// Throws [ArgumentError] if conversationId is empty.
  static Future<int> getUnreadMessageCountForConversation(
    String conversationId,
  ) async {
    if (conversationId.isEmpty) {
      throw ArgumentError('conversationId cannot be empty');
    }

    try {
      final result = await _channel.invokeMethod<int>(
        'getUnreadMessageCountForConversation',
        {'conversationId': conversationId},
      );
      return result ?? 0;
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'getUnreadMessageCountForConversation failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Start listening for unread message count changes and other events.
  ///
  /// After calling this method, events will be emitted to both
  /// [unreadMessagesCountStream] (legacy) and [eventStream] (new).
  ///
  /// This method should be called after [initialize].
  static Future<void> listenUnreadMessages() async {
    try {
      await _channel.invokeMethod('listenUnreadMessages');
      ZendeskMessagingConfig.log('Event listener started');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'listenUnreadMessages failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ============================================================================
  // Conversation Data
  // ============================================================================

  /// Set conversation tags.
  ///
  /// Tags are applied when the user starts a new conversation or sends a message.
  ///
  /// [tags] List of tags to apply to conversations.
  ///
  /// Throws [ArgumentError] if tags list is empty.
  static Future<void> setConversationTags(List<String> tags) async {
    if (tags.isEmpty) {
      throw ArgumentError('tags cannot be empty');
    }

    try {
      await _channel.invokeMethod('setConversationTags', {'tags': tags});
      ZendeskMessagingConfig.log('Conversation tags set: $tags');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'setConversationTags failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all conversation tags.
  static Future<void> clearConversationTags() async {
    try {
      await _channel.invokeMethod('clearConversationTags');
      ZendeskMessagingConfig.log('Conversation tags cleared');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'clearConversationTags failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Set conversation fields.
  ///
  /// Fields are applied when the user starts a new conversation or sends a message.
  /// Fields must be configured as custom ticket fields in Zendesk Admin Center.
  ///
  /// [fields] Map of field IDs to values.
  ///
  /// Throws [ArgumentError] if fields map is empty.
  static Future<void> setConversationFields(Map<String, String> fields) async {
    if (fields.isEmpty) {
      throw ArgumentError('fields cannot be empty');
    }

    try {
      await _channel.invokeMethod('setConversationFields', {'fields': fields});
      ZendeskMessagingConfig.log('Conversation fields set');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'setConversationFields failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Clear all conversation fields.
  static Future<void> clearConversationFields() async {
    try {
      await _channel.invokeMethod('clearConversationFields');
      ZendeskMessagingConfig.log('Conversation fields cleared');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'clearConversationFields failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ============================================================================
  // Connection
  // ============================================================================

  /// Get the current connection status.
  ///
  /// Returns the SDK's current connection state.
  ///
  /// **Important**: Connection status is only available after the SDK has
  /// established a connection. The status will be [ZendeskConnectionStatus.unknown]
  /// until one of these actions triggers a connection:
  ///
  /// - Opening the Messaging UI via [show], [showConversation], etc.
  /// - Logging in a user via [loginUser]
  /// - Having an active conversation
  /// - Network state changes while connected
  ///
  /// For real-time connection status updates, listen to [eventStream] for
  /// [ConnectionStatusChanged] events instead of polling this method.
  ///
  /// Example:
  /// ```dart
  /// final status = await ZendeskMessaging.getConnectionStatus();
  /// if (status == ZendeskConnectionStatus.unknown) {
  ///   // No connection has been established yet
  /// }
  /// ```
  static Future<ZendeskConnectionStatus> getConnectionStatus() async {
    try {
      final result = await _channel.invokeMethod<String>('getConnectionStatus');
      return ZendeskConnectionStatus.fromString(result);
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'getConnectionStatus failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ============================================================================
  // Push Notifications
  // ============================================================================

  /// Update the push notification token with Zendesk.
  ///
  /// Call this method when you receive a new FCM token (Android) or
  /// APNs device token (iOS) to enable push notifications.
  ///
  /// [token] The push notification token string.
  /// - Android: FCM token from FirebaseMessaging.instance.getToken()
  /// - iOS: APNs device token converted to string
  ///
  /// Throws [ArgumentError] if token is empty.
  /// Throws [PlatformException] if the update fails.
  ///
  /// Example:
  /// ```dart
  /// // Android with firebase_messaging
  /// final fcmToken = await FirebaseMessaging.instance.getToken();
  /// if (fcmToken != null) {
  ///   await ZendeskMessaging.updatePushNotificationToken(fcmToken);
  /// }
  ///
  /// // Listen for token refresh
  /// FirebaseMessaging.instance.onTokenRefresh.listen((token) {
  ///   ZendeskMessaging.updatePushNotificationToken(token);
  /// });
  /// ```
  static Future<void> updatePushNotificationToken(String token) async {
    if (token.isEmpty) {
      throw ArgumentError('token cannot be empty');
    }

    try {
      await _channel.invokeMethod('updatePushNotificationToken', {
        'token': token,
      });
      ZendeskMessagingConfig.log('Push notification token updated');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'updatePushNotificationToken failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Check if a push notification payload is from Zendesk.
  ///
  /// Use this method to determine whether an incoming push notification
  /// should be handled by the Zendesk SDK.
  ///
  /// [messageData] The notification data payload.
  ///
  /// Returns a [ZendeskPushResponsibility] indicating how to handle the notification:
  /// - [ZendeskPushResponsibility.messagingShouldDisplay]: Zendesk notification, SDK can display it
  /// - [ZendeskPushResponsibility.messagingShouldNotDisplay]: Zendesk notification, but should not display
  /// - [ZendeskPushResponsibility.notFromMessaging]: Not a Zendesk notification
  ///
  /// Example:
  /// ```dart
  /// FirebaseMessaging.onMessage.listen((message) async {
  ///   final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
  ///   switch (responsibility) {
  ///     case ZendeskPushResponsibility.messagingShouldDisplay:
  ///       // Let Zendesk handle it
  ///       await ZendeskMessaging.handleNotification(message.data);
  ///     case ZendeskPushResponsibility.notFromMessaging:
  ///       // Handle your own notification
  ///       showLocalNotification(message);
  ///     default:
  ///       break;
  ///   }
  /// });
  /// ```
  static Future<ZendeskPushResponsibility> shouldBeDisplayed(
    Map<String, dynamic> messageData,
  ) async {
    try {
      final result = await _channel.invokeMethod<String>('shouldBeDisplayed', {
        'messageData': messageData,
      });
      return ZendeskPushResponsibility.fromString(result);
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'shouldBeDisplayed failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Handle and display an incoming push notification.
  ///
  /// Call this method when you receive a push notification that should be
  /// handled by Zendesk. The SDK will display the notification appropriately
  /// based on the app state.
  ///
  /// [messageData] The notification data payload.
  ///
  /// Returns `true` if the notification was handled by Zendesk, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// FirebaseMessaging.onMessage.listen((message) async {
  ///   final handled = await ZendeskMessaging.handleNotification(message.data);
  ///   if (!handled) {
  ///     // Not a Zendesk notification, handle it yourself
  ///   }
  /// });
  /// ```
  static Future<bool> handleNotification(
    Map<String, dynamic> messageData,
  ) async {
    try {
      final result = await _channel.invokeMethod<bool>('handleNotification', {
        'messageData': messageData,
      });
      ZendeskMessagingConfig.log('Notification handled: $result');
      return result ?? false;
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'handleNotification failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Handle a notification tap event.
  ///
  /// Call this method when the user taps on a Zendesk push notification
  /// to navigate to the appropriate conversation.
  ///
  /// [messageData] The notification data payload.
  ///
  /// **Note**: On iOS, when the app is in a killed state, this may not
  /// navigate to the conversation as the SDK is not initialized.
  ///
  /// Example:
  /// ```dart
  /// FirebaseMessaging.onMessageOpenedApp.listen((message) async {
  ///   await ZendeskMessaging.handleNotificationTap(message.data);
  /// });
  /// ```
  static Future<void> handleNotificationTap(
    Map<String, dynamic> messageData,
  ) async {
    try {
      await _channel.invokeMethod('handleNotificationTap', {
        'messageData': messageData,
      });
      ZendeskMessagingConfig.log('Notification tap handled');
    } catch (e, stackTrace) {
      ZendeskMessagingConfig.logError(
        'handleNotificationTap failed',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  // ============================================================================
  // Method Channel Handler
  // ============================================================================

  static Future<dynamic> _onMethodCall(MethodCall call) async {
    final method = call.method;
    final arguments = call.arguments != null
        ? Map<String, dynamic>.from(call.arguments)
        : <String, dynamic>{};

    switch (method) {
      case 'unread_messages':
        // Legacy callback for backwards compatibility
        final count = arguments['messages_count'] as int?;
        _unreadMessagesCountController.add(count ?? 0);

      case 'zendesk_event':
        // New event system
        final event = ZendeskEventParser.parse(arguments);
        if (event != null) {
          _eventController.add(event);

          // Also emit to legacy stream for backwards compatibility
          if (event is UnreadMessageCountChanged) {
            _unreadMessagesCountController.add(event.totalUnreadCount);
          }
        }
    }
  }
}
