import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';

/// Response for login
class ZendeskLoginResponse {
  ZendeskLoginResponse(this.id, this.externalId);

  final String? id;
  final String? externalId;
}

/// Chat view modes
enum ZendeskViewMode { fullscreen, sheet, pageSheet, formSheet, automatic }

/// Exit action for messaging screen
enum ZendeskExitAction { close, returnToConversationList }

extension ZendeskExitActionExtension on ZendeskExitAction {
  String get value {
    switch (this) {
      case ZendeskExitAction.close:
        return 'close';
      case ZendeskExitAction.returnToConversationList:
        return 'return_to_conversation_list';
    }
  }
}

/// Messaging UI events
enum ZendeskUIEventType { opened, closed, willClose, minimized, reopened }

class ZendeskUIEvent {
  final ZendeskUIEventType type;
  final String? dismissType;
  final DateTime timestamp;

  ZendeskUIEvent(this.type, {this.dismissType, DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();
}

/// Conversation events
class ZendeskConversationEvent {
  final String event;
  final String? conversationId;
  final String? ticketId;
  final Map<String, dynamic>? payload;

  ZendeskConversationEvent(this.event, {this.conversationId, this.ticketId, this.payload});
}

/// Ticket status
class ZendeskTicketStatus {
  final String ticketId;
  final String? conversationId;
  final String status;
  final DateTime timestamp;

  ZendeskTicketStatus({required this.ticketId, this.conversationId, required this.status, required this.timestamp});

  factory ZendeskTicketStatus.fromMap(Map<String, dynamic> map) {
    return ZendeskTicketStatus(
      ticketId: map['ticketId'] ?? '',
      conversationId: map['conversationId'],
      status: map['status'] ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          ((map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch) * 1000).toInt()),
    );
  }
}

/// Authentication failure
class ZendeskAuthFailure {
  final String error;

  ZendeskAuthFailure(this.error);
}

/// Main plugin class
class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');
  static bool _handlerInitialized = false;

  // Streams
  static final _unreadMessagesController = StreamController<int>.broadcast();
  static final _conversationEventsController = StreamController<ZendeskConversationEvent>.broadcast();
  static final _messagingUIController = StreamController<ZendeskUIEvent>.broadcast();
  static final _authFailureController = StreamController<ZendeskAuthFailure>.broadcast();
  static final _ticketStatusController = StreamController<ZendeskTicketStatus>.broadcast();
  static final _notificationTapController = StreamController<Map<String, dynamic>>.broadcast();

  // Stream getters
  static Stream<int> get unreadMessagesCountStream => _unreadMessagesController.stream;

  static Stream<ZendeskConversationEvent> get conversationEventsStream => _conversationEventsController.stream;

  static Stream<ZendeskUIEvent> get messagingUIStream => _messagingUIController.stream;

  static Stream<ZendeskAuthFailure> get authFailureStream => _authFailureController.stream;

  static Stream<ZendeskTicketStatus> get ticketStatusStream => _ticketStatusController.stream;

  static Stream<Map<String, dynamic>> get notificationTapStream => _notificationTapController.stream;

  /// Initialize method handler
  static void _initializeMethodHandler() {
    if (_handlerInitialized) return;
    debugPrint('[ZendeskMessaging] Setting up method call handler');
    _channel.setMethodCallHandler(_onMethodCall);
    _handlerInitialized = true;
    debugPrint('[ZendeskMessaging] Method call handler initialized');
  }

  /// Initialize Zendesk SDK
  static Future<void> initialize({required String androidChannelKey, required String iosChannelKey}) async {
    _initializeMethodHandler();

    debugPrint('[ZendeskMessaging] Calling native initialize');
    await _channel.invokeMethod('initialize', {
      'channelKey': Platform.isAndroid ? androidChannelKey : iosChannelKey,
    });
    debugPrint('[ZendeskMessaging] Native initialize completed');
  }

