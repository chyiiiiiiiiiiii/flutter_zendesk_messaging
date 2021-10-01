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
  final String androidChannelKey =
      'eyJzZXR0aW5nc191cmwiOiJodHRwczovL2hhbmFtaWhlbHAuemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFGR0tDRTlSNEFLWDBGOUc2Sk04Mk5RQU0uanNvbiJ9';
  final String iosChannelKey =
      'eyJzZXR0aW5nc191cmwiOiJodHRwczovL2hhbmFtaWhlbHAuemVuZGVzay5jb20vbW9iaWxlX3Nka19hcGkvc2V0dGluZ3MvMDFGR1BGVFQ1Q1hFRjdRWVkwUkg2R0JYS0MuanNvbiJ9';

  @override
  void initState() {
    super.initState();
    ZendeskMessaging.initialize(
      androidChannelKey: androidChannelKey,
      iosChannelKey: iosChannelKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Zendesk Messaging Example'),
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                const BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 2.0),
                )
              ],
            ),
            child: GestureDetector(
              onTap: () {
                ZendeskMessaging.show();
              },
              child: const Text(
                "Messaging",
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 24.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
