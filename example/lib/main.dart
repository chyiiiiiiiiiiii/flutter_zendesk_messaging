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

  bool isLogin = false;
  int unreadMessageCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ZendeskMessaging.invalidate();
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
      channelMessages.add(
          "Login observer - SUCCESS: ${response.id}, ${response.externalId}");
      isLogin = true;
    } catch (e) {
      channelMessages.add("Login observer - FAILURE!");
      isLogin = false;
    }
  }

  Future<void> _logout() async {
    try {
      await ZendeskMessaging.logoutUser();
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
}
