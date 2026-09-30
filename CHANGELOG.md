## 3.6.0

### Behavior Changes

- **iOS**: `invalidate()` now clears the SDK's local storage (user data,
  conversations and cache), matching Android. Previously the iOS SDK was
  invalidated with `clearStorage: false`, so the previous user's data and
  conversation history stayed on the device after `logoutUser()` +
  `invalidate()` and could show up for the next user. Android's
  `Zendesk.invalidate()` has no option to keep data, so behavior is now the
  same on both platforms. Apps that relied on iOS keeping anonymous
  conversations across `invalidate()` will now start with a new anonymous
  user (#107, #108).

### Documentation

- **iOS**: `setLocale()` docs now say the new locale applies from the next app
  launch. iOS reads `AppleLanguages` only at launch, so the previously
  documented `invalidate()` + `initialize()` flow did not switch the language
  at runtime (#105, #109).

## 3.5.0

### Dependencies

- **iOS**: Update `ZendeskSDKMessaging` from 2.36.0 to 2.39.0 (CocoaPods and
  Swift Package Manager). Picks up the SDK fixes for the JWT-expiration check
  that could leave the app loading forever (2.36.1) and for client data being
  cleared unexpectedly (2.37.0). The minimum iOS version is unchanged; 2.40.0
  is deliberately skipped because it raises the SDK's minimum to iOS 16.
- **Android**: Update `messaging-android` from 2.36.1 to 2.40.0. The SDK is now
  built with Kotlin 2.2.21, so apps need Kotlin 2.1 or later.

## 3.4.0

### New Features

- **iOS**: Add Swift Package Manager (SPM) support (#100). The plugin now ships
  a `Package.swift` alongside the existing podspec, so apps that have migrated
  to SPM can depend on it. CocoaPods remains fully supported — both dependency
  managers resolve the same `ZendeskSDKMessaging` 2.36.0 native SDK, so existing
  CocoaPods users are unaffected and no app changes are required.

## 3.3.0

### New Features

- **Locale**: Add `setLocale(locale)` to override the Zendesk messaging UI
  language at runtime (#97).
  - Android: Sets `Locale.setDefault()` and updates the application/activity
    resource configuration. Can switch at runtime before launching the UI.
  - iOS: Sets the `AppleLanguages` user default for SDK localization. Set it
    **before** `initialize()`; to change after, call `invalidate()` then
    `initialize()` again.

### Build

- **Android**: Migrate to Flutter's built-in Kotlin so the plugin builds with
  Android Gradle Plugin (AGP) 9+ (#104). The Kotlin Gradle Plugin is now applied
  only on AGP < 9, and the deprecated `kotlinOptions` block is replaced by the
  `kotlin.compilerOptions` DSL. Apps on AGP < 9 are unaffected.

## 3.2.3

### Bug Fixes

- **iOS**: Parse the APNs device token as hex before forwarding to
  `PushNotifications.updatePushNotificationToken`. The previous code used
  `token.data(using: .utf8)`, which produced the UTF-8 bytes of the hex
  string instead of the 32-byte device token, so Zendesk registered a
  malformed token and never delivered iOS push.
- **Android**: Use the application context (stored in `onAttachedToEngine`)
  for `handleNotification` instead of the Activity. The Activity is null in a
  background isolate / terminated state, so the previous code bailed with
  `no_context` and background pushes never displayed.
  `PushNotifications.displayNotification` only needs a `Context`.
- **Android**: Guard `initialize` against a null Activity to return a clean
  error instead of a `NullPointerException`. Push display does not require
  `initialize`; it uses `shouldBeDisplayed` / `handleNotification`.

### Documentation

- Correct the push notification token usage in all README translations and the
  `updatePushNotificationToken` API doc. On iOS, pass the APNs device token
  from `getAPNSToken()`, not the FCM token from `getToken()` — using the FCM
  token on iOS silently fails to deliver push. Token retrieval is now split per
  platform, and `onTokenRefresh` is guarded to Android (iOS APNs tokens are
  re-fetched on launch).
- Document that `showConversation` should be called once per navigation. Rapid
  duplicate calls can make the underlying SDK open the default conversation
  instead of the requested one, so callers that may fire more than once for a
  single user action (e.g. a notification tap reaching multiple handlers) should
  de-duplicate.

## 3.2.2

### Bug Fixes

- **iOS**: Resolve root view controller from active scene for UISceneDelegate apps (#94)

## 3.2.1

### Documentation

- Add multi-language README support
  - 繁體中文 (Traditional Chinese)
  - 简体中文 (Simplified Chinese)
  - Español (Spanish)
  - Português (Brasil) (Portuguese)
  - 日本語 (Japanese)
  - 한국어 (Korean)
- Fix image URL for pub.dev compatibility (use absolute GitHub raw URL)

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