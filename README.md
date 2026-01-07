# Zendesk Messaging for Flutter

[![pub package](https://img.shields.io/pub/v/zendesk_messaging.svg)](https://pub.dev/packages/zendesk_messaging)
[![CI](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml/badge.svg)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging/actions/workflows/ci.yml)
[![coverage](https://img.shields.io/badge/coverage-83%25-brightgreen)](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Zendesk Messaging](Messaging.png)

A Flutter plugin for integrating Zendesk Messaging SDK into your mobile applications. Provides in-app customer support messaging with multi-conversation support, real-time events, and JWT authentication.

## Features

- Initialize and display the Zendesk Messaging UI
- JWT user authentication
- Multi-conversation navigation
- Real-time event streaming (24 event types)
- Unread message count tracking
- Conversation tags and custom fields
- Connection status monitoring
- Push notifications support (FCM/APNs)

## Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS | 14.0 |
| Android | API 21 (minSdk) |
| Dart | 3.6.0 |
| Flutter | 3.24.0 |

## Installation

Add `zendesk_messaging` to your `pubspec.yaml`:

```yaml
dependencies:
  zendesk_messaging: ^3.1.0
```

### Android Setup

Add the Zendesk Maven repository to your project-level `android/build.gradle`:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
    }
}
```

### iOS Setup

Update your `ios/Podfile` to target iOS 14.0:

```ruby
platform :ios, '14.0'
```

Then run:

```bash
cd ios && pod install
```

## Quick Start

### Getting Channel Keys

Before initializing the SDK, you need to obtain your Android and iOS channel keys from the Zendesk Admin Center:

1. Go to **Admin Center** > **Channels** > **Messaging and social** > **Messaging**
2. Hover over the brand you want to configure and click the **options icon**
3. Click **Edit** and navigate to the **Installation** section
4. Under **Channel ID**, click **Copy** to copy the key to your clipboard
5. Use this key for both Android and iOS initialization

> **Note:** The same Channel ID is used for both platforms. You can create separate channels for Android and iOS if needed.

### Initialize

```dart
import 'package:zendesk_messaging/zendesk_messaging.dart';

// Initialize the SDK (call once at app startup)
await ZendeskMessaging.initialize(
  androidChannelKey: '<YOUR_ANDROID_CHANNEL_KEY>',
  iosChannelKey: '<YOUR_IOS_CHANNEL_KEY>',
);
```

### Show Messaging UI

```dart
// Show the default messaging interface
await ZendeskMessaging.show();

// Show a specific conversation (requires multi-conversation enabled)
await ZendeskMessaging.showConversation('conversation_id');

// Show the conversation list
await ZendeskMessaging.showConversationList();

// Start a new conversation
await ZendeskMessaging.startNewConversation();
```

### User Authentication

```dart
// Login with JWT
try {
  final response = await ZendeskMessaging.loginUser(jwt: '<YOUR_JWT_TOKEN>');
  print('Logged in: ${response.id}');
} catch (e) {
  print('Login failed: $e');
}

// Check login status
final isLoggedIn = await ZendeskMessaging.isLoggedIn();

// Get current user
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('User ID: ${user.id}');
  print('External ID: ${user.externalId}');
  print('Auth type: ${user.authenticationType.name}');
}

// Logout
await ZendeskMessaging.logoutUser();
```

## Event Handling

The SDK provides a unified event stream for all Zendesk events. Use Dart 3 pattern matching to handle specific event types:

```dart
ZendeskMessaging.eventStream.listen((event) {
  switch (event) {
    case UnreadMessageCountChanged(:final totalUnreadCount, :final conversationId):
      print('Unread: $totalUnreadCount${conversationId != null ? ' (conversation: $conversationId)' : ''}');

    case AuthenticationFailed(:final errorMessage, :final isJwtExpired):
      print('Auth failed: $errorMessage (JWT expired: $isJwtExpired)');
      if (isJwtExpired) {
        // Refresh JWT token
      }

    case ConnectionStatusChanged(:final status):
      print('Connection: ${status.name}');

    case ConversationAdded(:final conversationId):
      print('Conversation added: $conversationId');

    case ConversationStarted(:final conversationId):
      print('Conversation started: $conversationId');

    case ConversationOpened(:final conversationId):
      print('Conversation opened: ${conversationId ?? 'default'}');

    case MessagesShown(:final conversationId, :final messages):
      print('Messages shown: ${messages.length} in $conversationId');

    case SendMessageFailed(:final errorMessage):
      print('Send failed: $errorMessage');

    case FieldValidationFailed(:final errors):
      print('Field validation failed: ${errors.join(', ')}');

    case MessagingOpened():
      print('Messaging UI opened');

    case MessagingClosed():
      print('Messaging UI closed');

    case ProactiveMessageDisplayed(:final proactiveMessageId):
      print('Proactive message displayed: $proactiveMessageId');

    case ProactiveMessageClicked(:final proactiveMessageId):
      print('Proactive message clicked: $proactiveMessageId');

    case ConversationWithAgentRequested(:final conversationId):
      print('Agent requested: $conversationId');

    case ConversationWithAgentAssigned(:final conversationId):
      print('Agent assigned: $conversationId');

    case ConversationServedByAgent(:final conversationId, :final agentId):
      print('Agent serving: $agentId in $conversationId');

    case NewConversationButtonClicked():
      print('New conversation button clicked');

    case PostbackButtonClicked(:final actionName):
      print('Postback clicked: $actionName');

    case ArticleClicked(:final articleUrl):
      print('Article clicked: $articleUrl');

    case ArticleBrowserClicked(:final articleUrl):
      print('Article opened in browser: $articleUrl');

    case ConversationExtensionOpened(:final extensionUrl):
      print('Extension opened: $extensionUrl');

    case ConversationExtensionDisplayed(:final extensionUrl):
      print('Extension displayed: $extensionUrl');

    case NotificationDisplayed(:final conversationId):
      print('Notification displayed: $conversationId');

    case NotificationOpened(:final conversationId):
      print('Notification opened: $conversationId');
  }
});

// Start listening for events
await ZendeskMessaging.listenUnreadMessages();
```

### Available Events

| Event | Description |
|-------|-------------|
| `UnreadMessageCountChanged` | Unread message count changed |
| `AuthenticationFailed` | Authentication failed |
| `ConnectionStatusChanged` | Connection status changed |
| `ConversationAdded` | New conversation created |
| `ConversationStarted` | Conversation initiated |
| `ConversationOpened` | Conversation opened |
| `MessagesShown` | Messages rendered |
| `SendMessageFailed` | Message send failed |
| `FieldValidationFailed` | Field validation failed |
| `MessagingOpened` | Messaging UI opened |
| `MessagingClosed` | Messaging UI closed |
| `ProactiveMessageDisplayed` | Proactive message shown |
| `ProactiveMessageClicked` | Proactive message clicked |
| `ConversationWithAgentRequested` | User requested agent |
| `ConversationWithAgentAssigned` | Agent assigned |
| `ConversationServedByAgent` | Agent serving |
| `NewConversationButtonClicked` | New conversation clicked |
| `PostbackButtonClicked` | Postback button clicked |
| `ArticleClicked` | Article clicked |
| `ArticleBrowserClicked` | Article opened in browser |
| `ConversationExtensionOpened` | Extension opened |
| `ConversationExtensionDisplayed` | Extension displayed |
| `NotificationDisplayed` | Push notification shown |
| `NotificationOpened` | Push notification opened |

## Unread Message Count

```dart
// Get current count
final count = await ZendeskMessaging.getUnreadMessageCount();

// Get count for specific conversation
final convCount = await ZendeskMessaging.getUnreadMessageCountForConversation('conv_id');

// Listen to count changes (legacy API)
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('Unread: $count');
});
```

## Conversation Tags & Fields

```dart
// Set tags (applied when user sends a message)
await ZendeskMessaging.setConversationTags(['vip', 'mobile', 'flutter']);

