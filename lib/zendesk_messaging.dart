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

/// Messaging UI events
enum ZendeskUIEventType { opened, closed, willClose, minimized, reopened }

class ZendeskUIEvent {
  final ZendeskUIEventType type;
  final String? dismissType;
  final DateTime timestamp;

  ZendeskUIEvent(this.type, {this.dismissType, DateTime? timestamp})
      : timestamp = timestamp ?? DateTime.now();
}

/// Conversation event payload
class ZendeskConversationEvent {
  final String event; // e.g., conversation_started, conversation_opened
  final String? conversationId;
  final String? ticketId;
  final Map<String, dynamic>? payload;

  ZendeskConversationEvent(this.event,
      {this.conversationId, this.ticketId, this.payload});
}

/// Ticket status update
class ZendeskTicketStatus {
  final String ticketId;
  final String? conversationId;
  final String status;
  final DateTime timestamp;

  ZendeskTicketStatus(
      {required this.ticketId,
        this.conversationId,
        required this.status,
        required this.timestamp});

  factory ZendeskTicketStatus.fromMap(Map<String, dynamic> map) {
    return ZendeskTicketStatus(
      ticketId: map['ticketId'] ?? '',
      conversationId: map['conversationId'],
      status: map['status'] ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
          ((map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch) * 1000)
              .toInt()),
    );
  }
}

/// Zendesk authentication failure
class ZendeskAuthFailure {
  final String error;

  ZendeskAuthFailure(this.error);
}

