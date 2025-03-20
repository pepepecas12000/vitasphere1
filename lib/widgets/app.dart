import 'package:flutter/material.dart';

import '../screens/monitor.dart';
import 'home.dart';

class App extends StatelessWidget {
  final String? userEmail;
  const App({super.key, this.userEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "VitaSphere",
        initialRoute: "home",
        home: Monitor());//Home());
  }
}
