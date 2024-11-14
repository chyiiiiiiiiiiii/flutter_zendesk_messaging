import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Message type emitted by native platforms
enum ZendeskMessagingMessageType {
  initializeSuccess,
  initializeFailure,
  loginSuccess,
  loginFailure,
  logoutSuccess,
  logoutFailure,
  unreadMessages,
}

/// Used by ZendeskMessaging to attach custom async observers
class ZendeskMessagingObserver {
  ZendeskMessagingObserver(this.removeOnCall, this.execution);

  final bool removeOnCall;
  final Function(Map<String, dynamic>? args) execution;
}

class ZendeskLoginResponse {
  ZendeskLoginResponse(this.id, this.externalId);

  final String? id;
  final String? externalId;
}

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');
  static const channelMethodToMessageType = {
    'initialize_success': ZendeskMessagingMessageType.initializeSuccess,
    'initialize_failure': ZendeskMessagingMessageType.initializeFailure,
    'login_success': ZendeskMessagingMessageType.loginSuccess,
    'login_failure': ZendeskMessagingMessageType.loginFailure,
    'logout_success': ZendeskMessagingMessageType.logoutSuccess,
    'logout_failure': ZendeskMessagingMessageType.logoutFailure,
    'unread_messages': ZendeskMessagingMessageType.unreadMessages,
  };

  /// Global handler, all channel method calls will trigger this observer
  static Function(ZendeskMessagingMessageType type, Map? arguments)? _handler;

  /// Allow end-user to use local observer when calling some methods
  static final Map<ZendeskMessagingMessageType, ZendeskMessagingObserver> _observers = {};

  /// Attach a global observer for incoming messages
  static void setMessageHandler(
    Function(ZendeskMessagingMessageType type, Map? arguments)? handler,
  ) {
    _handler = handler;
  }

  /// Initialize the Zendesk SDK for Android and iOS
  ///
  /// @param  androidChannelKey  The Android SDK key generated from Zendesk dashboard
  /// @param  iosChannelKey      The iOS SDK key generated from the Zendesk dashboard
  static Future<void> initialize({
    required String androidChannelKey,
    required String iosChannelKey,
  }) async {
    if (androidChannelKey.isEmpty || iosChannelKey.isEmpty) {
      debugPrint('ZendeskMessaging - initialize - keys can not be empty');
      return;
    }

    try {
      _channel.setMethodCallHandler(
        _onMethodCall,
      ); // start observing channel messages
      await _channel.invokeMethod('initialize', {
        'channelKey': Platform.isAndroid ? androidChannelKey : iosChannelKey,
      });
      return;
    } catch (e) {
      debugPrint('ZendeskMessaging - initialize - Error: $e}');
      return;
    }
  }

  /// Invalidates the current instance of ZendeskMessaging.
  /// After calling this method you will have to call ZendeskMessaging.initialize again if you would like to use ZendeskMessaging.
  static Future<void> invalidate() async {
    try {
      await _channel.invokeMethod('invalidate');
    } catch (e) {
      debugPrint('ZendeskMessaging - invalidate - Error: $e}');
    }
  }

  /// Start the Zendesk Messaging UI
  static Future<void> show() async {
    try {
      await _channel.invokeMethod('show');
    } catch (e) {
      debugPrint('ZendeskMessaging - show - Error: $e}');
    }
  }

  /// Add a list of tags to a support ticket
  ///
  /// Conversation tags are not immediately associated with a conversation when this method is called.
  /// It will only be applied to a conversation when end users either start a new
  /// conversation or send a new message in an existing conversation.
  ///
  /// For example, to apply "promo_code" and "discount" tags to a conversation about an order, then you would call:
  /// `ZendeskMessaging.setConversationTags(["promo_code","discount"])`
  static Future<void> setConversationTags(List<String> tags) async {
    try {
      await _channel.invokeMethod('setConversationTags', {'tags': tags});
    } catch (e) {
      debugPrint('ZendeskMessaging - setConversationTags - Error: $e}');
    }
  }

  /// Remove all the tags on the current support ticket
  ///
  static Future<void> clearConversationTags() async {
    try {
      await _channel.invokeMethod('clearConversationTags');
    } catch (e) {
      debugPrint('ZendeskMessaging - clearConversationTags - Error: $e}');
    }
  }

  /// Authenticate the current session with a JWT
  ///
  /// @param  jwt       Required by the SDK - You must generate it from your backend
  /// @param  onSuccess Optional - If you need to be notified about the login success
  /// @param  onFailure Optional - If you need to be notified about the login failure
  static Future<void> loginUserCallbacks({
    required String jwt,
    Function(String? id, String? externalId)? onSuccess,
    Function()? onFailure,
  }) async {
    if (jwt.isEmpty) {
      debugPrint('ZendeskMessaging - loginUser - jwt can not be empty');
      return;
    }

    try {
      _setObserver(
        ZendeskMessagingMessageType.loginSuccess,
        onSuccess != null
            ? (Map? args) {
                final id = args?['id'] ?? '';
                final externalId = args?['externalId'] ?? '';
                onSuccess(id, externalId);
              }
            : null,
      );
      _setObserver(
        ZendeskMessagingMessageType.loginFailure,
        onFailure != null ? (Map? args) => onFailure() : null,
      );
      await _channel.invokeMethod('loginUser', {'jwt': jwt});
    } catch (e) {
      debugPrint('ZendeskMessaging - loginUser - Error: $e}');
    }
  }

  /// Helper function to login waiting for future to complete
  ///
  /// @return   The zendesk userId
  static Future<ZendeskLoginResponse> loginUser({required String jwt}) async {
    final completer = Completer<ZendeskLoginResponse>();
    await loginUserCallbacks(
      jwt: jwt,
      onSuccess: (id, externalId) => completer.complete(ZendeskLoginResponse(id, externalId)),
      onFailure: () => completer.completeError(Exception('Zendesk::loginUser failed')),
    );
    return completer.future;
  }

  /// Logout the currently authenticated user
  ///
  /// @param  onSuccess Optional - If you need to be notified about the logout success
  /// @param  onFailure Optional - If you need to be notified about the logout failure
  static Future<void> logoutUserCallbacks({
    Function()? onSuccess,
    Function()? onFailure,
  }) async {
    try {
      _setObserver(
        ZendeskMessagingMessageType.logoutSuccess,
        onSuccess != null ? (Map? args) => onSuccess() : null,
      );
      _setObserver(
        ZendeskMessagingMessageType.logoutFailure,
        onFailure != null ? (Map? args) => onFailure() : null,
      );

      await _channel.invokeMethod('logoutUser');
    } catch (e) {
      debugPrint('ZendeskMessaging - logoutUser - Error: $e}');
    }
  }

  /// Helper function to logout waiting for future to complete
  static Future<void> logoutUser() async {
    final completer = Completer<void>();
    await logoutUserCallbacks(
      onSuccess: completer.complete,
      onFailure: () => completer.completeError(Exception('Zendesk::logoutUser failed')),
    );
    return completer.future;
  }

  /// Listen count of unread messages
  ///
  /// @return  Function onUnreadMessageCountChanged(int) - If you need to be notified about the unread messages count changed
  static Future<void> listenUnreadMessages({
    Function(int?)? onUnreadMessageCountChanged,
  }) async {
    try {
      _setObserver(
        ZendeskMessagingMessageType.unreadMessages,
        onUnreadMessageCountChanged != null ? (Map? args) => onUnreadMessageCountChanged(args?['messages_count']) : null,
        removeOnCall: false,
      );
      await _channel.invokeMethod('listenUnreadMessages');
    } catch (e) {
      debugPrint('ZendeskMessaging - listenUnreadMessages - Error: $e}');
    }
  }

  /// Retrieve unread messages count from the Zendesk SDK
  static Future<int> getUnreadMessageCount() async {
    try {
      return await _channel.invokeMethod(
        'getUnreadMessageCount',
      );
    } catch (e) {
      debugPrint('ZendeskMessaging - count - Error: $e}');
      return 0;
    }
  }

  ///  Check if the Zendesk SDK for Android and iOS is already initialized
  static Future<bool> isInitialized() async {
    try {
      return await _channel.invokeMethod(
        'isInitialized',
      );
    } catch (e) {
      debugPrint('ZendeskMessaging - isInitialized - Error: $e}');
      return false;
    }
  }

  ///  Check if the user is already logged in
  static Future<bool> isLoggedIn() async {
    try {
      return await _channel.invokeMethod(
        'isLoggedIn',
      );
    } catch (e) {
      debugPrint('ZendeskMessaging - isLoggedIn - Error: $e}');
      return false;
    }
  }

  /// Handle incoming message from platforms (iOS and Android)
  static Future<dynamic> _onMethodCall(final MethodCall call) async {
    final method = call.method;
    final arguments = Map<String, dynamic>.from(call.arguments);

    if (!channelMethodToMessageType.containsKey(method)) {
      return;
    }

    final type = channelMethodToMessageType[method]!;
    final globalHandler = _handler;
    if (globalHandler != null) {
      globalHandler(type, arguments);
    }

    // call all observers too
    final observer = _observers[type];
    if (observer != null) {
      observer.execution(arguments);

      if (observer.removeOnCall) {
        _setObserver(type, null);
      }
    }
  }

  /// Add an observer for a specific type
  static _setObserver(
    ZendeskMessagingMessageType type,
    void Function(Map<String, dynamic>? args)? execution, {
    bool removeOnCall = true,
  }) {
    if (execution == null) {
      _observers.remove(type);
    } else {
      _observers[type] = ZendeskMessagingObserver(removeOnCall, execution);
    }
  }

  /// Set values for conversation fields in the SDK to add contextual data about the conversation.
  ///
  /// This method allows setting custom field values which are used to add additional context to a conversation in Zendesk.
  /// Conversation fields must be created as custom ticket fields in the Zendesk Admin Center and configured to be settable by end users.
  ///
  /// Note: Conversation fields are not immediately associated with a conversation when this method is called.
  /// The fields will only be applied to a conversation when end users start a new conversation or send a new message in an existing conversation.
  ///
  /// System ticket fields, such as the Priority field, are not supported.
  ///
  /// The values set by this method are persisted in the SDK and will apply to all conversations going forward.
  /// To remove fields, use the `ClearConversationFields` API.
  ///
  /// Example:
  /// To set custom fields "user_type" and "purchase_amount" for a conversation, use the following call:
  /// ```
  /// setConversationFields({"user_type": "new_user", "purchase_amount": "39.99"});
  /// ```
  static Future<void> setConversationFields(Map<String, String> fields) async {
    try {
      await _channel.invokeMethod('setConversationFields', {'fields': fields});
    } catch (e) {
      debugPrint('ZendeskMessaging - setConversationFields - Error: $e}');
    }
  }

  /// Remove all the fields on the current support ticket
  ///
  static Future<void> clearConversationFields() async {
    try {
      await _channel.invokeMethod('clearConversationFields');
    } catch (e) {
      debugPrint('ZendeskMessaging - clearConversationFields - Error: $e}');
    }
  }
}
