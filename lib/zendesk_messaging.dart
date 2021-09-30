
import 'dart:async';

import 'package:flutter/services.dart';

class ZendeskMessaging {
  static const MethodChannel _channel = MethodChannel('zendesk_messaging');

  static Future<void> initialize() async {
    await _channel.invokeMethod('initialize');
  }

  static Future<void> show() async {
    await _channel.invokeMethod('show');
  }
}
