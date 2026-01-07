# @add-test

**Comprehensive Testing for Flutter Plugin Development**

Quick reference for adding unit tests to the Zendesk Messaging Flutter plugin. Focus on MethodChannel communication, event parsing, and model serialization.

---

## Project Overview

This is a **Flutter Plugin** for Zendesk Messaging SDK with:
- **MethodChannel** communication with native platforms
- **Sealed class hierarchy** for events (24+ event types)
- **Platform-specific** implementations (Android Kotlin / iOS Swift)
- **No external state management** (no Riverpod, no Bloc)

---

## Testing Mindset

### Before Writing ANY Test, Ask:

1. **What MethodChannel calls are involved?** - Verify correct method names, arguments
2. **What native responses are expected?** - Mock realistic return values
3. **What edge cases exist?** - Empty strings, null values, malformed data
4. **What error conditions?** - Platform exceptions, argument validation
5. **What serialization is needed?** - fromMap, toMap, JSON parsing

### Impact Analysis (Do This First)

```markdown
## Impact Analysis for: {filename}

### Direct Impact
- [ ] What MethodChannel methods were changed?
- [ ] What event types were added/modified?
- [ ] What model fields were changed?

### Native Platform Impact
- [ ] Did method signatures change?
- [ ] Did return types change?
- [ ] Are both Android and iOS updated?

### Consumer Impact
- [ ] What public API methods changed?
- [ ] Are stream events affected?
- [ ] Is backwards compatibility maintained?
```

---

## Test File Structure

```
test/
├── zendesk_messaging_test.dart    # MethodChannel API tests
├── zendesk_event_test.dart        # Event parsing & model tests
├── helpers/                       # (future) Test utilities
│   ├── method_channel_mocks.dart
│   └── test_data_builders.dart
└── integration/                   # (future) Integration tests
```

Test file naming: `{filename}_test.dart`
- `lib/src/zendesk_messaging.dart` -> `test/zendesk_messaging_test.dart`
- `lib/src/events/event_parser.dart` -> `test/zendesk_event_test.dart`

---

## Quick Test Templates by Change Type

### 1. **MethodChannel API Changed** (`zendesk_messaging.dart`)

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('zendesk_messaging');
  final List<MethodCall> log = [];

  setUp(() {
    log.clear();
    ZendeskMessagingConfig.enableLogging = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      return _handleMockMethodCall(methodCall);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NewMethod', () {
    test('sends correct method name and arguments', () async {
      await ZendeskMessaging.newMethod(param: 'value');

      expect(log, hasLength(1));
      expect(log.first.method, 'newMethod');
      expect(log.first.arguments['param'], 'value');
    });

    test('throws ArgumentError for invalid input', () async {
      expect(
        () => ZendeskMessaging.newMethod(param: ''),
        throwsArgumentError,
      );
    });

    test('returns correct type from native response', () async {
      final result = await ZendeskMessaging.newMethod(param: 'test');

      expect(result, isA<ExpectedType>());
      expect(result.field, expectedValue);
    });
  });
}

dynamic _handleMockMethodCall(MethodCall methodCall) {
  switch (methodCall.method) {
    case 'newMethod':
      return {'field': 'expectedValue'};
    // Add other method handlers...
    default:
      return null;
  }
}
```

#### Key Patterns for MethodChannel Tests:

```dart
// 1. Verify method name sent to native
expect(log.first.method, 'methodName');

// 2. Verify arguments structure
expect(log.first.arguments, isA<Map>());
expect(log.first.arguments['key'], expectedValue);

// 3. Verify return type parsing
final result = await ZendeskMessaging.method();
expect(result, isA<ExpectedType>());

// 4. Verify ArgumentError validation
expect(
  () => ZendeskMessaging.method(param: ''),
  throwsArgumentError,
);

