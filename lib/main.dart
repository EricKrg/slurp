import 'dart:async';

import 'package:flutter/material.dart';
import 'package:slurp/pages/landing.page.dart';
import 'package:slurp/services/database.service.dart';
import 'package:slurp/services/notifications.service.dart';

PageStorageKey mykey = const PageStorageKey("testkey");
final PageStorageBucket _bucket = PageStorageBucket();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
  await LocalNoticeService().setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slurp',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
          textTheme: const TextTheme(
            displayLarge: TextStyle(
                color: Colors.lightBlue,
                fontSize: 40,
                fontFamily: "OdiBeeSans"),
            displayMedium: TextStyle(
                color: Colors.white, fontSize: 30, fontFamily: "OdiBeeSans"),
            bodySmall: TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: 0.6,
                fontFamily: "OdiBeeSans"),
            bodyLarge: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: "OdiBeeSans"),
            bodyMedium: TextStyle(
                color: Colors.black, fontSize: 18, fontFamily: "OdiBeeSans"),
            titleMedium: TextStyle(
                color: Colors.white70, fontSize: 16, fontFamily: "OdiBeeSans"),
          )),
      home: LandingPage(key: UniqueKey()),
    );
  }
}
