import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String androidChannelKey = "your android key";
  static const String iosChannelKey = "your iOS key";

  final List<String> channelMessages = [];
  StreamSubscription<int>? unreadMessagesCountSubscription;

  bool isLogin = false;
  int unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ZendeskMessaging.invalidate();
    unreadMessagesCountSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = channelMessages.join("\n");

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zendesk Messaging Example'),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Text(message),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () => ZendeskMessaging.initialize(
                    androidChannelKey: androidChannelKey,
                    iosChannelKey: iosChannelKey,
                  ),
                  child: const Text("Initialize"),
                ),
                if (isLogin) ...[
                  ElevatedButton(
                    onPressed: () => ZendeskMessaging.show(),
                    child: const Text("Show messaging"),
                  ),
                  ElevatedButton(
                    onPressed: () => _getUnreadMessageCount(),
                    child:
                    Text('Get unread message count - $unreadMessageCount'),
                  ),
                  ElevatedButton(
                    onPressed: () => _listenUnreadMessageCount(),
                    child: Text(
                        'Listen unread message count - $unreadMessageCount'),
                  ),
                ],
                ElevatedButton(
                  onPressed: () => _setTags(),
                  child: const Text("Add tags"),
                ),
                ElevatedButton(
                  onPressed: () => _clearTags(),
                  child: const Text("Clear tags"),
                ),
                ElevatedButton(
                  onPressed: () => _login(),
                  child: const Text("Login"),
                ),
                ElevatedButton(
                  onPressed: () => _logout(),
                  child: const Text("Logout"),
                ),
                ElevatedButton(
                  onPressed: () => _checkUserLoggedIn(),
                  child: const Text("Check LoggedIn"),
                ),
                ElevatedButton(
                  onPressed: () => _setFields(),
                  child: const Text("Add Fields"),
                ),
                ElevatedButton(
                  onPressed: () => _clearFields(),
                  child: const Text("Clear Fields"),
                ),
                ElevatedButton(
                  onPressed: () => _show(),
                  child: const Text("Show"),
                ),
                ElevatedButton(
                  onPressed: () => _testHandlePushNotification(),
                  child: const Text("Test Handle Push Notification (Zendesk)"),
                ),
                ElevatedButton(
                  onPressed: () => _testHandleNonZendeskNotification(),
                  child: const Text("Test Handle Push Notification (Non-Zendesk)"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    // You can attach local observer when calling some methods to be notified when ready
    try {
      final response = await ZendeskMessaging.loginUser(jwt: 'my_jwt');
      setState(() {
        channelMessages.add(
            "Login observer - SUCCESS: ${response.id}, ${response.externalId}");
        isLogin = true;
      });
    } catch (e) {
      setState(() {
        channelMessages.add("Login observer - FAILURE!");
        isLogin = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await ZendeskMessaging.logoutUser();
      unreadMessagesCountSubscription?.cancel();
    } catch (_) {}
    setState(() {
      isLogin = false;
    });
  }

  void _getUnreadMessageCount() async {
    final messageCount = await ZendeskMessaging.getUnreadMessageCount();
    if (mounted) {
      unreadMessageCount = messageCount;
      setState(() {});
    }
  }

  void _listenUnreadMessageCount() async {
    await ZendeskMessaging.listenUnreadMessages();

    unreadMessagesCountSubscription =
        ZendeskMessaging.unreadMessagesCountStream.listen((unreadCount) {
          print('unread count changed: $unreadCount');
          setState(() {
            unreadMessageCount = unreadCount;
          });
        });
  }

  void _setTags() async {
    final tags = ['tag1', 'tag2', 'tag3'];
    await ZendeskMessaging.setConversationTags(tags);
  }

  void _clearTags() async {
    await ZendeskMessaging.clearConversationTags();
  }

  void _checkUserLoggedIn() async {
    final isLoggedIn = await ZendeskMessaging.isLoggedIn();
    setState(() {
      channelMessages.add('User is ${isLoggedIn ? '' : 'not'} logged in');
    });
  }

  void _setFields() async {
    Map<String, String> fieldsMap = {};

    fieldsMap["field1"] = "Value 1";
    fieldsMap["field2"] = "Value 2";

    await ZendeskMessaging.setConversationFields(fieldsMap);
  }

  void _clearFields() async {
    await ZendeskMessaging.clearConversationFields();
  }

  void _show() {
    ZendeskMessaging.show();
  }

  Future<void> _testHandlePushNotification() async {
    try {
      // Check if Zendesk is initialized first
      final isInitialized = await ZendeskMessaging.isInitialized();
      if (!isInitialized) {
        setState(() {
          channelMessages.add('ERROR: Please initialize Zendesk first! Click "Initialize" button.');
        });
        return;
      }

      // Simulate a Zendesk push notification payload
      // This mimics what Firebase would send for a Zendesk notification
      final mockNotificationData = {
        'zendesk': 'true',
        'zd.conversation_id': '12345',
        'zd.message_id': '67890',
        'title': 'New message from Zendesk',
        'body': 'You have a new message in your support conversation',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      };

      await ZendeskMessaging.handlePushNotification(mockNotificationData);

      setState(() {
        channelMessages.add('✓ Zendesk push notification handled - messaging interface should open');
      });
    } catch (e) {
      setState(() {
        channelMessages.add('✗ Push notification error: $e');
      });
    }
  }

  Future<void> _testHandleNonZendeskNotification() async {
    try {
      // Check if Zendesk is initialized first
      final isInitialized = await ZendeskMessaging.isInitialized();
      if (!isInitialized) {
        setState(() {
          channelMessages.add('ERROR: Please initialize Zendesk first! Click "Initialize" button.');
        });
        return;
      }

      // Simulate a non-Zendesk push notification payload
      final mockNotificationData = {
        'title': 'Regular notification',
        'body': 'This is not a Zendesk notification',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      };

      await ZendeskMessaging.handlePushNotification(mockNotificationData);

      setState(() {
        channelMessages.add('✓ Non-Zendesk push notification handled - should be ignored (check logs)');
      });
    } catch (e) {
      setState(() {
        channelMessages.add('✗ Push notification error: $e');
      });
    }
  }
}
