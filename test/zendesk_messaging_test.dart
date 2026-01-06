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
    default:
      return null;
  }
}
