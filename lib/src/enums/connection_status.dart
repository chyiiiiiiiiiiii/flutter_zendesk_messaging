/// Connection status of the Zendesk SDK.
///
/// Maps to native SDK values:
/// - iOS: `ZendeskConnectionStatus` enum
/// - Android: `ConnectionStatus` enum
///
/// ## When Connection Status Events Are Triggered
///
/// The Zendesk SDK only reports connection status after establishing a
/// connection. Events are triggered when:
///
/// 1. **Opening Messaging UI** - Calling `show()`, `showConversation()`,
///    `showConversationList()`, or `startNewConversation()`
/// 2. **User Authentication** - Calling `loginUser()` with a JWT
/// 3. **Active Conversation** - When there's an ongoing conversation
/// 4. **Network Changes** - When network connectivity changes while connected
///
/// Until one of these actions occurs, the status will remain [unknown].
///
/// ## Recommended Usage
///
/// Instead of polling `getConnectionStatus()`, listen to the event stream:
///
/// ```dart
/// ZendeskMessaging.eventStream.listen((event) {
///   if (event is ConnectionStatusChanged) {
///     print('Connection status: ${event.status}');
///   }
/// });
/// ```
enum ZendeskConnectionStatus {
  /// SDK is disconnected from the server.
  disconnected,

  /// SDK is connected to the server.
  connected,

  /// SDK is connecting to realtime services.
  connectingRealtime,

  /// SDK is connected to realtime services.
  connectedRealtime,

  /// Connection status is unknown.
  ///
  /// This is the initial state before any connection has been established.
  /// The SDK does not report connection status until the user interacts
  /// with the messaging UI or logs in.
  unknown;

  /// Parse connection status from string.
  ///
  /// Returns [unknown] if the value is null or not recognized.
  static ZendeskConnectionStatus fromString(String? value) {
    if (value == null) return ZendeskConnectionStatus.unknown;
    return switch (value.toLowerCase()) {
      'disconnected' => ZendeskConnectionStatus.disconnected,
      'connected' => ZendeskConnectionStatus.connected,
      'connectingrealtime' => ZendeskConnectionStatus.connectingRealtime,
      'connectedrealtime' => ZendeskConnectionStatus.connectedRealtime,
      // Android uses RECONNECTING
      'reconnecting' => ZendeskConnectionStatus.connectingRealtime,
      _ => ZendeskConnectionStatus.unknown,
    };
  }
}