  /// Show messaging UI
  static Future<void> show({
    ZendeskViewMode viewMode = ZendeskViewMode.fullscreen,
    ZendeskExitAction exitAction = ZendeskExitAction.close,
    bool useNavigation = false,
  }) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('show');
    } else {
      await _channel.invokeMethod(
        useNavigation ? 'showInNavigation' : 'show',
        {
          'viewMode': viewMode.name,
          'exitAction': exitAction.value,
        },
      );
    }
  }

  /// Start a new conversation
  static Future<ZendeskTicketStatus?> startNewConversation({
    ZendeskViewMode viewMode = ZendeskViewMode.fullscreen,
    ZendeskExitAction exitAction = ZendeskExitAction.close,
    Map<String, String>? preFilledFields,
    List<String>? tags,
  }) async {
    final result = await _channel.invokeMethod('startNewConversation', {
      if (Platform.isIOS) 'viewMode': viewMode.name,
      if (Platform.isIOS) 'exitAction': exitAction.value,
      if (preFilledFields != null && preFilledFields.isNotEmpty) 'preFilledFields': preFilledFields,
      if (tags != null && tags.isNotEmpty) 'tags': tags,
    });

    if (result is Map) {
      return ZendeskTicketStatus.fromMap(Map<String, dynamic>.from(result));
    }
    return null;
  }

  /// Login / logout
  static Future<ZendeskLoginResponse> loginUser({required String jwt}) async {
    final result = await _channel.invokeMethod('loginUser', {'jwt': jwt});
    if (result is Map) {
      final safeMap = Map<String, dynamic>.from(result);
      return ZendeskLoginResponse(safeMap['id'], safeMap['externalId']);
    }
    return ZendeskLoginResponse(null, null);
  }

  /// Logout user
  static Future<void> logoutUser() => _channel.invokeMethod('logoutUser');

  /// Conversation fields/tags
  static Future<void> setConversationTags(List<String> tags) =>
      _channel.invokeMethod('setConversationTags', {'tags': tags});

  static Future<void> clearConversationTags() => _channel.invokeMethod('clearConversationTags');

  static Future<void> setConversationFields(Map<String, String> fields) =>
      _channel.invokeMethod('setConversationFields', {'fields': fields});

  static Future<void> clearConversationFields() => _channel.invokeMethod('clearConversationFields');

  /// Unread messages
  static Future<int> getUnreadMessageCount() async => await _channel.invokeMethod('getUnreadMessageCount') ?? 0;

  /// Push notification support
  static Future<void> updatePushNotificationToken(String token) async {
    await _channel.invokeMethod('updatePushNotificationToken', {'token': token});
  }

  static Future<void> handlePushNotification(Map<String, dynamic> data) async {
    await _channel.invokeMethod('handlePushNotification', {'data': data});
  }

  /// Plugin state
  static Future<bool> isInitialized() async => await _channel.invokeMethod('isInitialized') ?? false;

  static Future<bool> isLoggedIn() async => await _channel.invokeMethod('isLoggedIn') ?? false;

  static Future<void> invalidate() async => _channel.invokeMethod('invalidate');

  /// Method call handler from native
  static Future<void> _onMethodCall(MethodCall call) async {
    debugPrint('[ZendeskMessaging._onMethodCall] Received: ${call.method}');

    final args = call.arguments is Map ? Map<String, dynamic>.from(call.arguments as Map) : <String, dynamic>{};

    switch (call.method) {
      case 'onEvent':
        _handleNativeEvent(args);
        break;
      case 'notification_tap':
        _notificationTapController.add(args);
        break;
      default:
        debugPrint('[ZendeskMessaging] Unknown method: ${call.method}');
    }
  }

  static void _handleNativeEvent(Map<String, dynamic> args) {
    String? eventType = args['type']?.toString();
    if (eventType != null) {
      eventType = eventType.replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}').toLowerCase();
    }

    debugPrint('[ZendeskMessaging] Event type: $eventType, args: $args');

    switch (eventType) {
      case 'unread_message_count_changed':
        if (!_unreadMessagesController.isClosed) {
          _unreadMessagesController.add(args['currentUnreadCount'] as int? ?? 0);
        }
        break;

      case 'connection_status_changed':
        final status = args['connectionStatus']?.toString();
        debugPrint('[ZendeskMessaging] Connection status changed: $status');
        break;

      case 'conversation_event':
      case 'conversation_added':
      case 'conversation_opened':
      case 'conversation_started':
      case 'messages_shown':
        _conversationEventsController.add(
          ZendeskConversationEvent(
            eventType ?? 'conversation_event',
            conversationId: args['conversationId']?.toString(),
            ticketId: args['ticketId']?.toString(),
            payload: args,
          ),
        );

        break;

      case 'messaging_ui_event':
      case 'messaging_opened':
      case 'messaging_closed':
      case 'messaging_will_close':
      case 'messaging_minimized':
      case 'messaging_reopened':
        if (!_messagingUIController.isClosed) {
          final uiEventMap = <String, ZendeskUIEventType>{
            'messaging_opened': ZendeskUIEventType.opened,
            'messaging_closed': ZendeskUIEventType.closed,
            'messaging_will_close': ZendeskUIEventType.willClose,
            'messaging_minimized': ZendeskUIEventType.minimized,
            'messaging_reopened': ZendeskUIEventType.reopened,
          };
          final type = uiEventMap[eventType];
          final dismissType = args['dismissType'] as String?;
          if (type != null) {
            _messagingUIController.add(ZendeskUIEvent(type, dismissType: dismissType));
          }
        }
        break;

      case 'ticket_status':
        if (!_ticketStatusController.isClosed && args.isNotEmpty) {
          try {
            _ticketStatusController.add(ZendeskTicketStatus.fromMap(args));
          } catch (e, st) {
            debugPrint('[ZendeskMessaging] Failed to parse ticket_status: $e\n$st');
          }
        }
        break;

      case 'authentication_failed':
      case 'send_message_failed':
        _authFailureController.add(ZendeskAuthFailure(args['error']?.toString() ?? 'Unknown'));
        break;

      default:
        debugPrint('[ZendeskMessaging] Unknown event type: $eventType');
    }
  }

  /// Dispose all streams
  static void dispose() {
    if (!_unreadMessagesController.isClosed) _unreadMessagesController.close();
    if (!_conversationEventsController.isClosed) _conversationEventsController.close();
    if (!_authFailureController.isClosed) _authFailureController.close();
    if (!_messagingUIController.isClosed) _messagingUIController.close();
    if (!_ticketStatusController.isClosed) _ticketStatusController.close();
    if (!_notificationTapController.isClosed) _notificationTapController.close();
  }
}
