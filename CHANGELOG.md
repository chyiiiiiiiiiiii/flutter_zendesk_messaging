## 3.2.0

### Breaking Changes

- **Flutter SDK**: >=3.24.0 -> >=3.27.0

### Improvements

- Add GitHub Actions CI workflow with automated testing
- Expand unit test coverage for plugin APIs
- Update README documentation

## 3.1.0

### New Features

- **Push Notifications Support**
  - `updatePushNotificationToken(token)` - Register FCM/APNs token with Zendesk
  - `shouldBeDisplayed(data)` - Check if notification is from Zendesk messaging
  - `handleNotification(data)` - Display Zendesk push notification
  - `handleNotificationTap(data)` - Handle notification tap and navigate to conversation
  - `ZendeskPushResponsibility` enum - Notification classification (messagingShouldDisplay, messagingShouldNotDisplay, notFromMessaging)

### Implementation Details

- Android: Uses official `PushNotifications` class from Zendesk SDK
- iOS: Uses official `PushNotifications` class with `handleTap` completion handler
- Follows official Zendesk SDK documentation patterns

## 3.0.0

### Breaking Changes

- **iOS minimum version**: 12.0 -> 14.0
- **Dart SDK**: ^3.0.0 -> ^3.6.0
- **Flutter SDK**: >=3.10.0 -> >=3.24.0

### Native SDK Updates

- Android SDK: 2.26.0 -> 2.36.1
- iOS SDK: 2.24.0 -> 2.36.0
- Kotlin: 1.9.24 -> 2.1.21
- Swift: 5.9

### New Features

- **Full Event System**: 24 event types via sealed class pattern
  - `UnreadMessageCountChanged` - unread count changes with conversation details
  - `AuthenticationFailed` - auth errors with JWT expiration detection
  - `ConnectionStatusChanged` - network state monitoring
  - `ConversationAdded`, `ConversationStarted`, `ConversationOpened` - conversation lifecycle
  - `MessagesShown` - messages rendered with message data
  - `SendMessageFailed` - message send failures
  - `FieldValidationFailed` - conversation field validation errors
  - `MessagingOpened`, `MessagingClosed` - UI lifecycle
  - `ProactiveMessageDisplayed`, `ProactiveMessageClicked` - proactive messaging
  - `ConversationWithAgentRequested`, `ConversationWithAgentAssigned`, `ConversationServedByAgent` - agent events
  - `NewConversationButtonClicked`, `PostbackButtonClicked` - UI interactions
  - `ArticleClicked`, `ArticleBrowserClicked` - article events
  - `ConversationExtensionOpened`, `ConversationExtensionDisplayed` - extension events
  - `NotificationDisplayed`, `NotificationOpened` - push notification events (Android)

- **Multi-Conversation Navigation**
  - `showConversation(conversationId)` - navigate to specific conversation
  - `showConversationList()` - display conversation list
  - `startNewConversation()` - start new conversation directly
  - `getUnreadMessageCountForConversation(conversationId)` - per-conversation count

- **User Management**
  - `getCurrentUser()` - get current user with auth type
  - `ZendeskUser` model with id, externalId, authenticationType
  - `ZendeskAuthenticationType` enum (anonymous, jwt)

- **Connection Status**
  - `getConnectionStatus()` - get SDK connection state
  - `ZendeskConnectionStatus` enum (connected, connecting, disconnected, unknown)

- **New Models**
  - `ZendeskUser` - user information
  - `ZendeskMessage` - message data with id, conversationId, authorId, content, timestamp
  - `ZendeskLoginResponse` - login response data
  - `ZendeskEvent` sealed class hierarchy

### Improvements

- Modern Dart 3.x syntax with sealed classes and pattern matching
- Comprehensive API documentation
- Unit tests for method channels and event parsing
- Enhanced example app with all features demonstrated
- Backwards compatible `unreadMessagesCountStream` for legacy code

### Migration Guide

See README.md for detailed migration instructions from 2.x.

## 2.9.3

* Update Dart SDK minimum version to 3.0.0 .
* Update Flutter SDK minimum version to 3.10.0 .
* Fix method channel calls never complete.

## 2.9.2

* Fix multi conversation navigation

## 2.9.1

* recover namespace setting for android

## 2.9.0

* fix issue for logoutUser in iOS
* upgrade ios version to 2.24.0
* downgrade android version to 2.13.0

## 2.8.0

* Upgrade zendesk-messaging sdk version to 2.16.0
* Minimum iOS version is now 12
* ADD conversation fields

## 2.7.7

* Add ```invalidate()``` to invalidate the current instance of ZendeskMessaging

## 2.7.6

* Add conversation tag

## 2.7.5

* Upgrade Flutter sdk version
* Upgrade zendesk-messaging sdk version to 2.11.0

## 2.7.4

* Upgrade ZendeskSDKMessaging of iOS to v2.9.0 to be compatible with Xcode 14.3

## 2.7.3

* Fix parameter type issue of handler function

## 2.7.2

* Upgrade Dart sdk version

## 2.6.0+1

* Update versions of environment

## 2.6.0

* Upgrade to 2.6.0

## 0.0.3

* Upgrade to 2.5.0
## 0.0.2

* Authentication
* Global observer
## 0.0.1

* Initial release