import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('zendesk_messaging');
  final List<MethodCall> log = [];

  setUp(() {
    log.clear();
    // Disable logging during tests
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

  group('Initialization', () {
    test('initialize sends correct channel key for Android', () async {
      await ZendeskMessaging.initialize(
        androidChannelKey: 'android_key_123',
        iosChannelKey: 'ios_key_456',
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'initialize');
      expect(log.first.arguments, isA<Map>());
      expect(log.first.arguments['channelKey'], isNotNull);
    });

    test('initialize throws ArgumentError for empty keys', () async {
      expect(
        () => ZendeskMessaging.initialize(
          androidChannelKey: '',
          iosChannelKey: 'ios_key',
        ),
        throwsArgumentError,
      );
    });

    test('isInitialized returns correct value', () async {
      final result = await ZendeskMessaging.isInitialized();

      expect(log, hasLength(1));
      expect(log.first.method, 'isInitialized');
      expect(result, isA<bool>());
    });

    test('invalidate calls native method', () async {
      await ZendeskMessaging.invalidate();

      expect(log, hasLength(1));
      expect(log.first.method, 'invalidate');
    });
  });

  group('Authentication', () {
    test('loginUser sends JWT and returns user data', () async {
      final response = await ZendeskMessaging.loginUser(jwt: 'test_jwt_token');

      expect(log, hasLength(1));
      expect(log.first.method, 'loginUser');
      expect(log.first.arguments['jwt'], 'test_jwt_token');
      expect(response, isA<ZendeskLoginResponse>());
      expect(response.id, 'user_123');
      expect(response.externalId, 'ext_456');
    });

    test('loginUser throws ArgumentError for empty JWT', () async {
      expect(
        () => ZendeskMessaging.loginUser(jwt: ''),
        throwsArgumentError,
      );
    });

    test('logoutUser calls native method', () async {
      await ZendeskMessaging.logoutUser();

      expect(log, hasLength(1));
      expect(log.first.method, 'logoutUser');
    });

    test('isLoggedIn returns correct value', () async {
      final result = await ZendeskMessaging.isLoggedIn();

      expect(log, hasLength(1));
      expect(log.first.method, 'isLoggedIn');
      expect(result, isA<bool>());
    });

    test('getCurrentUser returns user data', () async {
      final user = await ZendeskMessaging.getCurrentUser();

      expect(log, hasLength(1));
      expect(log.first.method, 'getCurrentUser');
      expect(user, isA<ZendeskUser?>());
      if (user != null) {
        expect(user.id, 'user_123');
        expect(user.authenticationType, ZendeskAuthenticationType.jwt);
      }
    });
  });

  group('Messaging UI', () {
    test('show calls native method', () async {
      await ZendeskMessaging.show();

      expect(log, hasLength(1));
      expect(log.first.method, 'show');
    });

    test('showConversation sends conversation ID', () async {
      await ZendeskMessaging.showConversation('conv_123');

      expect(log, hasLength(1));
      expect(log.first.method, 'showConversation');
      expect(log.first.arguments['conversationId'], 'conv_123');
    });

    test('showConversation throws ArgumentError for empty ID', () async {
      expect(
        () => ZendeskMessaging.showConversation(''),
        throwsArgumentError,
      );
    });

    test('showConversationList calls native method', () async {
      await ZendeskMessaging.showConversationList();

      expect(log, hasLength(1));
      expect(log.first.method, 'showConversationList');
    });

    test('startNewConversation calls native method', () async {
      await ZendeskMessaging.startNewConversation();

      expect(log, hasLength(1));
      expect(log.first.method, 'startNewConversation');
    });
  });

  group('Message Count', () {
    test('getUnreadMessageCount returns count', () async {
      final count = await ZendeskMessaging.getUnreadMessageCount();

      expect(log, hasLength(1));
      expect(log.first.method, 'getUnreadMessageCount');
      expect(count, 5);
    });

    test('getUnreadMessageCountForConversation returns count', () async {
      final count = await ZendeskMessaging.getUnreadMessageCountForConversation(
        'conv_123',
      );

      expect(log, hasLength(1));
      expect(log.first.method, 'getUnreadMessageCountForConversation');
      expect(log.first.arguments['conversationId'], 'conv_123');
      expect(count, 3);
    });

    test('getUnreadMessageCountForConversation throws for empty ID', () async {
      expect(
        () => ZendeskMessaging.getUnreadMessageCountForConversation(''),
        throwsArgumentError,
      );
    });

    test('listenUnreadMessages calls native method', () async {
      await ZendeskMessaging.listenUnreadMessages();

      expect(log, hasLength(1));
      expect(log.first.method, 'listenUnreadMessages');
    });
  });

  group('Connection Status', () {
    test('getConnectionStatus returns status', () async {
      final status = await ZendeskMessaging.getConnectionStatus();

      expect(log, hasLength(1));
      expect(log.first.method, 'getConnectionStatus');
      expect(status, ZendeskConnectionStatus.connected);
    });
  });

  group('Conversation Data', () {
    test('setConversationTags sends tags list', () async {
      await ZendeskMessaging.setConversationTags(['tag1', 'tag2', 'tag3']);

      expect(log, hasLength(1));
      expect(log.first.method, 'setConversationTags');
      expect(log.first.arguments['tags'], ['tag1', 'tag2', 'tag3']);
    });

    test('setConversationTags throws for empty list', () async {
      expect(
        () => ZendeskMessaging.setConversationTags([]),
        throwsArgumentError,
      );
    });

    test('clearConversationTags calls native method', () async {
      await ZendeskMessaging.clearConversationTags();

      expect(log, hasLength(1));
      expect(log.first.method, 'clearConversationTags');
    });

    test('setConversationFields sends fields map', () async {
      await ZendeskMessaging.setConversationFields({
        'field1': 'value1',
        'field2': 'value2',
      });

      expect(log, hasLength(1));
      expect(log.first.method, 'setConversationFields');
      expect(log.first.arguments['fields'], {
        'field1': 'value1',
        'field2': 'value2',
      });
    });

    test('setConversationFields throws for empty map', () async {
      expect(
        () => ZendeskMessaging.setConversationFields({}),
        throwsArgumentError,
      );
    });

    test('clearConversationFields calls native method', () async {
      await ZendeskMessaging.clearConversationFields();

      expect(log, hasLength(1));
      expect(log.first.method, 'clearConversationFields');
    });
  });

  group('Push Notifications', () {
    test('updatePushNotificationToken sends token', () async {
      await ZendeskMessaging.updatePushNotificationToken('test_fcm_token_123');

      expect(log, hasLength(1));
      expect(log.first.method, 'updatePushNotificationToken');
      expect(log.first.arguments['token'], 'test_fcm_token_123');
    });

    test('updatePushNotificationToken throws ArgumentError for empty token',
        () async {
      expect(
        () => ZendeskMessaging.updatePushNotificationToken(''),
        throwsArgumentError,
      );
    });

    test('shouldBeDisplayed returns correct responsibility', () async {
      final responsibility = await ZendeskMessaging.shouldBeDisplayed({
        'zendesk_sdk_request_id': 'request_123',
        'conversation_id': 'conv_456',
      });

      expect(log, hasLength(1));
      expect(log.first.method, 'shouldBeDisplayed');
      expect(log.first.arguments['messageData'], isA<Map>());
      expect(responsibility, ZendeskPushResponsibility.messagingShouldDisplay);
    });

    test('shouldBeDisplayed handles notFromMessaging', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'shouldBeDisplayed') {
          return 'notFromMessaging';
        }
        return _handleMockMethodCall(methodCall);
      });

      final responsibility = await ZendeskMessaging.shouldBeDisplayed({
        'other_key': 'value',
      });

      expect(responsibility, ZendeskPushResponsibility.notFromMessaging);
    });

    test('handleNotification returns true when handled', () async {
      final handled = await ZendeskMessaging.handleNotification({
        'zendesk_sdk_request_id': 'request_123',
        'conversation_id': 'conv_456',
      });

      expect(log, hasLength(1));
      expect(log.first.method, 'handleNotification');
      expect(log.first.arguments['messageData'], isA<Map>());
      expect(handled, isTrue);
    });

    test('handleNotification returns false when not handled', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'handleNotification') {
          return false;
        }
        return _handleMockMethodCall(methodCall);
      });

      final handled = await ZendeskMessaging.handleNotification({
        'other_key': 'value',
      });

      expect(handled, isFalse);
    });

    test('handleNotificationTap calls native method', () async {
      await ZendeskMessaging.handleNotificationTap({
        'zendesk_sdk_request_id': 'request_123',
        'conversation_id': 'conv_456',
      });

      expect(log, hasLength(1));
      expect(log.first.method, 'handleNotificationTap');
      expect(log.first.arguments['messageData'], isA<Map>());
    });
  });

  group('Authentication Edge Cases', () {
    test('getCurrentUser returns null when no user', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getCurrentUser') {
          return null;
        }
        return _handleMockMethodCall(methodCall);
      });

      final user = await ZendeskMessaging.getCurrentUser();

      expect(log, hasLength(1));
      expect(log.first.method, 'getCurrentUser');
      expect(user, isNull);
    });

    test('isInitialized returns false when not initialized', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'isInitialized') {
          return false;
        }
        return _handleMockMethodCall(methodCall);
      });

      final result = await ZendeskMessaging.isInitialized();

      expect(result, isFalse);
    });

    test('isLoggedIn returns false when not logged in', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'isLoggedIn') {
          return false;
        }
        return _handleMockMethodCall(methodCall);
      });

      final result = await ZendeskMessaging.isLoggedIn();

      expect(result, isFalse);
    });

    test('loginUser handles null response', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'loginUser') {
          return null;
        }
        return _handleMockMethodCall(methodCall);
      });

      final response = await ZendeskMessaging.loginUser(jwt: 'test_jwt');

      expect(response, isA<ZendeskLoginResponse>());
      expect(response.id, isNull);
      expect(response.externalId, isNull);
    });
  });

  group('Message Count Edge Cases', () {
    test('getUnreadMessageCount returns 0 when null', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getUnreadMessageCount') {
          return null;
        }
        return _handleMockMethodCall(methodCall);
      });

      final count = await ZendeskMessaging.getUnreadMessageCount();

      expect(count, 0);
    });

    test('getUnreadMessageCountForConversation returns 0 when null', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getUnreadMessageCountForConversation') {
          return null;
        }
        return _handleMockMethodCall(methodCall);
      });

      final count = await ZendeskMessaging.getUnreadMessageCountForConversation(
        'conv_123',
      );

      expect(count, 0);
    });
  });

  group('Connection Status Edge Cases', () {
    test('getConnectionStatus handles unknown status', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getConnectionStatus') {
          return 'unknown_status';
        }
        return _handleMockMethodCall(methodCall);
      });

      final status = await ZendeskMessaging.getConnectionStatus();

      expect(status, ZendeskConnectionStatus.unknown);
    });

    test('getConnectionStatus handles null status', () async {
      // Override handler for this specific test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'getConnectionStatus') {
          return null;
        }
        return _handleMockMethodCall(methodCall);
      });

      final status = await ZendeskMessaging.getConnectionStatus();

      expect(status, ZendeskConnectionStatus.unknown);
    });
  });

  group('ZendeskMessagingConfig', () {
    test('logging can be enabled and disabled', () {
      ZendeskMessagingConfig.enableLogging = true;
      expect(ZendeskMessagingConfig.enableLogging, isTrue);

      ZendeskMessagingConfig.enableLogging = false;
      expect(ZendeskMessagingConfig.enableLogging, isFalse);
    });

    test('custom logger can be set', () {
      final logs = <String>[];
      ZendeskMessagingConfig.enableLogging = true;
      ZendeskMessagingConfig.logger = (message, {error, stackTrace}) {
        logs.add(message);
      };

      ZendeskMessagingConfig.log('test message');

      expect(logs, contains('[ZendeskMessaging] test message'));

      // Cleanup
      ZendeskMessagingConfig.logger = null;
      ZendeskMessagingConfig.enableLogging = false;
    });

    test('log does nothing when logging is disabled', () {
      final logs = <String>[];
      ZendeskMessagingConfig.enableLogging = false;
      ZendeskMessagingConfig.logger = (message, {error, stackTrace}) {
        logs.add(message);
      };

      ZendeskMessagingConfig.log('test message');

      expect(logs, isEmpty);

      // Cleanup
      ZendeskMessagingConfig.logger = null;
    });

    test('logError includes error details', () {
      final logs = <String>[];
      Object? capturedError;
      StackTrace? capturedStackTrace;

      ZendeskMessagingConfig.enableLogging = true;
      ZendeskMessagingConfig.logger = (message, {error, stackTrace}) {
        logs.add(message);
        capturedError = error;
        capturedStackTrace = stackTrace;
      };

      final testError = Exception('Test error');
      final testStackTrace = StackTrace.current;
      ZendeskMessagingConfig.logError(
        'error occurred',
        error: testError,
        stackTrace: testStackTrace,
      );

      expect(logs, contains('[ZendeskMessaging] error occurred'));
      expect(capturedError, testError);
      expect(capturedStackTrace, testStackTrace);

      // Cleanup
      ZendeskMessagingConfig.logger = null;
      ZendeskMessagingConfig.enableLogging = false;
    });
  });
}

