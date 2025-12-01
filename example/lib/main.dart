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
    _subscribeUnreadMessages();
  }

  @override
  void dispose() {
    unreadMessagesCountSubscription?.cancel();
    ZendeskMessaging.invalidate();
    super.dispose();
  }

  void _subscribeUnreadMessages() {
    unreadMessagesCountSubscription =
        ZendeskMessaging.unreadMessagesCountStream.listen((unreadCount) {
          setState(() {
            unreadMessageCount = unreadCount;
          });
        });
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _initialize,
                  child: const Text("Initialize"),
                ),
                if (isLogin) ...[
                  ElevatedButton(
                    onPressed: _showMessaging,
                    child: const Text("Show messaging"),
                  ),
                  ElevatedButton(
                    onPressed: _getUnreadMessageCount,
                    child: Text('Get unread message count - $unreadMessageCount'),
                  ),
                ],
                ElevatedButton(
                  onPressed: _setTags,
                  child: const Text("Add tags"),
                ),
                ElevatedButton(
                  onPressed: _clearTags,
                  child: const Text("Clear tags"),
                ),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text("Login"),
                ),
                ElevatedButton(
                  onPressed: _logout,
                  child: const Text("Logout"),
                ),
                ElevatedButton(
                  onPressed: _checkUserLoggedIn,
                  child: const Text("Check LoggedIn"),
                ),
                ElevatedButton(
                  onPressed: _setFields,
                  child: const Text("Add Fields"),
                ),
                ElevatedButton(
                  onPressed: _clearFields,
                  child: const Text("Clear Fields"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initialize() async {
    try {
      await ZendeskMessaging.initialize(
        androidChannelKey: androidChannelKey,
        iosChannelKey: iosChannelKey,
      );
      setState(() {
        channelMessages.add("SDK initialized");
      });
    } catch (e) {
      setState(() {
        channelMessages.add("Initialization failed: $e");
      });
    }
  }

  Future<void> _login() async {
    try {
      final response = await ZendeskMessaging.loginUser(jwt: 'my_jwt');
      setState(() {
        channelMessages.add("Login SUCCESS: ${response.id}, ${response.externalId}");
        isLogin = true;
      });
    } catch (e) {
      setState(() {
        channelMessages.add("Login FAILURE: $e");
        isLogin = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await ZendeskMessaging.logoutUser();
      setState(() {
        isLogin = false;
        channelMessages.add("User logged out");
      });
    } catch (e) {
      setState(() {
        channelMessages.add("Logout error: $e");
      });
    }
  }

  Future<void> _getUnreadMessageCount() async {
    final count = await ZendeskMessaging.getUnreadMessageCount();
    setState(() {
      unreadMessageCount = count;
      channelMessages.add("Unread messages: $count");
    });
  }

  Future<void> _setTags() async {
    await ZendeskMessaging.setConversationTags(['tag1', 'tag2']);
    setState(() => channelMessages.add("Tags set"));
  }

  Future<void> _clearTags() async {
    await ZendeskMessaging.clearConversationTags();
    setState(() => channelMessages.add("Tags cleared"));
  }

  Future<void> _setFields() async {
    await ZendeskMessaging.setConversationFields({
      "field1": "Value 1",
      "field2": "Value 2",
    });
    setState(() => channelMessages.add("Fields set"));
  }

  Future<void> _clearFields() async {
    await ZendeskMessaging.clearConversationFields();
    setState(() => channelMessages.add("Fields cleared"));
  }

  Future<void> _checkUserLoggedIn() async {
    final loggedIn = await ZendeskMessaging.isLoggedIn();
    setState(() {
      channelMessages.add("User is ${loggedIn ? '' : 'not '}logged in");
    });
  }

  Future<void> _showMessaging() async {
    await ZendeskMessaging.show();
  }
}