// Clear tags
await ZendeskMessaging.clearConversationTags();

// Set custom fields
await ZendeskMessaging.setConversationFields({
  'app_version': '3.0.0',
  'platform': 'flutter',
  'user_tier': 'premium',
});

// Clear fields
await ZendeskMessaging.clearConversationFields();
```

## Connection Status

```dart
final status = await ZendeskMessaging.getConnectionStatus();

// Handle different connection states
final color = switch (status) {
  ZendeskConnectionStatus.connected ||
  ZendeskConnectionStatus.connectedRealtime => Colors.green,
  ZendeskConnectionStatus.connectingRealtime => Colors.orange,
  ZendeskConnectionStatus.disconnected => Colors.red,
  ZendeskConnectionStatus.unknown => Colors.grey,
};
```

## Push Notifications

Enable push notifications to notify users of new messages when the app is in the background or closed.

### Requirements

| Platform | Requirement |
|----------|-------------|
| Android | Firebase Cloud Messaging (FCM) setup |
| iOS | APNs certificate uploaded to Zendesk Admin Center |
| Both | Real device (simulators don't support push) |

### Setup

#### Android

1. Add Firebase to your Android app ([Firebase setup guide](https://firebase.google.com/docs/android/setup))
2. Add `firebase_messaging` to your `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_messaging: ^15.0.0
   ```
3. Get your FCM Server Key from Firebase Console
4. Upload the key to Zendesk Admin Center > Channels > Messaging > Android > Notifications

#### iOS

1. Create an APNs certificate in Apple Developer Portal
2. Export as `.p12` file from Keychain Access
3. Upload to Zendesk Admin Center > Channels > Messaging > iOS > Notifications
4. Add Push Notifications capability in Xcode

### Usage

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

Future<void> setupPushNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission
  await messaging.requestPermission();

  // Get and register token
  final token = await messaging.getToken();
  if (token != null) {
    await ZendeskMessaging.updatePushNotificationToken(token);
  }

  // Listen for token refresh
  messaging.onTokenRefresh.listen((token) {
    ZendeskMessaging.updatePushNotificationToken(token);
  });

  // Handle foreground notifications
  FirebaseMessaging.onMessage.listen((message) async {
    final responsibility = await ZendeskMessaging.shouldBeDisplayed(message.data);
    switch (responsibility) {
      case ZendeskPushResponsibility.messagingShouldDisplay:
        await ZendeskMessaging.handleNotification(message.data);
      case ZendeskPushResponsibility.notFromMessaging:
        // Handle your own notification
        break;
      default:
        break;
    }
  });

  // Handle notification tap (app in background)
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    await ZendeskMessaging.handleNotificationTap(message.data);
  });
}
```