dynamic _handleMockMethodCall(MethodCall methodCall) {
  switch (methodCall.method) {
    case 'initialize':
      return null;
    case 'isInitialized':
      return true;
    case 'invalidate':
      return null;
    case 'loginUser':
      return {
        'id': 'user_123',
        'externalId': 'ext_456',
        'authenticationType': 'jwt',
      };
    case 'logoutUser':
      return null;
    case 'isLoggedIn':
      return true;
    case 'getCurrentUser':
      return {
        'id': 'user_123',
        'externalId': 'ext_456',
        'authenticationType': 'jwt',
      };
    case 'show':
      return null;
    case 'showConversation':
      return null;
    case 'showConversationList':
      return null;
    case 'startNewConversation':
      return null;
    case 'getUnreadMessageCount':
      return 5;
    case 'getUnreadMessageCountForConversation':
      return 3;
    case 'listenUnreadMessages':
      return null;
    case 'getConnectionStatus':
      return 'connected';
    case 'setConversationTags':
      return null;
    case 'clearConversationTags':
      return null;
    case 'setConversationFields':
      return null;
    case 'clearConversationFields':
      return null;
    case 'updatePushNotificationToken':
      return null;
    case 'shouldBeDisplayed':
      return 'messagingShouldDisplay';
    case 'handleNotification':
      return true;
    case 'handleNotificationTap':
      return null;
    default:
      return null;
  }
}
