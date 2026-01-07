import 'package:flutter_test/flutter_test.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  group('ZendeskEventParser', () {
    test('UnreadMessageCountChanged parses correctly', () {
      final data = {
        'type': 'unreadMessageCountChanged',
        'timestamp': 1704067200000,
        'totalUnreadCount': 5,
        'conversationId': 'conv_123',
        'conversationUnreadCount': 2,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<UnreadMessageCountChanged>());
      final unreadEvent = event as UnreadMessageCountChanged;
      expect(unreadEvent.totalUnreadCount, 5);
      expect(unreadEvent.conversationId, 'conv_123');
      expect(unreadEvent.conversationUnreadCount, 2);
    });

    test('AuthenticationFailed parses correctly', () {
      final data = {
        'type': 'authenticationFailed',
        'timestamp': 1704067200000,
        'errorCode': 'auth_error',
        'errorMessage': 'Token expired',
        'isJwtExpired': true,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<AuthenticationFailed>());
      final authEvent = event as AuthenticationFailed;
      expect(authEvent.errorCode, 'auth_error');
      expect(authEvent.errorMessage, 'Token expired');
      expect(authEvent.isJwtExpired, true);
    });

    test('ConnectionStatusChanged parses correctly', () {
      final data = {
        'type': 'connectionStatusChanged',
        'timestamp': 1704067200000,
        'status': 'connected',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConnectionStatusChanged>());
      final connEvent = event as ConnectionStatusChanged;
      expect(connEvent.status, ZendeskConnectionStatus.connected);
    });

    test('ConversationAdded parses correctly', () {
      final data = {
        'type': 'conversationAdded',
        'timestamp': 1704067200000,
        'conversationId': 'new_conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationAdded>());
      final convEvent = event as ConversationAdded;
      expect(convEvent.conversationId, 'new_conv_123');
    });

    test('ConversationStarted parses correctly', () {
      final data = {
        'type': 'conversationStarted',
        'timestamp': 1704067200000,
        'conversationId': 'started_conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationStarted>());
      final convEvent = event as ConversationStarted;
      expect(convEvent.conversationId, 'started_conv_123');
    });

    test('ConversationOpened parses correctly', () {
      final data = {
        'type': 'conversationOpened',
        'timestamp': 1704067200000,
        'conversationId': 'opened_conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationOpened>());
      final convEvent = event as ConversationOpened;
      expect(convEvent.conversationId, 'opened_conv_123');
    });

    test('MessagesShown parses correctly with messages', () {
      final data = {
        'type': 'messagesShown',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        'messages': [
          {
            'id': 'msg_1',
            'conversationId': 'conv_123',
            'content': 'Hello',
            'timestamp': 1704067100000,
          },
          {
            'id': 'msg_2',
            'conversationId': 'conv_123',
            'content': 'World',
            'timestamp': 1704067150000,
          },
        ],
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<MessagesShown>());
      final msgEvent = event as MessagesShown;
      expect(msgEvent.conversationId, 'conv_123');
      expect(msgEvent.messages.length, 2);
      expect(msgEvent.messages[0].id, 'msg_1');
      expect(msgEvent.messages[0].content, 'Hello');
      expect(msgEvent.messages[1].id, 'msg_2');
      expect(msgEvent.messages[1].content, 'World');
    });

    test('SendMessageFailed parses correctly', () {
      final data = {
        'type': 'sendMessageFailed',
        'timestamp': 1704067200000,
        'errorMessage': 'Network error',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<SendMessageFailed>());
      final failEvent = event as SendMessageFailed;
      expect(failEvent.errorMessage, 'Network error');
    });

    test('FieldValidationFailed parses correctly', () {
      final data = {
        'type': 'fieldValidationFailed',
        'timestamp': 1704067200000,
        'errors': ['Field 1 invalid', 'Field 2 required'],
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<FieldValidationFailed>());
      final validationEvent = event as FieldValidationFailed;
      expect(validationEvent.errors.length, 2);
      expect(validationEvent.errors[0], 'Field 1 invalid');
    });

    test('MessagingOpened parses correctly', () {
      final data = {
        'type': 'messagingOpened',
        'timestamp': 1704067200000,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<MessagingOpened>());
    });

    test('MessagingClosed parses correctly', () {
      final data = {
        'type': 'messagingClosed',
        'timestamp': 1704067200000,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<MessagingClosed>());
    });

    test('ProactiveMessageDisplayed parses correctly', () {
      final data = {
        'type': 'proactiveMessageDisplayed',
        'timestamp': 1704067200000,
        'proactiveMessageId': 'proactive_123',
        'campaignId': 'campaign_456',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ProactiveMessageDisplayed>());
      final proactiveEvent = event as ProactiveMessageDisplayed;
      expect(proactiveEvent.proactiveMessageId, 'proactive_123');
      expect(proactiveEvent.campaignId, 'campaign_456');
    });

    test('ProactiveMessageClicked parses correctly', () {
      final data = {
        'type': 'proactiveMessageClicked',
        'timestamp': 1704067200000,
        'proactiveMessageId': 'proactive_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ProactiveMessageClicked>());
      final proactiveEvent = event as ProactiveMessageClicked;
      expect(proactiveEvent.proactiveMessageId, 'proactive_123');
    });

    test('ConversationWithAgentRequested parses correctly', () {
      final data = {
        'type': 'conversationWithAgentRequested',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationWithAgentRequested>());
      final agentEvent = event as ConversationWithAgentRequested;
      expect(agentEvent.conversationId, 'conv_123');
    });

    test('ConversationWithAgentAssigned parses correctly', () {
      final data = {
        'type': 'conversationWithAgentAssigned',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationWithAgentAssigned>());
      final agentEvent = event as ConversationWithAgentAssigned;
      expect(agentEvent.conversationId, 'conv_123');
    });

    test('ConversationServedByAgent parses correctly', () {
      final data = {
        'type': 'conversationServedByAgent',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        'agentId': 'agent_456',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationServedByAgent>());
      final agentEvent = event as ConversationServedByAgent;
      expect(agentEvent.conversationId, 'conv_123');
      expect(agentEvent.agentId, 'agent_456');
    });

    test('NewConversationButtonClicked parses correctly', () {
      final data = {
        'type': 'newConversationButtonClicked',
        'timestamp': 1704067200000,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<NewConversationButtonClicked>());
    });

    test('PostbackButtonClicked parses correctly', () {
      final data = {
        'type': 'postbackButtonClicked',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        'actionName': 'buy_now',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<PostbackButtonClicked>());
      final postbackEvent = event as PostbackButtonClicked;
      expect(postbackEvent.conversationId, 'conv_123');
      expect(postbackEvent.actionName, 'buy_now');
    });

    test('ArticleClicked parses correctly', () {
      final data = {
        'type': 'articleClicked',
        'timestamp': 1704067200000,
        'articleUrl': 'https://help.example.com/article/123',
        'conversationId': 'conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ArticleClicked>());
      final articleEvent = event as ArticleClicked;
      expect(articleEvent.articleUrl, 'https://help.example.com/article/123');
      expect(articleEvent.conversationId, 'conv_123');
    });

    test('ArticleBrowserClicked parses correctly', () {
      final data = {
        'type': 'articleBrowserClicked',
        'timestamp': 1704067200000,
        'articleUrl': 'https://help.example.com/article/456',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ArticleBrowserClicked>());
      final articleEvent = event as ArticleBrowserClicked;
      expect(articleEvent.articleUrl, 'https://help.example.com/article/456');
    });

    test('ConversationExtensionOpened parses correctly', () {
      final data = {
        'type': 'conversationExtensionOpened',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        'extensionUrl': 'https://extension.example.com',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationExtensionOpened>());
      final extEvent = event as ConversationExtensionOpened;
      expect(extEvent.conversationId, 'conv_123');
      expect(extEvent.extensionUrl, 'https://extension.example.com');
    });

    test('ConversationExtensionDisplayed parses correctly', () {
      final data = {
        'type': 'conversationExtensionDisplayed',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        'extensionUrl': 'https://extension.example.com',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationExtensionDisplayed>());
      final extEvent = event as ConversationExtensionDisplayed;
      expect(extEvent.conversationId, 'conv_123');
      expect(extEvent.extensionUrl, 'https://extension.example.com');
    });

    test('NotificationDisplayed parses correctly', () {
      final data = {
        'type': 'notificationDisplayed',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<NotificationDisplayed>());
      final notifEvent = event as NotificationDisplayed;
      expect(notifEvent.conversationId, 'conv_123');
    });

    test('NotificationOpened parses correctly', () {
      final data = {
        'type': 'notificationOpened',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<NotificationOpened>());
      final notifEvent = event as NotificationOpened;
      expect(notifEvent.conversationId, 'conv_123');
    });

    test('Unknown event type returns null', () {
      final data = {
        'type': 'unknownEventType',
        'timestamp': 1704067200000,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isNull);
    });

    test('Null data returns null', () {
      final event = ZendeskEventParser.parse(null);

      expect(event, isNull);
    });
  });

  group('ZendeskConnectionStatus', () {
    test('connected status parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('connected'),
        ZendeskConnectionStatus.connected,
      );
    });

    test('connectingRealtime status parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('connectingRealtime'),
        ZendeskConnectionStatus.connectingRealtime,
      );
    });

    test('connectedRealtime status parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('connectedRealtime'),
        ZendeskConnectionStatus.connectedRealtime,
      );
    });

    test('reconnecting maps to connectingRealtime', () {
      expect(
        ZendeskConnectionStatus.fromString('reconnecting'),
        ZendeskConnectionStatus.connectingRealtime,
      );
    });

    test('disconnected status parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('disconnected'),
        ZendeskConnectionStatus.disconnected,
      );
    });

    test('unknown string returns unknown status', () {
      expect(
        ZendeskConnectionStatus.fromString('invalid'),
        ZendeskConnectionStatus.unknown,
      );
    });

    test('null string returns unknown status', () {
      expect(
        ZendeskConnectionStatus.fromString(null),
        ZendeskConnectionStatus.unknown,
      );
    });
  });

  group('ZendeskAuthenticationType', () {
    test('jwt type parses correctly', () {
      expect(
        ZendeskAuthenticationType.fromString('jwt'),
        ZendeskAuthenticationType.jwt,
      );
    });

    test('anonymous type parses correctly', () {
      expect(
        ZendeskAuthenticationType.fromString('anonymous'),
        ZendeskAuthenticationType.anonymous,
      );
    });

    test('unknown string returns anonymous', () {
      expect(
        ZendeskAuthenticationType.fromString('invalid'),
        ZendeskAuthenticationType.anonymous,
      );
    });

    test('null string returns anonymous', () {
      expect(
        ZendeskAuthenticationType.fromString(null),
        ZendeskAuthenticationType.anonymous,
      );
    });
  });

  group('ZendeskUser', () {
    test('creates user with all fields', () {
      const user = ZendeskUser(
        id: 'user_123',
        externalId: 'ext_456',
        authenticationType: ZendeskAuthenticationType.jwt,
      );

      expect(user.id, 'user_123');
      expect(user.externalId, 'ext_456');
      expect(user.authenticationType, ZendeskAuthenticationType.jwt);
    });

    test('creates user with null optional fields', () {
      const user = ZendeskUser(
        id: null,
        externalId: null,
        authenticationType: ZendeskAuthenticationType.anonymous,
      );

      expect(user.id, isNull);
      expect(user.externalId, isNull);
      expect(user.authenticationType, ZendeskAuthenticationType.anonymous);
    });

    test('fromMap creates user correctly', () {
      final user = ZendeskUser.fromMap({
        'id': 'user_123',
        'externalId': 'ext_456',
        'authenticationType': 'jwt',
      });

      expect(user.id, 'user_123');
      expect(user.externalId, 'ext_456');
      expect(user.authenticationType, ZendeskAuthenticationType.jwt);
    });

    test('equality works correctly', () {
      const user1 = ZendeskUser(
        id: 'user_123',
        externalId: 'ext_456',
        authenticationType: ZendeskAuthenticationType.jwt,
      );
      const user2 = ZendeskUser(
        id: 'user_123',
        externalId: 'ext_456',
        authenticationType: ZendeskAuthenticationType.jwt,
      );
      const user3 = ZendeskUser(
        id: 'different',
        externalId: 'ext_456',
        authenticationType: ZendeskAuthenticationType.jwt,
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });

  group('ZendeskMessage', () {
    test('creates message with all fields', () {
      final timestamp = DateTime.now();
      final message = ZendeskMessage(
        id: 'msg_123',
        conversationId: 'conv_456',
        authorId: 'author_789',
        content: 'Hello World',
        timestamp: timestamp,
      );

      expect(message.id, 'msg_123');
      expect(message.conversationId, 'conv_456');
      expect(message.authorId, 'author_789');
      expect(message.content, 'Hello World');
      expect(message.timestamp, timestamp);
    });

    test('creates message with null optional fields', () {
      final timestamp = DateTime.now();
      final message = ZendeskMessage(
        id: 'msg_123',
        conversationId: 'conv_456',
        authorId: null,
        content: null,
        timestamp: timestamp,
      );

      expect(message.id, 'msg_123');
      expect(message.conversationId, 'conv_456');
      expect(message.authorId, isNull);
      expect(message.content, isNull);
    });

    test('fromMap creates message correctly', () {
      final message = ZendeskMessage.fromMap({
        'id': 'msg_123',
        'conversationId': 'conv_456',
        'authorId': 'author_789',
        'content': 'Hello',
        'timestamp': 1704067200000,
      });

      expect(message.id, 'msg_123');
      expect(message.conversationId, 'conv_456');
      expect(message.authorId, 'author_789');
      expect(message.content, 'Hello');
      expect(message.timestamp, isNotNull);
    });
  });

  group('ZendeskLoginResponse', () {
    test('creates response with all fields', () {
      const response = ZendeskLoginResponse(
        id: 'user_123',
        externalId: 'ext_456',
      );

      expect(response.id, 'user_123');
      expect(response.externalId, 'ext_456');
    });

    test('creates response with null optional fields', () {
      const response = ZendeskLoginResponse(
        id: null,
        externalId: null,
      );

      expect(response.id, isNull);
      expect(response.externalId, isNull);
    });

    test('fromMap creates response correctly', () {
      final response = ZendeskLoginResponse.fromMap({
        'id': 'user_123',
        'externalId': 'ext_456',
      });

      expect(response.id, 'user_123');
      expect(response.externalId, 'ext_456');
    });

    test('equality works correctly', () {
      const response1 = ZendeskLoginResponse(
        id: 'user_123',
        externalId: 'ext_456',
      );
      const response2 = ZendeskLoginResponse(
        id: 'user_123',
        externalId: 'ext_456',
      );

      expect(response1, equals(response2));
    });

    test('hashCode is consistent', () {
      const response1 = ZendeskLoginResponse(
        id: 'user_123',
        externalId: 'ext_456',
      );
      const response2 = ZendeskLoginResponse(
        id: 'user_123',
        externalId: 'ext_456',
      );

      expect(response1.hashCode, equals(response2.hashCode));
    });

    test('toString returns readable format', () {
      const response = ZendeskLoginResponse(
        id: 'user_123',
        externalId: 'ext_456',
      );

      expect(response.toString(), contains('user_123'));
      expect(response.toString(), contains('ext_456'));
    });
  });

  group('ZendeskPushResponsibility', () {
    test('messagingShouldDisplay parses correctly', () {
      expect(
        ZendeskPushResponsibility.fromString('messagingShouldDisplay'),
        ZendeskPushResponsibility.messagingShouldDisplay,
      );
    });

    test('messagingShouldDisplay with underscore parses correctly', () {
      expect(
        ZendeskPushResponsibility.fromString('messaging_should_display'),
        ZendeskPushResponsibility.messagingShouldDisplay,
      );
    });

    test('messagingShouldNotDisplay parses correctly', () {
      expect(
        ZendeskPushResponsibility.fromString('messagingShouldNotDisplay'),
        ZendeskPushResponsibility.messagingShouldNotDisplay,
      );
    });

    test('messagingShouldNotDisplay with underscore parses correctly', () {
      expect(
        ZendeskPushResponsibility.fromString('messaging_should_not_display'),
        ZendeskPushResponsibility.messagingShouldNotDisplay,
      );
    });

    test('notFromMessaging parses correctly', () {
      expect(
        ZendeskPushResponsibility.fromString('notFromMessaging'),
        ZendeskPushResponsibility.notFromMessaging,
      );
    });

    test('notFromMessaging with underscore parses correctly', () {
      expect(
        ZendeskPushResponsibility.fromString('not_from_messaging'),
        ZendeskPushResponsibility.notFromMessaging,
      );
    });

    test('unknown string returns unknown', () {
      expect(
        ZendeskPushResponsibility.fromString('invalid'),
        ZendeskPushResponsibility.unknown,
      );
    });

    test('null string returns unknown', () {
      expect(
        ZendeskPushResponsibility.fromString(null),
        ZendeskPushResponsibility.unknown,
      );
    });
  });

  group('ZendeskUser additional tests', () {
    test('hashCode is consistent', () {
      const user1 = ZendeskUser(
        id: 'user_123',
        externalId: 'ext_456',
        authenticationType: ZendeskAuthenticationType.jwt,
      );
      const user2 = ZendeskUser(
        id: 'user_123',
        externalId: 'ext_456',
        authenticationType: ZendeskAuthenticationType.jwt,
      );

      expect(user1.hashCode, equals(user2.hashCode));
    });

    test('toString returns readable format', () {
      const user = ZendeskUser(
        id: 'user_123',
        externalId: 'ext_456',
        authenticationType: ZendeskAuthenticationType.jwt,
      );

      expect(user.toString(), contains('user_123'));
      expect(user.toString(), contains('ext_456'));
      expect(user.toString(), contains('jwt'));
    });

    test('fromMap handles missing fields', () {
      final user = ZendeskUser.fromMap({});

      expect(user.id, isNull);
      expect(user.externalId, isNull);
      expect(user.authenticationType, ZendeskAuthenticationType.anonymous);
    });
  });

  group('ZendeskMessage additional tests', () {
    test('hashCode is consistent', () {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(1704067200000);
      final message1 = ZendeskMessage(
        id: 'msg_123',
        conversationId: 'conv_456',
        authorId: 'author_789',
        content: 'Hello',
        timestamp: timestamp,
      );
      final message2 = ZendeskMessage(
        id: 'msg_123',
        conversationId: 'conv_456',
        authorId: 'author_789',
        content: 'Hello',
        timestamp: timestamp,
      );

      expect(message1.hashCode, equals(message2.hashCode));
    });

    test('equality works correctly', () {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(1704067200000);
      final message1 = ZendeskMessage(
        id: 'msg_123',
        conversationId: 'conv_456',
        authorId: 'author_789',
        content: 'Hello',
        timestamp: timestamp,
      );
      final message2 = ZendeskMessage(
        id: 'msg_123',
        conversationId: 'conv_456',
        authorId: 'author_789',
        content: 'Hello',
        timestamp: timestamp,
      );
      final message3 = ZendeskMessage(
        id: 'different',
        conversationId: 'conv_456',
        authorId: 'author_789',
        content: 'Hello',
        timestamp: timestamp,
      );

      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });

    test('toString returns readable format', () {
      final message = ZendeskMessage(
        id: 'msg_123',
        conversationId: 'conv_456',
        authorId: 'author_789',
        content: 'Hello',
        timestamp: DateTime.now(),
      );

      expect(message.toString(), contains('msg_123'));
      expect(message.toString(), contains('conv_456'));
      expect(message.toString(), contains('Hello'));
    });

    test('fromMap handles missing optional fields', () {
      final message = ZendeskMessage.fromMap({
        'id': 'msg_123',
        'conversationId': 'conv_456',
      });

      expect(message.id, 'msg_123');
      expect(message.conversationId, 'conv_456');
      expect(message.authorId, isNull);
      expect(message.content, isNull);
      expect(message.timestamp, isNull);
    });

    test('fromMap handles missing required fields with defaults', () {
      final message = ZendeskMessage.fromMap({});

      expect(message.id, '');
      expect(message.conversationId, '');
    });
  });

  group('ZendeskEventParser edge cases', () {
    test('parses event with non-Map data returns null', () {
      final event = ZendeskEventParser.parse('not a map');

      expect(event, isNull);
    });

    test('parses event with missing timestamp uses current time', () {
      final data = {
        'type': 'messagingOpened',
        // timestamp omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<MessagingOpened>());
      expect(event!.timestamp, isNotNull);
      // Timestamp should be close to now
      expect(
        event.timestamp.difference(DateTime.now()).inSeconds.abs(),
        lessThan(2),
      );
    });

    test('UnreadMessageCountChanged handles missing optional fields', () {
      final data = {
        'type': 'unreadMessageCountChanged',
        'timestamp': 1704067200000,
        'totalUnreadCount': 5,
        // conversationId and conversationUnreadCount omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<UnreadMessageCountChanged>());
      final unreadEvent = event as UnreadMessageCountChanged;
      expect(unreadEvent.totalUnreadCount, 5);
      expect(unreadEvent.conversationId, isNull);
      expect(unreadEvent.conversationUnreadCount, isNull);
    });

    test('AuthenticationFailed handles missing fields with defaults', () {
      final data = {
        'type': 'authenticationFailed',
        'timestamp': 1704067200000,
        // All optional fields omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<AuthenticationFailed>());
      final authEvent = event as AuthenticationFailed;
      expect(authEvent.errorCode, 'unknown');
      expect(authEvent.errorMessage, 'Unknown error');
      expect(authEvent.isJwtExpired, false);
    });

    test('FieldValidationFailed handles non-list errors', () {
      final data = {
        'type': 'fieldValidationFailed',
        'timestamp': 1704067200000,
        'errors': null,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<FieldValidationFailed>());
      final validationEvent = event as FieldValidationFailed;
      expect(validationEvent.errors, isEmpty);
    });

    test('MessagesShown handles empty messages list', () {
      final data = {
        'type': 'messagesShown',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        'messages': [],
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<MessagesShown>());
      final msgEvent = event as MessagesShown;
      expect(msgEvent.messages, isEmpty);
    });

    test('MessagesShown handles null messages', () {
      final data = {
        'type': 'messagesShown',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        'messages': null,
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<MessagesShown>());
      final msgEvent = event as MessagesShown;
      expect(msgEvent.messages, isEmpty);
    });

    test('SendMessageFailed handles missing conversationId', () {
      final data = {
        'type': 'sendMessageFailed',
        'timestamp': 1704067200000,
        'errorMessage': 'Failed to send',
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<SendMessageFailed>());
      final failEvent = event as SendMessageFailed;
      expect(failEvent.conversationId, isNull);
      expect(failEvent.errorMessage, 'Failed to send');
    });

    test('ConversationOpened handles null conversationId', () {
      final data = {
        'type': 'conversationOpened',
        'timestamp': 1704067200000,
        // conversationId omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationOpened>());
      final convEvent = event as ConversationOpened;
      expect(convEvent.conversationId, isNull);
    });

    test('ProactiveMessageDisplayed handles null campaignId', () {
      final data = {
        'type': 'proactiveMessageDisplayed',
        'timestamp': 1704067200000,
        'proactiveMessageId': 'proactive_123',
        // campaignId omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ProactiveMessageDisplayed>());
      final proactiveEvent = event as ProactiveMessageDisplayed;
      expect(proactiveEvent.proactiveMessageId, 'proactive_123');
      expect(proactiveEvent.campaignId, isNull);
    });

    test('ArticleClicked handles null conversationId', () {
      final data = {
        'type': 'articleClicked',
        'timestamp': 1704067200000,
        'articleUrl': 'https://help.example.com/article/123',
        // conversationId omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ArticleClicked>());
      final articleEvent = event as ArticleClicked;
      expect(articleEvent.articleUrl, 'https://help.example.com/article/123');
      expect(articleEvent.conversationId, isNull);
    });

    test('ConversationServedByAgent handles null agentId', () {
      final data = {
        'type': 'conversationServedByAgent',
        'timestamp': 1704067200000,
        'conversationId': 'conv_123',
        // agentId omitted
      };

      final event = ZendeskEventParser.parse(data);

      expect(event, isA<ConversationServedByAgent>());
      final agentEvent = event as ConversationServedByAgent;
      expect(agentEvent.conversationId, 'conv_123');
      expect(agentEvent.agentId, isNull);
    });
  });

  group('ZendeskConnectionStatus case insensitivity', () {
    test('CONNECTED (uppercase) parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('CONNECTED'),
        ZendeskConnectionStatus.connected,
      );
    });

    test('Connected (mixed case) parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('Connected'),
        ZendeskConnectionStatus.connected,
      );
    });

    test('DISCONNECTED (uppercase) parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('DISCONNECTED'),
        ZendeskConnectionStatus.disconnected,
      );
    });

    test('RECONNECTING (uppercase) parses correctly', () {
      expect(
        ZendeskConnectionStatus.fromString('RECONNECTING'),
        ZendeskConnectionStatus.connectingRealtime,
      );
    });
  });

  group('ZendeskAuthenticationType case insensitivity', () {
    test('JWT (uppercase) parses correctly', () {
      expect(
        ZendeskAuthenticationType.fromString('JWT'),
        ZendeskAuthenticationType.jwt,
      );
    });

    test('Jwt (mixed case) parses correctly', () {
      expect(
        ZendeskAuthenticationType.fromString('Jwt'),
        ZendeskAuthenticationType.jwt,
      );
    });

    test('ANONYMOUS (uppercase) parses correctly', () {
      expect(
        ZendeskAuthenticationType.fromString('ANONYMOUS'),
        ZendeskAuthenticationType.anonymous,
      );
    });
  });
}
