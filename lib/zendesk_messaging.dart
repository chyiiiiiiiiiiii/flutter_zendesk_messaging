import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');

  static Future<void> initialize({
    required String androidChannelKey,
    required String iosChannelKey,
  }) async {
    if (androidChannelKey.isEmpty || iosChannelKey.isEmpty) {
      debugPrint('ZendeskMessaging - initialize - keys can not be empty');
      return;
    }
    Map arguments = {
      'channelKey': Platform.isAndroid ? androidChannelKey : iosChannelKey,
    };
    try {
      await _channel.invokeMethod('initialize', arguments);
    } catch (e) {
      debugPrint('ZendeskMessaging - initialize - Error: $e}');
    }
  }

  static Future<void> show() async {
    await _channel.invokeMethod('show');
  }

}
