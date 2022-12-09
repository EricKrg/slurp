import 'package:flutter/material.dart';
import 'package:slurp/pages/landing.page.dart';
import 'package:slurp/services/database.service.dart';

PageStorageKey mykey = const PageStorageKey("testkey");
final PageStorageBucket _bucket = PageStorageBucket();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.instance.init();
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
            bodyText1: TextStyle(
                color: Colors.white, fontSize: 20, fontFamily: "OdiBeeSans"),
          )),
      home: LandingPage(key: UniqueKey()),
    );
  }
}
