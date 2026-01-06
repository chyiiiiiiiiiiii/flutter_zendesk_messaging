# Events

This directory contains the event system for the Zendesk Messaging plugin. It uses Dart 3's sealed class pattern for type-safe event handling.

## Architecture

```
ZendeskEvent (sealed base class)
├── Core Events
│   ├── UnreadMessageCountChanged
│   ├── AuthenticationFailed
│   ├── FieldValidationFailed
│   ├── ConnectionStatusChanged
│   └── SendMessageFailed
├── Conversation Events
│   ├── ConversationAdded
│   ├── ConversationStarted
│   ├── ConversationOpened
│   ├── MessagesShown
│   ├── ConversationWithAgentRequested
│   ├── ConversationWithAgentAssigned
│   └── ConversationServedByAgent
├── UI Events
│   ├── MessagingOpened
│   ├── MessagingClosed
│   ├── NewConversationButtonClicked
│   ├── PostbackButtonClicked
│   ├── ProactiveMessageDisplayed
│   ├── ProactiveMessageClicked
│   ├── ArticleClicked
│   ├── ArticleBrowserClicked
│   ├── ConversationExtensionOpened
│   └── ConversationExtensionDisplayed
└── Notification Events (Android only)
    ├── NotificationDisplayed
    └── NotificationOpened
```

## Files

| File | Description |
|------|-------------|
| `zendesk_event.dart` | Base sealed class and library definition |
| `core_events.dart` | Authentication, connection, message events |
| `conversation_events.dart` | Conversation lifecycle events |
| `ui_events.dart` | User interface interaction events |
| `notification_events.dart` | Push notification events (Android) |
| `event_parser.dart` | Deserializes native platform data to events |

## Usage

### Basic Event Handling

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount):
      updateBadge(totalUnreadCount);
    case AuthenticationFailed(:final isJwtExpired):
      if (isJwtExpired) refreshToken();
    case ConnectionStatusChanged(:final status):
      updateConnectionUI(status);
    default:
      break;
  }
});
```

### Pattern Matching with Guards

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(totalUnreadCount: var count) when count > 0:
      showNotificationBadge(count);
    case UnreadMessageCountChanged():
      hideNotificationBadge();
    default:
      break;
  }
});
```

### Type Checking

```dart
ZendeskMessaging.eventStream.listen((event) {
  if (event is AuthenticationFailed) {
    handleAuthError(event.errorMessage, event.isJwtExpired);
  }
});
```

## Event Details

### Core Events

| Event | Key Properties | Description |
|-------|----------------|-------------|
| `UnreadMessageCountChanged` | `totalUnreadCount`, `conversationId?` | Unread count changed |
| `AuthenticationFailed` | `errorMessage`, `isJwtExpired` | JWT authentication failed |
| `FieldValidationFailed` | `errors` | Invalid conversation fields |
| `ConnectionStatusChanged` | `status` | SDK connection state changed |
| `SendMessageFailed` | `conversationId?`, `errorMessage` | Message send failed |

### Conversation Events

| Event | Key Properties | Description |
|-------|----------------|-------------|
| `ConversationAdded` | `conversationId` | New conversation created |
| `ConversationStarted` | `conversationId` | User initiated conversation |
| `ConversationOpened` | `conversationId?` | Conversation opened |
| `MessagesShown` | `messages` | Messages displayed to user |
| `ConversationWithAgentRequested` | `conversationId` | User requested agent |
| `ConversationWithAgentAssigned` | `conversationId` | Agent assigned |
| `ConversationServedByAgent` | `conversationId`, `agentId?` | Agent serving |

### UI Events

| Event | Key Properties | Description |
|-------|----------------|-------------|
| `MessagingOpened` | - | Messaging UI opened |
| `MessagingClosed` | - | Messaging UI closed |
| `NewConversationButtonClicked` | - | New conversation button clicked |
| `PostbackButtonClicked` | `actionName` | Postback button clicked |
| `ProactiveMessageDisplayed` | `proactiveMessageId` | Proactive message shown |
| `ProactiveMessageClicked` | `proactiveMessageId` | Proactive message clicked |
| `ArticleClicked` | `articleUrl` | Article clicked |
| `ArticleBrowserClicked` | `articleUrl` | Article opened in browser |

### Notification Events (Android Only)

| Event | Key Properties | Description |
|-------|----------------|-------------|
| `NotificationDisplayed` | `conversationId` | Push notification shown |
| `NotificationOpened` | `conversationId` | Push notification opened |
