import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ZendeskLoginResponse {
  ZendeskLoginResponse(this.id, this.externalId);

  final String? id;
  final String? externalId;
}

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');

  static final StreamController<int> _unreadMessagesCountController =
      StreamController<int>.broadcast();
  static Stream<int> get unreadMessagesCountStream =>
      _unreadMessagesCountController.stream;

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
    } catch (e) {
      debugPrint('ZendeskMessaging - initialize - Error: $e}');
      rethrow;
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

  /// Helper function to login waiting for future to complete
  ///
  /// @return   The zendesk userId
  static Future<ZendeskLoginResponse> loginUser({required String jwt}) async {
    try {
      final result = await _channel.invokeMethod('loginUser', {'jwt': jwt});
      final arguments = result == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(result);
      final String id = arguments['id'] ?? '';
      final String externalId = arguments['externalId'] ?? '';
      return ZendeskLoginResponse(id, externalId);
    } catch (e) {
      debugPrint('ZendeskMessaging - loginUser - Error: $e}');
      rethrow;
    }
  }

  /// Helper function to logout waiting for future to complete
  static Future<void> logoutUser() async {
    try {
      await _channel.invokeMethod('logoutUser');
    } catch (e) {
      debugPrint('ZendeskMessaging - logoutUser - Error: $e}');
      rethrow;
    }
  }

  /// Listen count of unread messages
  ///
  /// @return  Function onUnreadMessageCountChanged(int) - If you need to be notified about the unread messages count changed
  static Future<void> listenUnreadMessages() async {
    try {
      await _channel.invokeMethod('listenUnreadMessages');
    } catch (e) {
      debugPrint('ZendeskMessaging - listenUnreadMessages - Error: $e}');
      rethrow;
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
    final arguments = call.arguments != null
        ? Map<String, dynamic>.from(call.arguments)
        : <String, dynamic>{};

    switch (method) {
      case 'unread_messages':
        final count = arguments['messages_count'] as int?;
        _unreadMessagesCountController.add(count ?? 0);
        break;
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
