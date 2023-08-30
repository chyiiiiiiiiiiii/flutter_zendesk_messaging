import 'package:flutter/material.dart';
import 'package:zendesk_messaging/zendesk_messaging.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
    // Optional, observe all incoming messages
    ZendeskMessaging.setMessageHandler((type, arguments) {
      setState(() {
        channelMessages.add("$type - args=$arguments");
      });
    });
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
                    child: Text('Get unread message count - $unreadMessageCount'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    // You can attach local observer when calling some methods to be notified when ready
    ZendeskMessaging.loginUserCallbacks(
      jwt: "my_jwt",
      onSuccess: (id, externalId) => setState(() {
        channelMessages.add("Login observer - SUCCESS: $id, $externalId");
        isLogin = true;
      }),
      onFailure: () => setState(() {
        channelMessages.add("Login observer - FAILURE!");
        isLogin = false;
      }),
    );
  }

  void _logout() {
    ZendeskMessaging.logoutUser();
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
  void _checkUserLoggedIn()async {
   final isLoggedIn = await ZendeskMessaging.isLoggedIn();
   setState(() {
     channelMessages.add('User is ${isLoggedIn?'':'not'} logged in');
   });
  }
}