/// Public API for Zendesk Messaging
class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');
  static bool _handlerInitialized = false;

  // Streams
  static final _unreadMessagesController = StreamController<int>.broadcast();
  static final _conversationEventsController =
  StreamController<ZendeskConversationEvent>.broadcast();
  static final _messagingUIController = StreamController<ZendeskUIEvent>.broadcast();
  static final _authFailureController =
  StreamController<ZendeskAuthFailure>.broadcast();
  static final _ticketStatusController =
  StreamController<ZendeskTicketStatus>.broadcast();

  // Stream getters
  static Stream<int> get unreadMessagesCountStream =>
      _unreadMessagesController.stream;

  static Stream<ZendeskConversationEvent> get conversationEventsStream =>
      _conversationEventsController.stream;

  static Stream<ZendeskUIEvent> get messagingUIStream =>
      _messagingUIController.stream;

  static Stream<ZendeskAuthFailure> get authFailureStream =>
      _authFailureController.stream;

  static Stream<ZendeskTicketStatus> get ticketStatusStream =>
      _ticketStatusController.stream;

  /// Initialize method call handler (called once)
  static void _initializeMethodHandler() {
    if (_handlerInitialized) return;

    debugPrint('[ZendeskMessaging] Setting up method call handler');
    _channel.setMethodCallHandler(_onMethodCall);
    _handlerInitialized = true;
    debugPrint('[ZendeskMessaging] Method call handler initialized');
  }

  /// Initialize Zendesk Messaging SDK
  static Future<void> initialize(
      {required String androidChannelKey, required String iosChannelKey}) async {
    _initializeMethodHandler();

    debugPrint('[ZendeskMessaging] Calling native initialize');
    await _channel.invokeMethod('initialize', {
      'channelKey': Platform.isAndroid ? androidChannelKey : iosChannelKey,
    });
    debugPrint('[ZendeskMessaging] Native initialize completed');
  }

  /// Start a new conversation (ticket)
  static Future<ZendeskTicketStatus?> startNewConversation(
      {ZendeskViewMode viewMode = ZendeskViewMode.fullscreen}) async {
    final result = await _channel.invokeMethod('startNewConversation', {
      if (Platform.isIOS) 'viewMode': viewMode.name,
    });

    if (result is Map) {
      final safeMap = Map<String, dynamic>.from(result);
      return ZendeskTicketStatus.fromMap(safeMap);
    }
    return null;
  }

  /// Show the chat UI
  static Future<void> show(
      {ZendeskViewMode viewMode = ZendeskViewMode.fullscreen,
        bool useNavigation = false}) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod('show');
    } else {
      await _channel.invokeMethod(
          useNavigation ? 'showInNavigation' : 'show', {'viewMode': viewMode.name});
    }
  }

  /// Login a user with JWT
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

  static Future<void> clearConversationTags() =>
      _channel.invokeMethod('clearConversationTags');

  static Future<void> setConversationFields(Map<String, String> fields) =>
      _channel.invokeMethod('setConversationFields', {'fields': fields});

  static Future<void> clearConversationFields() =>
      _channel.invokeMethod('clearConversationFields');

  /// Unread messages count
  static Future<int> getUnreadMessageCount() async =>
      await _channel.invokeMethod('getUnreadMessageCount') ?? 0;

  /// Push notification token
  static Future<void> updatePushNotificationToken(String token) async {
    await _channel.invokeMethod('updatePushNotificationToken', {'token': token});
  }

  /// Plugin state
  static Future<bool> isInitialized() async =>
      await _channel.invokeMethod('isInitialized') ?? false;

  static Future<bool> isLoggedIn() async =>
      await _channel.invokeMethod('isLoggedIn') ?? false;

  static Future<void> invalidate() async => _channel.invokeMethod('invalidate');

  /// Method call handler from native
  static Future<void> _onMethodCall(MethodCall call) async {
    debugPrint('[ZendeskMessaging._onMethodCall] Received: ${call.method}');

    // Ensure type-safe map
    final args = call.arguments is Map
        ? Map<String, dynamic>.from(call.arguments as Map)
        : <String, dynamic>{};

    switch (call.method) {
      case 'unread_messages':
        if (!_unreadMessagesController.isClosed) {
          _unreadMessagesController.add(args['messages_count'] ?? 0);
        }
        break;

      case 'conversation_event':
        if (!_conversationEventsController.isClosed) {
          _conversationEventsController.add(ZendeskConversationEvent(
            args['event'] ?? 'unknown',
            conversationId: args['conversationId'],
            ticketId: args['ticketId'],
            payload: Map<String, dynamic>.from(args),
          ));
        }
        break;

      case 'authentication_failed':
        if (!_authFailureController.isClosed) {
          _authFailureController.add(ZendeskAuthFailure(args['error'] ?? 'Unknown'));
        }
        break;

      case 'messaging_ui_event':
        if (!_messagingUIController.isClosed) {
          final eventStr = args['event'] as String?;
          final dismissType = args['dismissType'] as String?;
          ZendeskUIEventType? type;

          switch (eventStr) {
            case 'messaging_opened':
              type = ZendeskUIEventType.opened;
              break;
            case 'messaging_closed':
              type = ZendeskUIEventType.closed;
              break;
            case 'messaging_will_close':
              type = ZendeskUIEventType.willClose;
              break;
            case 'messaging_minimized':
              type = ZendeskUIEventType.minimized;
              break;
            case 'messaging_reopened':
              type = ZendeskUIEventType.reopened;
              break;
          }

          if (type != null) {
            _messagingUIController.add(ZendeskUIEvent(type, dismissType: dismissType));
          }
        }
        break;

      case 'ticket_status':
        if (!_ticketStatusController.isClosed && args.isNotEmpty) {
          _ticketStatusController.add(ZendeskTicketStatus.fromMap(args));
        }
        break;

      default:
        debugPrint('[ZendeskMessaging] Unknown method: ${call.method}');
    }
  }

  /// Dispose all streams
  static void dispose() {
    if (!_unreadMessagesController.isClosed) _unreadMessagesController.close();
    if (!_conversationEventsController.isClosed) _conversationEventsController.close();
    if (!_authFailureController.isClosed) _authFailureController.close();
    if (!_messagingUIController.isClosed) _messagingUIController.close();
    if (!_ticketStatusController.isClosed) _ticketStatusController.close();
  }
}
