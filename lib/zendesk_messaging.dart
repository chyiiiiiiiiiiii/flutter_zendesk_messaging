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
}

/// Used by ZendeskMessaging to attach custom async observers
class ZendeskMessagingObserver {
  final bool removeOnCall;
  final Function(Map? args) func;

  ZendeskMessagingObserver(this.removeOnCall, this.func);
}

class ZendeskLoginResponse {
  final String? id;
  final String? externalId;

  ZendeskLoginResponse(this.id, this.externalId);
}

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');
  static const channelMethodToMessageType = {
    "initialize_success": ZendeskMessagingMessageType.initializeSuccess,
    "initialize_failure": ZendeskMessagingMessageType.initializeFailure,
    "login_success": ZendeskMessagingMessageType.loginSuccess,
    "login_failure": ZendeskMessagingMessageType.loginFailure,
    "logout_success": ZendeskMessagingMessageType.logoutSuccess,
    "logout_failure": ZendeskMessagingMessageType.logoutFailure,
  };

  /// Global handler, all channel method calls will trigger this observer
  static Function(ZendeskMessagingMessageType type, Map? arguments)? _handler;

  /// Allow end-user to use local observer when calling some methods
  static final Map<ZendeskMessagingMessageType, ZendeskMessagingObserver> _observers = {};

  /// Attach a global observer for incoming messages
  static void setMessageHandler(Function(ZendeskMessagingMessageType type, Map? arguments)? handler) {
    _handler = handler;
  }

  /// Initialize the Zendesk SDK for Android and iOS
  ///
  /// @param  androidChannelKey  The Android SDK key generated from Zendesk dashboard
  /// @param  iosChannelKey      The iOS SDK key generated from the Zendesk dashboard
  static Future<void> initialize({required String androidChannelKey, required String iosChannelKey}) async {
    if (androidChannelKey.isEmpty || iosChannelKey.isEmpty) {
      debugPrint('ZendeskMessaging - initialize - keys can not be empty');
      return;
    }

    try {
      _channel.setMethodCallHandler(_onMethodCall); // start observing channel messages
      await _channel.invokeMethod('initialize', {
        'channelKey': Platform.isAndroid ? androidChannelKey : iosChannelKey,
      });
    } catch (e) {
      debugPrint('ZendeskMessaging - initialize - Error: $e}');
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

  /// Authenticate the current session with a JWT
  ///
  /// @param  jwt       Required by the SDK - You must generate it from your backend
  /// @param  onSuccess Optional - If you need to be notified about the login success
  /// @param  onFailure Optional - If you need to be notified about the login failure
  static Future<void> loginUserCallbacks({required String jwt, Function(String? id, String? externalId)? onSuccess, Function()? onFailure}) async {
    if (jwt.isEmpty) {
      debugPrint('ZendeskMessaging - loginUser - jwt can not be empty');
      return;
    }

    try {
      _setObserver(ZendeskMessagingMessageType.loginSuccess, onSuccess != null ? (Map? args) => onSuccess(args?["id"], args?["externalId"]) : null);
      _setObserver(ZendeskMessagingMessageType.loginFailure, onFailure != null ? (Map? args) => onFailure() : null);

      await _channel.invokeMethod('loginUser', {'jwt': jwt});
    } catch (e) {
      debugPrint('ZendeskMessaging - loginUser - Error: $e}');
    }
  }

  /// Helper function to login waiting for future to complete
  ///
  /// @return   The zendesk userId
  static Future<ZendeskLoginResponse> loginUser({required String jwt}) async {
    var completer = Completer<ZendeskLoginResponse>();
    await loginUserCallbacks(
      jwt: jwt,
      onSuccess: (id, externalId) => completer.complete(ZendeskLoginResponse(id, externalId)),
      onFailure: () => completer.completeError(Exception("Zendesk::loginUser failed")),
    );
    return completer.future;
  }

  /// Logout the currently authenticated user
  ///
  /// @param  onSuccess Optional - If you need to be notified about the logout success
  /// @param  onFailure Optional - If you need to be notified about the logout failure
  static Future<void> logoutUserCallbacks({Function()? onSuccess, Function()? onFailure}) async {
    try {
      _setObserver(ZendeskMessagingMessageType.logoutSuccess, onSuccess != null ? (Map? args) => onSuccess() : null);
      _setObserver(ZendeskMessagingMessageType.logoutFailure, onFailure != null ? (Map? args) => onFailure() : null);

      await _channel.invokeMethod('logoutUser');
    } catch (e) {
      debugPrint('ZendeskMessaging - logoutUser - Error: $e}');
    }
  }

  /// Helper function to logout waiting for future to complete
  static Future<void> logoutUser() async {
    var completer = Completer<void>();
    await logoutUserCallbacks(
      onSuccess: () => completer.complete(),
      onFailure: () => completer.completeError(Exception("Zendesk::logoutUser failed")),
    );
    return completer.future;
  }

  /// Handle incoming message from platforms (iOS and Android)
  static Future<dynamic> _onMethodCall(final MethodCall call) async {
    if (!channelMethodToMessageType.containsKey(call.method)) {
      return;
    }

    final ZendeskMessagingMessageType type = channelMethodToMessageType[call.method]!;
    var globalHandler = _handler;
    if (globalHandler != null) {
      globalHandler(type, call.arguments);
    }

    // call all observers too
    final ZendeskMessagingObserver? observer = _observers[type];
    if (observer != null) {
      observer.func(call.arguments);
      if (observer.removeOnCall) {
        _setObserver(type, null);
      }
    }
  }

  /// Add an observer for a specific type
  static _setObserver(ZendeskMessagingMessageType type, Function(Map? args)? func, {bool removeOnCall = true}) {
    if (func == null) {
      _observers.remove(type);
    } else {
      _observers[type] = ZendeskMessagingObserver(removeOnCall, func);
    }
  }
}