### Push Notification API

| Method | Returns | Description |
|--------|---------|-------------|
| `updatePushNotificationToken(token)` | `Future<void>` | Register FCM/APNs token with Zendesk |
| `shouldBeDisplayed(data)` | `Future<ZendeskPushResponsibility>` | Check if notification is from Zendesk |
| `handleNotification(data)` | `Future<bool>` | Display the notification |
| `handleNotificationTap(data)` | `Future<void>` | Handle notification tap |

### ZendeskPushResponsibility

| Value | Description |
|-------|-------------|
| `messagingShouldDisplay` | Zendesk notification, SDK can display it |
| `messagingShouldNotDisplay` | Zendesk notification, but should not display (e.g., user is viewing the conversation) |
| `notFromMessaging` | Not a Zendesk notification, handle it yourself |
| `unknown` | Unable to determine |

## SDK Lifecycle

```dart
// Check if SDK is initialized
final isInit = await ZendeskMessaging.isInitialized();

// Invalidate SDK instance (cleanup)
await ZendeskMessaging.invalidate();
// After invalidate, you must call initialize() again to use the SDK
```

## API Reference

### ZendeskMessaging

| Method | Returns | Description |
|--------|---------|-------------|
| `initialize(androidChannelKey, iosChannelKey)` | `Future<void>` | Initialize the SDK |
| `isInitialized()` | `Future<bool>` | Check if SDK is initialized |
| `invalidate()` | `Future<void>` | Invalidate SDK instance |
| `show()` | `Future<void>` | Show messaging UI |
| `showConversation(id)` | `Future<void>` | Show specific conversation |
| `showConversationList()` | `Future<void>` | Show conversation list |
| `startNewConversation()` | `Future<void>` | Start new conversation |
| `loginUser(jwt)` | `Future<ZendeskLoginResponse>` | Login with JWT |
| `logoutUser()` | `Future<void>` | Logout current user |
| `isLoggedIn()` | `Future<bool>` | Check login status |
| `getCurrentUser()` | `Future<ZendeskUser?>` | Get current user info |
| `getUnreadMessageCount()` | `Future<int>` | Get total unread count |
| `getUnreadMessageCountForConversation(id)` | `Future<int>` | Get unread count for conversation |
| `listenUnreadMessages()` | `Future<void>` | Start listening for events |
| `setConversationTags(tags)` | `Future<void>` | Set conversation tags |
| `clearConversationTags()` | `Future<void>` | Clear conversation tags |
| `setConversationFields(fields)` | `Future<void>` | Set custom fields |
| `clearConversationFields()` | `Future<void>` | Clear custom fields |
| `getConnectionStatus()` | `Future<ZendeskConnectionStatus>` | Get connection status |
| `updatePushNotificationToken(token)` | `Future<void>` | Register push token |
| `shouldBeDisplayed(data)` | `Future<ZendeskPushResponsibility>` | Check notification source |
| `handleNotification(data)` | `Future<bool>` | Handle push notification |
| `handleNotificationTap(data)` | `Future<void>` | Handle notification tap |

