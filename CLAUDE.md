# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Flutter plugin for integrating Zendesk Messaging SDK into mobile applications. This is a federated plugin with platform-specific implementations for Android (Kotlin) and iOS (Swift).

**Current Version**: 3.0.0
**SDK Versions**: Android 2.36.1, iOS 2.36.0

## Development Commands

### Run Tests
```bash
flutter test                           # Run all tests
flutter test test/zendesk_event_test.dart  # Run specific test file
```

### Analyze Code
```bash
flutter analyze
```

### Run Example App
```bash
cd example
flutter run
```

### iOS Setup
```bash
cd example/ios && pod install --repo-update
```

## Architecture

### Plugin Structure
```
lib/
├── zendesk_messaging.dart           # Library exports
└── src/
    ├── zendesk_messaging.dart       # Main API (MethodChannel communication)
    ├── zendesk_messaging_config.dart # Logging configuration
    ├── events/
    │   ├── zendesk_event.dart       # Sealed class hierarchy for events
    │   ├── event_parser.dart        # Deserializes native events
    │   ├── core_events.dart         # Auth, connection events (part file)
    │   ├── conversation_events.dart # Conversation events (part file)
    │   ├── ui_events.dart           # UI interaction events (part file)
    │   └── notification_events.dart # Push notification events (part file)
    ├── enums/
    │   ├── authentication_type.dart
    │   └── connection_status.dart
    └── models/
        ├── zendesk_user.dart
        ├── zendesk_message.dart
        └── zendesk_login_response.dart
```

### Native Implementations
- **Android**: `android/src/main/kotlin/com/chyiiiiiiiiiiiiii/zendesk_messaging/`
  - `ZendeskMessagingPlugin.kt` - Method channel handler
  - `ZendeskMessaging.kt` - Zendesk SDK wrapper and event handling
- **iOS**: `ios/Classes/`
  - `SwiftZendeskMessagingPlugin.swift` - Method channel handler
  - `ZendeskMessaging.swift` - Zendesk SDK wrapper and event handling

### Event System
The plugin uses a sealed class hierarchy (`ZendeskEvent`) enabling exhaustive pattern matching. Events flow from native SDKs through the `zendesk_event` method channel and are parsed by `ZendeskEventParser`.

Two event channels exist:
1. `unread_messages` - Legacy callback for backwards compatibility
2. `zendesk_event` - New unified event system (24 event types)

### Method Channel
Single channel named `zendesk_messaging` handles all communication between Dart and native code. Methods require SDK initialization before use (except `initialize` and `isInitialized`).

## Key Patterns

### Sealed Classes for Events
All Zendesk events extend the sealed `ZendeskEvent` base class, enabling Dart 3 exhaustive pattern matching:
```dart
switch (event) {
  case UnreadMessageCountChanged(:final totalUnreadCount):
    // Handle event
  case AuthenticationFailed(:final isJwtExpired):
    // Handle event
}
```

### Dual Stream Support
Both `unreadMessagesCountStream` (legacy) and `eventStream` (new) are maintained for backwards compatibility. The `_onMethodCall` handler emits to both streams when appropriate.

### Platform-Specific Channel Keys
`initialize()` accepts both `androidChannelKey` and `iosChannelKey`, selecting the appropriate key based on `Platform.isAndroid`.

## Platform Requirements

| Platform | Minimum Version |
|----------|----------------|
| iOS | 14.0 |
| Android | API 21 (minSdk) |
| Dart | 3.6.0 |
| Flutter | 3.24.0 |

## Android Configuration

Add Zendesk Maven repository in `android/build.gradle`:
```gradle
maven { url 'https://zendesk.jfrog.io/artifactory/repo' }
```

## iOS Configuration

Set platform in `ios/Podfile`:
```ruby
platform :ios, '14.0'
```
