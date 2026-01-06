# Enums

This directory contains enumeration types used throughout the Zendesk Messaging plugin.

## Files

### authentication_type.dart

Defines user authentication states.

```dart
enum ZendeskAuthenticationType {
  anonymous,  // User not authenticated with JWT
  jwt,        // User authenticated with JWT token
}
```

**Usage:**
```dart
final user = await ZendeskMessaging.getCurrentUser();
if (user?.authenticationType == ZendeskAuthenticationType.jwt) {
  print('User is authenticated');
}
```

### connection_status.dart

Defines SDK connection states.

```dart
enum ZendeskConnectionStatus {
  connected,     // SDK connected to server
  connecting,    // SDK attempting to connect
  disconnected,  // SDK disconnected from server
  unknown,       // Connection status unknown
}
```

**Usage:**
```dart
final status = await ZendeskMessaging.getConnectionStatus();
switch (status) {
  case ZendeskConnectionStatus.connected:
    print('Online');
  case ZendeskConnectionStatus.disconnected:
    print('Offline');
  default:
    break;
}
```

## Barrel Export

The `enums.dart` file provides a barrel export for all enums:

```dart
import 'package:zendesk_messaging/src/enums/enums.dart';
```