// 5. Verify PlatformException handling (optional)
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(channel, (call) async {
  throw PlatformException(code: 'ERROR', message: 'Test error');
});
expect(() => ZendeskMessaging.method(), throwsA(isA<PlatformException>()));
```

---

### 2. **Event Parsing Changed** (`event_parser.dart`, `*_events.dart`)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  group('ZendeskEventParser', () {
    test('NewEventType parses correctly with all fields', () {
      final data = {
        'type': 'newEventType',
        'timestamp': 1704067200000,
        'requiredField': 'value',
        'optionalField': 'optional_value',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<NewEventType>());
      final typedEvent = event as NewEventType;
      expect(typedEvent.requiredField, 'value');
      expect(typedEvent.optionalField, 'optional_value');
      expect(typedEvent.timestamp, isA<DateTime>());
    });

    test('NewEventType parses with missing optional fields', () {
      final data = {
        'type': 'newEventType',
        'timestamp': 1704067200000,
        'requiredField': 'value',
        // optionalField omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<NewEventType>());
      final typedEvent = event as NewEventType;
      expect(typedEvent.requiredField, 'value');
      expect(typedEvent.optionalField, isNull);
    });

    test('NewEventType handles null required field with default', () {
      final data = {
        'type': 'newEventType',
        'timestamp': 1704067200000,
        // requiredField omitted - should use default
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<NewEventType>());
      final typedEvent = event as NewEventType;
      expect(typedEvent.requiredField, ''); // Default empty string
    });
  });
}
```

#### Key Patterns for Event Tests:

```dart
// 1. Test all fields parse correctly
expect(event.field, expectedValue);

// 2. Test optional fields with null
expect(event.optionalField, isNull);

// 3. Test default values for missing fields
expect(event.fieldWithDefault, defaultValue);

// 4. Test timestamp parsing
expect(event.timestamp, isA<DateTime>());

// 5. Test unknown event type returns null
final unknown = ZendeskEventParser.parse({'type': 'unknownType'});
expect(unknown, isNull);

// 6. Test null data returns null
expect(ZendeskEventParser.parse(null), isNull);

// 7. Test pattern matching works
switch (event) {
  case NewEventType(:final requiredField):
    expect(requiredField, 'value');
  default:
    fail('Expected NewEventType');
}
```

---

