import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
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
  @override
  void initState() {
    super.initState();
    //
    ZendeskMessaging.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                const BoxShadow(
                  color: Colors.grey,
                  offset: Offset(2.0, 3.0),
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
