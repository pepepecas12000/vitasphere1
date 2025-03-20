import 'package:flutter/material.dart';
import '../screens/welcome.dart';

class App extends StatelessWidget {
  final String? userId;
  const App({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "VitaSphere",
      home: userId != null ? Welcome(userId: userId) : const Welcome(),
    );
  }
}
