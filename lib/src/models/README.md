# Models

This directory contains data models used throughout the Zendesk Messaging plugin.

## Files

### zendesk_user.dart

Represents a Zendesk user.

```dart
class ZendeskUser {
  final String? id;                              // Zendesk internal user ID
  final String? externalId;                      // External ID from JWT
  final ZendeskAuthenticationType authenticationType;  // anonymous or jwt
}
```

**Usage:**
```dart
final user = await ZendeskMessaging.getCurrentUser();
if (user != null) {
  print('User ID: ${user.id}');
  print('External ID: ${user.externalId}');
  print('Auth Type: ${user.authenticationType.name}');
}
```

### zendesk_login_response.dart

Response from a successful login operation.

```dart
class ZendeskLoginResponse {
  final String? id;          // Zendesk internal user ID
  final String? externalId;  // External ID from JWT
}
```

**Usage:**
```dart
try {
  final response = await ZendeskMessaging.loginUser(jwt: token);
  print('Logged in as: ${response.id}');
} catch (e) {
  print('Login failed: $e');
}
```

### zendesk_message.dart

Represents a single message in a conversation.

```dart
class ZendeskMessage {
  final String id;               // Unique message ID
  final String conversationId;   // Parent conversation ID
  final String? authorId;        // Author (user or agent) ID
  final String? content;         // Message text content
  final DateTime? timestamp;     // When message was received
}
```

**Usage:**
```dart
ZendeskMessaging.eventStream.listen((event) {
  if (event is MessagesShown) {
    for (final message in event.messages) {
      print('${message.authorId}: ${message.content}');
    }
  }
});
```

## Common Features

All models include:

- **Factory constructor**: `fromMap()` for deserializing native platform data
- **Equality**: `==` operator and `hashCode` for comparison
- **String representation**: `toString()` for debugging

## Barrel Export

The `models.dart` file provides a barrel export for all models:

```dart
import 'package:zendesk_messaging/src/models/models.dart';
```
