# Source Code Structure

This directory contains the core implementation of the Zendesk Messaging Flutter plugin.

## Directory Structure

```
src/
├── enums/              # Enumeration types
├── events/             # Event system (sealed classes)
├── models/             # Data models
├── zendesk_messaging.dart        # Main plugin API
└── zendesk_messaging_config.dart # Configuration & logging
```

## Files

### zendesk_messaging.dart

The main entry point for the plugin. Provides the `ZendeskMessaging` class with all public APIs:

- **Initialization**: `initialize()`, `isInitialized()`, `invalidate()`
- **UI Navigation**: `show()`, `showConversation()`, `showConversationList()`, `startNewConversation()`
- **Authentication**: `loginUser()`, `logoutUser()`, `isLoggedIn()`, `getCurrentUser()`
- **Messages**: `getUnreadMessageCount()`, `listenUnreadMessages()`
- **Conversation Data**: `setConversationTags()`, `setConversationFields()`
- **Connection**: `getConnectionStatus()`
- **Streams**: `eventStream`, `unreadMessagesCountStream`

### zendesk_messaging_config.dart

Global configuration for the plugin:

- `enableLogging` - Enable/disable debug logging
- `logger` - Custom logger callback
- `log()` / `logError()` - Internal logging methods

## Architecture

```
┌─────────────────────────────────────────────────┐
│              ZendeskMessaging                    │
│         (Static API + MethodChannel)            │
├─────────────────────────────────────────────────┤
│  eventStream          │  unreadMessagesCountStream │
│  (ZendeskEvent)       │  (int) - Legacy            │
├───────────────────────┴─────────────────────────┤
│              ZendeskEventParser                  │
│         (Native data → ZendeskEvent)            │
├─────────────────────────────────────────────────┤
│     Models     │     Enums      │    Events     │
│  ZendeskUser   │ ConnectionStatus│ 24 event types │
│  ZendeskMessage│ AuthenticationType│             │
└─────────────────────────────────────────────────┘
```

## Usage

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// Initialize
await ZendeskMessaging.initialize(
  androidChannelKey: 'key',
  iosChannelKey: 'key',
);

// Listen to events
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount):
      print('Unread: $totalUnreadCount');
    default:
      break;
  }
});

// Show messaging UI
await ZendeskMessaging.show();
```