### Streams

| Stream | Type | Description |
|--------|------|-------------|
| `eventStream` | `Stream<ZendeskEvent>` | All Zendesk events |
| `unreadMessagesCountStream` | `Stream<int>` | Unread count changes (legacy) |

### Models

**ZendeskUser**
```dart
class ZendeskUser {
  String? id;
  String? externalId;
  ZendeskAuthenticationType authenticationType;
}
```

**ZendeskLoginResponse**
```dart
class ZendeskLoginResponse {
  String? id;
  String? externalId;
}
```

**ZendeskMessage**
```dart
class ZendeskMessage {
  String id;
  String conversationId;
  String? authorId;
  String? content;
  DateTime? timestamp;
}
```

### Enums

**ZendeskAuthenticationType**
- `anonymous`
- `jwt`

**ZendeskConnectionStatus**
- `connected`
- `connectedRealtime`
- `connectingRealtime`
- `disconnected`
- `unknown`

**ZendeskPushResponsibility**
- `messagingShouldDisplay`
- `messagingShouldNotDisplay`
- `notFromMessaging`
- `unknown`

## Migration from 2.x

### Breaking Changes in 3.0.0

1. **iOS 14.0 minimum** - Apps targeting iOS 12/13 must upgrade
2. **Dart 3.6+ required** - Update your SDK constraint
3. **Flutter 3.24+ required** - Update your Flutter SDK
4. **New event API** - Use sealed class pattern for type-safe event handling

### Migration Steps

1. Update `pubspec.yaml`:
```yaml
environment:
  sdk: ^3.6.0
  flutter: ">=3.24.0"
```

2. Update iOS Podfile:
```ruby
platform :ios, '14.0'
```

3. Update event handling (optional but recommended):
```dart
// Old way (still works)
ZendeskMessaging.unreadMessagesCountStream.listen((count) {
  print('Unread: $count');
});

// New way (recommended)
ZendeskMessaging.eventStream.listen((event) {
  if (event is UnreadMessageCountChanged) {
    print('Unread: ${event.totalUnreadCount}');
  }
});
```

## Troubleshooting

### iOS Build Fails

Ensure your Podfile has the correct platform version:
```ruby
platform :ios, '14.0'
```

Then run:
```bash
cd ios && pod install --repo-update
```

### Android Build Fails

Ensure the Zendesk Maven repository is added:
```gradle
maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
```

### Events Not Received

Make sure to call `listenUnreadMessages()` after initialization:
```dart
await ZendeskMessaging.initialize(...);
await ZendeskMessaging.listenUnreadMessages();
```

## SDK Versions

| Plugin | Android SDK | iOS SDK |
|--------|-------------|---------|
| 3.1.0 | 2.36.1 | 2.36.0 |
| 3.0.0 | 2.36.1 | 2.36.0 |
| 2.9.x | 2.26.0 | 2.24.0 |

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please read the contributing guidelines before submitting a pull request.

## Links

- [GitHub Repository](https://github.com/chyiiiiiiiiiiii/flutter_zendesk_messaging)
- [Zendesk Android SDK Docs](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/getting_started/)
- [Zendesk iOS SDK Docs](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/ios/getting_started/)
- [Working with Messaging for Mobile Channels](https://support.zendesk.com/hc/en-us/articles/4408834810394-Working-with-messaging-for-your-mobile-channel)
