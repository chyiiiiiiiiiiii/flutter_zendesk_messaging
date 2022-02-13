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
  static const String androidChannelKey = "eyJzZXR0aW5nc191cmwiOiJodHRwczovL2hhbmFtaWhlbHAuemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFGR0tDRTlSNEFLWDBGOUc2Sk04Mk5RQU0uanNvbiJ9";
  static const String iosChannelKey = "eyJzZXR0aW5nc191cmwiOiJodHRwczovL2hhbmFtaWhlbHAuemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFGR1BGVFQ1Q1hFRjdRWVkwUkg2R0JYS0MuanNvbiJ9";

  final List<String> channelMessages = [];

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
  Widget build(BuildContext context) {
    var message = channelMessages.join("\n");

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
                ElevatedButton(
                  onPressed: () => ZendeskMessaging.initialize(androidChannelKey: androidChannelKey, iosChannelKey: iosChannelKey),
                  child: const Text("Initialize"),
                ),
                ElevatedButton(onPressed: () => ZendeskMessaging.show(), child: const Text("Show messaging")),
                ElevatedButton(onPressed: () => _login(), child: const Text("Login")),
                ElevatedButton(onPressed: () => ZendeskMessaging.logoutUser(), child: const Text("Logout")),
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
      onSuccess: (id, externalId) => setState(() => channelMessages.add("Login observer SUCCESS: $id, $externalId")),
      onFailure: () => setState(() => channelMessages.add("Login observer FAILURE !")),
    );
  }
}