### 3. **Model Changed** (`zendesk_*.dart` in models/)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  group('NewModel', () {
    test('creates instance with all fields', () {
      const model = NewModel(
        id: 'model_123',
        name: 'Test Model',
        optionalField: 'optional',
      );

      expect(model.id, 'model_123');
      expect(model.name, 'Test Model');
      expect(model.optionalField, 'optional');
    });

    test('creates instance with null optional fields', () {
      const model = NewModel(
        id: 'model_123',
        name: 'Test Model',
        optionalField: null,
      );

      expect(model.id, 'model_123');
      expect(model.optionalField, isNull);
    });

    test('fromMap creates model correctly', () {
      final model = NewModel.fromMap({
        'id': 'model_123',
        'name': 'Test Model',
        'optionalField': 'optional',
      });

      expect(model.id, 'model_123');
      expect(model.name, 'Test Model');
      expect(model.optionalField, 'optional');
    });

    test('fromMap handles missing optional fields', () {
      final model = NewModel.fromMap({
        'id': 'model_123',
        'name': 'Test Model',
        // optionalField missing
      });

      expect(model.id, 'model_123');
      expect(model.optionalField, isNull);
    });

    test('equality works correctly', () {
      const model1 = NewModel(id: '123', name: 'Test');
      const model2 = NewModel(id: '123', name: 'Test');
      const model3 = NewModel(id: '456', name: 'Test');

      expect(model1, equals(model2));
      expect(model1, isNot(equals(model3)));
    });

    test('hashCode is consistent', () {
      const model1 = NewModel(id: '123', name: 'Test');
      const model2 = NewModel(id: '123', name: 'Test');

      expect(model1.hashCode, equals(model2.hashCode));
    });

    test('toString returns readable format', () {
      const model = NewModel(id: '123', name: 'Test');

      expect(model.toString(), contains('123'));
      expect(model.toString(), contains('Test'));
    });
  });
}
```

---

### 4. **Enum Changed** (`enums/*.dart`)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  group('NewEnumType', () {
    test('value1 parses correctly', () {
      expect(
        NewEnumType.fromString('value1'),
        NewEnumType.value1,
      );
    });

    test('value2 parses correctly', () {
      expect(
        NewEnumType.fromString('value2'),
        NewEnumType.value2,
      );
    });

    test('unknown string returns default value', () {
      expect(
        NewEnumType.fromString('invalid'),
        NewEnumType.unknown, // or default value
      );
    });

    test('null string returns default value', () {
      expect(
        NewEnumType.fromString(null),
        NewEnumType.unknown, // or default value
      );
    });

    // If enum has aliases (like 'reconnecting' -> 'connectingRealtime')
    test('alias maps to correct enum value', () {
      expect(
        NewEnumType.fromString('alias'),
        NewEnumType.targetValue,
      );
    });
  });
}
```

---

### 5. **Stream/Event Handler Changed**

```dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('zendesk_messaging');

  setUp(() {
    ZendeskMessagingConfig.enableLogging = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Event Stream', () {
    test('eventStream emits parsed events', () async {
      // Initialize to set up method call handler
      await ZendeskMessaging.initialize(
        androidChannelKey: 'test_key',
        iosChannelKey: 'test_key',
      );

      // Listen to event stream
      final events = <ZendeskEvent>[];
      final subscription = ZendeskMessaging.eventStream.listen(events.add);

      // Simulate native event callback
      // Note: This requires access to the internal method handler
      // In practice, you may need to test this via integration tests

      await subscription.cancel();
    });

    test('unreadMessagesCountStream emits count updates', () async {
      final counts = <int>[];
      final subscription = ZendeskMessaging.unreadMessagesCountStream.listen(counts.add);

      // Simulate events...

      await subscription.cancel();
    });
  });
}
```

---

## Required Test Scenarios

### For Every MethodChannel Method:

| Scenario | Priority | Description |
|----------|----------|-------------|
| Happy Path | Required | Method sends correct name and arguments |
| Return Value | Required | Native response parsed correctly |
| Argument Validation | Required | Invalid inputs throw ArgumentError |
| Empty Input | Required | Empty strings/lists throw ArgumentError |
| Null Handling | Required | Null responses handled gracefully |
| Platform Exception | Optional | Native errors propagate correctly |

### For Every Event Type:

| Scenario | Priority | Description |
|----------|----------|-------------|
| Full Parse | Required | All fields parse correctly |
| Optional Fields | Required | Missing optional fields handled |
| Default Values | Required | Missing required fields use defaults |
| Timestamp | Required | Timestamp parses to DateTime |
| Type Matching | Required | Pattern matching works correctly |

### For Every Model:

| Scenario | Priority | Description |
|----------|----------|-------------|
| Construction | Required | All constructors work |
| fromMap | Required | Deserialization works |
| Equality | Required | == operator works correctly |
| HashCode | Required | hashCode is consistent |
| Optional Fields | Required | Null optionals handled |

### For Every Enum:

| Scenario | Priority | Description |
|----------|----------|-------------|
| Each Value | Required | All known values parse |
| Unknown String | Required | Unknown returns default |
| Null String | Required | Null returns default |
| Aliases | If applicable | Aliases map correctly |

---

## Complete Event Type Reference

When adding tests for events, ensure you cover all 24+ event types in the sealed class hierarchy:

### Core Events
- `UnreadMessageCountChanged` - totalUnreadCount, conversationId?, conversationUnreadCount?
- `AuthenticationFailed` - errorCode, errorMessage, isJwtExpired
- `FieldValidationFailed` - errors (List<String>)
- `ConnectionStatusChanged` - status (ZendeskConnectionStatus)
- `SendMessageFailed` - conversationId?, errorMessage

### Conversation Events
- `ConversationAdded` - conversationId
- `ConversationStarted` - conversationId
- `ConversationOpened` - conversationId?
- `MessagesShown` - conversationId, messages (List<ZendeskMessage>)
- `ConversationWithAgentRequested` - conversationId
- `ConversationWithAgentAssigned` - conversationId
- `ConversationServedByAgent` - conversationId, agentId?

### UI Events
- `MessagingOpened` - (no additional fields)
- `MessagingClosed` - (no additional fields)
- `NewConversationButtonClicked` - (no additional fields)
- `PostbackButtonClicked` - conversationId, actionName
- `ProactiveMessageDisplayed` - proactiveMessageId, campaignId?
- `ProactiveMessageClicked` - proactiveMessageId, campaignId?
- `ArticleClicked` - articleUrl, conversationId?
- `ArticleBrowserClicked` - articleUrl
- `ConversationExtensionOpened` - conversationId, extensionUrl
- `ConversationExtensionDisplayed` - conversationId, extensionUrl

### Notification Events
- `NotificationDisplayed` - conversationId
- `NotificationOpened` - conversationId

---

## MethodChannel Method Reference

Current methods in `ZendeskMessaging`:

| Method | Arguments | Returns |
|--------|-----------|---------|
| `initialize` | channelKey | void |
| `isInitialized` | - | bool |
| `invalidate` | - | void |
| `show` | - | void |
| `showConversation` | conversationId | void |
| `showConversationList` | - | void |
| `startNewConversation` | - | void |
| `loginUser` | jwt | Map (ZendeskLoginResponse) |
| `logoutUser` | - | void |
| `isLoggedIn` | - | bool |
| `getCurrentUser` | - | Map? (ZendeskUser) |
| `getUnreadMessageCount` | - | int |
| `getUnreadMessageCountForConversation` | conversationId | int |
| `listenUnreadMessages` | - | void |
| `setConversationTags` | tags | void |
| `clearConversationTags` | - | void |
| `setConversationFields` | fields | void |
| `clearConversationFields` | - | void |
| `getConnectionStatus` | - | String |
| `updatePushNotificationToken` | token | void |
| `shouldBeDisplayed` | messageData | String |
| `handleNotification` | messageData | bool |
| `handleNotificationTap` | messageData | void |

---

## Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/zendesk_messaging_test.dart
flutter test test/zendesk_event_test.dart

# Run with coverage
flutter test --coverage

# Run with verbose output
flutter test --reporter expanded
```

---

## Implementation Checklist

When adding tests for changed code:

### Step 1: Identify Change Type
- [ ] MethodChannel API change?
- [ ] New/modified event type?
- [ ] Model class change?
- [ ] Enum change?

### Step 2: Setup
- [ ] Add test to correct test file
- [ ] Set up MethodChannel mock if needed
- [ ] Prepare test data (native response maps)

### Step 3: Core Tests
- [ ] Test happy path
- [ ] Test argument validation (ArgumentError)
- [ ] Test return value parsing
- [ ] Test null/empty edge cases

### Step 4: Edge Cases
- [ ] Test missing optional fields
- [ ] Test default values
- [ ] Test malformed data handling
- [ ] Test platform-specific behavior if any

### Step 5: Verify
- [ ] Run tests: `flutter test`
- [ ] Verify existing tests still pass
- [ ] Check coverage for new code

---

## Common Patterns

### Mock MethodChannel Handler Pattern
```dart
TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
  log.add(methodCall);
  return switch (methodCall.method) {
    'methodName' => {'field': 'value'},
    _ => null,
  };
});
```

### Verify Method Call Pattern
```dart
expect(log, hasLength(1));
expect(log.first.method, 'expectedMethodName');
expect(log.first.arguments['key'], expectedValue);
```

### Event Parsing Pattern
```dart
final data = {'type': 'eventType', 'timestamp': 1704067200000, ...};
final event = ZendeskEventParser.parse(data);
expect(event, isA<ExpectedEventType>());
final typed = event as ExpectedEventType;
expect(typed.field, expectedValue);
```

### Model fromMap Pattern
```dart
final model = Model.fromMap({'id': '123', 'name': 'test'});
expect(model.id, '123');
expect(model.name, 'test');
```

---

## Key Principles

1. **Test the contract** - Verify method names, argument keys, return types
2. **Mirror native behavior** - Mock responses match real native SDK responses
3. **Handle edge cases** - Empty strings, null values, missing keys
4. **Validate inputs** - Ensure ArgumentError thrown for invalid inputs
5. **Keep tests atomic** - One behavior per test
6. **Maintain backwards compatibility** - Legacy streams still work
7. **Document assumptions** - Comment why specific mock values are used

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `MissingPluginException` | Ensure `TestWidgetsFlutterBinding.ensureInitialized()` is called |
| Mock handler not called | Check channel name matches exactly: `zendesk_messaging` |
| Async test fails | Use `async/await` properly, ensure test returns Future |
| Log is empty | Verify mock handler is set up in `setUp()` |
| Platform.isAndroid fails | Tests run on host platform, mock if needed |
